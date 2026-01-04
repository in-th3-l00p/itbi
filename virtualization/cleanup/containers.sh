#!/bin/bash

get_matching_containers() {
    print_info "Căutare containere care se potrivesc cu pattern-ul '$PATTERN'..."

    local all_containers=$(lxc list -c n --format csv)
    local regex_pattern="${PATTERN//\*/.*}"

    MATCHING_CONTAINERS=()

    for container in $all_containers; do
        if [[ "$container" == "base-ubuntu" ]]; then
            continue
        fi

        if [[ "$container" =~ $regex_pattern ]]; then
            MATCHING_CONTAINERS+=("$container")
        fi
    done

    if [[ ${#MATCHING_CONTAINERS[@]} -eq 0 ]]; then
        print_warn "Nu s-au găsit containere care se potrivesc cu pattern-ul '$PATTERN'"
        exit 0
    fi

    print_info "S-au găsit ${#MATCHING_CONTAINERS[@]} container(e) potrivite:"
    for container in "${MATCHING_CONTAINERS[@]}"; do
        STATUS=$(lxc list "$container" -c s --format csv)
        echo "  - $container ($STATUS)"
    done
    echo
}

confirm_deletion() {
    print_warn "======================================"
    print_warn "ATENȚIE: Confirmare ștergere"
    print_warn "======================================"
    echo
    print_warn "Următoarele containere vor fi ȘTERSE PERMANENT:"
    for container in "${MATCHING_CONTAINERS[@]}"; do
        echo "  - $container"
    done
    echo
    print_warn "Această acțiune NU poate fi anulată!"
    echo

    read -p "Ești sigur că vrei să ștergi aceste containere? (yes/NU): " -r
    echo

    if [[ ! "$REPLY" =~ ^[Yy][Ee][Ss]$ ]]; then
        print_info "Ștergere anulată de utilizator"
        exit 0
    fi

    print_info "Se continuă cu ștergerea..."
    echo
}

stop_containers() {
    print_info "Oprire containere..."
    echo

    for i in "${!MATCHING_CONTAINERS[@]}"; do
        container="${MATCHING_CONTAINERS[$i]}"
        current=$((i + 1))
        total=${#MATCHING_CONTAINERS[@]}

        STATUS=$(lxc list "$container" -c s --format csv)

        if [[ "$STATUS" == "RUNNING" ]]; then
            print_info "[$current/$total] Oprire '$container'..."
            lxc stop "$container" --force
        else
            print_info "[$current/$total] Containerul '$container' este deja oprit"
        fi
    done

    echo
    print_info "Toate containerele au fost oprite"
}

delete_containers() {
    print_info "Ștergere containere..."
    echo

    for i in "${!MATCHING_CONTAINERS[@]}"; do
        container="${MATCHING_CONTAINERS[$i]}"
        current=$((i + 1))
        total=${#MATCHING_CONTAINERS[@]}

        print_info "[$current/$total] Ștergere '$container'..."
        lxc delete "$container" --force

        print_info "[$current/$total] Containerul '$container' a fost șters cu succes"
    done

    echo
    print_info "Toate containerele au fost șterse"
}
