#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHARED_DIR="$SCRIPT_DIR/../shared"

source "$SHARED_DIR/config.sh"
source "$SHARED_DIR/output.sh"
source "$SHARED_DIR/checks.sh"
source "$SHARED_DIR/utils.sh"
source "$SCRIPT_DIR/validation.sh"
source "$SCRIPT_DIR/containers.sh"
source "$SCRIPT_DIR/network.sh"

print_usage() {
    cat << EOF
Utilizare: $0 <număr_noduri> <prefix_nume>

Creează multiple containere LXD prin clonarea containerului de bază.

Argumente:
  număr_noduri  Numărul de containere de creat (ex: 5)
  prefix_nume   Prefixul pentru numele containerelor (ex: "node" creează node1, node2, ...)

Exemple:
  $0 5 foo        # Creează foo1, foo2, foo3, foo4, foo5
  $0 3 test       # Creează test1, test2, test3
EOF
}

display_summary() {
    echo
    print_info "======================================"
    print_info "Creare containere completă!"
    print_info "======================================"
    echo

    print_info "Containere create:"
    for i in $(seq 1 "$NUM_NODES"); do
        CONTAINER_NAME="${NAME_PREFIX}${i}"

        if ! lxc list | grep -q "^| $CONTAINER_NAME "; then
            continue
        fi

        IP=$(get_container_ip "$CONTAINER_NAME")
        printf "  %-15s %s\n" "$CONTAINER_NAME" "$IP"
    done

    echo
    print_info "Acum poți folosi SSH pentru a te conecta la containere:"
    print_info "  ssh student@${NAME_PREFIX}1"
    print_info "  Parolă: student"
    echo
    print_info "Pașii următori:"
    print_info "  Rulează setup-ssh-access.sh ${NAME_PREFIX}[1-${NUM_NODES}] pentru SSH fără parolă"
}

main() {
    validate_arguments "$@"
    check_root
    check_base_container
    create_containers
    configure_and_start_containers
    wait_for_network
    update_hosts_file
    display_summary
}

if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    print_usage
    exit 0
fi

main "$@"
