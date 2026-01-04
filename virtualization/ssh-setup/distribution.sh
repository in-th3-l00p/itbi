#!/bin/bash

distribute_ssh_keys() {
    print_info "Distribuire cheie SSH publică la containere..."
    echo

    PUB_KEY_PATH="${SSH_KEY_PATH}.pub"
    PUB_KEY_CONTENT=$(cat "$PUB_KEY_PATH")

    for i in "${!MATCHING_CONTAINERS[@]}"; do
        container="${MATCHING_CONTAINERS[$i]}"
        current=$((i + 1))
        total=${#MATCHING_CONTAINERS[@]}

        print_info "[$current/$total] Configurare acces SSH pentru '$container'..."

        IP=$($LXC_CMD list "$container" -c 4 --format csv | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | head -n1)

        if [[ -z "$IP" ]]; then
            print_warn "[$current/$total] Nu s-a putut obține IP pentru '$container', se omite..."
            continue
        fi

        print_info "[$current/$total] Se așteaptă SSH pe $container ($IP)..."
        for attempt in {1..30}; do
            if nc -z -w 2 "$IP" 22 &>/dev/null; then
                break
            fi
            sleep 1
        done

        print_info "[$current/$total] Creare director SSH pe '$container'..."
        $LXC_CMD exec "$container" -- su - "$SSH_USER" -c "mkdir -p ~/.ssh && chmod 700 ~/.ssh"

        print_info "[$current/$total] Adăugare cheie publică la authorized_keys..."
        $LXC_CMD exec "$container" -- su - "$SSH_USER" -c "echo '$PUB_KEY_CONTENT' >> ~/.ssh/authorized_keys"
        $LXC_CMD exec "$container" -- su - "$SSH_USER" -c "chmod 600 ~/.ssh/authorized_keys"

        print_info "[$current/$total] Cheia SSH a fost adăugată la '$container' cu succes"
    done

    echo
    print_info "Chei SSH distribuite la toate containerele"
}

test_ssh_access() {
    print_info "Testare acces SSH fără parolă..."
    echo

    FAILED_TESTS=()

    for i in "${!MATCHING_CONTAINERS[@]}"; do
        container="${MATCHING_CONTAINERS[$i]}"
        current=$((i + 1))
        total=${#MATCHING_CONTAINERS[@]}

        print_info "[$current/$total] Testare SSH la '$container'..."

        SSH_CMD="ssh"
        if [[ -n "$SUDO_USER" ]]; then
            SSH_CMD="sudo -u $SUDO_USER ssh"
        fi

        if $SSH_CMD -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o BatchMode=yes \
            "${SSH_USER}@${container}" "echo 'Test SSH reușit'" &>/dev/null; then
            print_info "[$current/$total] SSH la '$container' funcționează!"
        else
            print_warn "[$current/$total] SSH la '$container' a eșuat!"
            FAILED_TESTS+=("$container")
        fi
    done

    echo

    if [[ ${#FAILED_TESTS[@]} -eq 0 ]]; then
        print_info "Toate testele SSH au trecut cu succes!"
    else
        print_warn "Testele SSH au eșuat pentru următoarele containere:"
        for container in "${FAILED_TESTS[@]}"; do
            echo "  - $container"
        done
        return 1
    fi
}

display_summary() {
    echo
    print_info "======================================"
    print_info "Configurare SSH completă!"
    print_info "======================================"
    echo

    print_info "Acum poți accesa containerele fără parolă:"
    for container in "${MATCHING_CONTAINERS[@]}"; do
        echo "  ssh ${SSH_USER}@${container}"
    done

    echo
    print_info "Pentru comenzi shell paralele, folosește pdsh:"
    HOST_LIST=$(IFS=,; echo "${MATCHING_CONTAINERS[*]}")
    echo "  pdsh -w ${HOST_LIST} -l ${SSH_USER} 'hostname'"
    echo
}
