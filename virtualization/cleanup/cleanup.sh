#!/bin/bash

cleanup_hosts_file() {
    print_info "Curățare $HOSTS_FILE..."

    BACKUP_FILE="${HOSTS_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$HOSTS_FILE" "$BACKUP_FILE"
    print_info "Backup creat: $BACKUP_FILE"

    REMOVED_COUNT=0
    for container in "${MATCHING_CONTAINERS[@]}"; do
        if grep -q "^.*${container}.*${HOSTS_MARKER}" "$HOSTS_FILE"; then
            sed -i "/^.*${container}.*${HOSTS_MARKER}/d" "$HOSTS_FILE"
            print_info "Înlăturată intrarea din /etc/hosts pentru '$container'"
            ((REMOVED_COUNT++))
        fi
    done

    if [[ $REMOVED_COUNT -eq 0 ]]; then
        print_info "Nu s-au găsit intrări în /etc/hosts pentru aceste containere"
    else
        print_info "Au fost înlăturate $REMOVED_COUNT intrări din $HOSTS_FILE"
    fi
}

cleanup_ssh_known_hosts() {
    print_info "Curățare SSH known_hosts..."

    if [[ -f "/root/.ssh/known_hosts" ]]; then
        for container in "${MATCHING_CONTAINERS[@]}"; do
            ssh-keygen -R "$container" -f "/root/.ssh/known_hosts" &>/dev/null || true
        done
    fi

    if [[ -n "$SUDO_USER" ]]; then
        USER_HOME=$(eval echo ~$SUDO_USER)
        if [[ -f "$USER_HOME/.ssh/known_hosts" ]]; then
            for container in "${MATCHING_CONTAINERS[@]}"; do
                sudo -u "$SUDO_USER" ssh-keygen -R "$container" -f "$USER_HOME/.ssh/known_hosts" &>/dev/null || true
            done
        fi
    fi

    print_info "SSH known_hosts curățat"
}

display_summary() {
    echo
    print_info "======================================"
    print_info "Curățare completă!"
    print_info "======================================"
    echo

    print_info "Au fost șterse ${#MATCHING_CONTAINERS[@]} container(e):"
    for container in "${MATCHING_CONTAINERS[@]}"; do
        echo "  - $container"
    done

    echo
    print_info "Acțiuni de curățare efectuate:"
    echo "  - Oprite toate containerele potrivite"
    echo "  - Șterse toate containerele potrivite"
    echo "  - Înlăturate intrările din /etc/hosts"
    echo "  - Curățat SSH known_hosts"
    echo

    if [[ -n "$BACKUP_FILE" ]]; then
        print_info "Backup-ul /etc/hosts salvat la: $BACKUP_FILE"
    fi
}
