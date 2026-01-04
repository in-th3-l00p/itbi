#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHARED_DIR="$SCRIPT_DIR/../shared"

source "$SHARED_DIR/config.sh"
source "$SHARED_DIR/output.sh"
source "$SHARED_DIR/checks.sh"
source "$SCRIPT_DIR/lxd.sh"
source "$SCRIPT_DIR/container.sh"

print_usage() {
    cat << EOF
Utilizare: $0

Acest script configurează LXD și creează un container Ubuntu 20.04 de bază
configurat cu acces SSH pentru testarea comenzilor shell distribuite.

Nu necesită argumente.
EOF
}

main() {
    print_info "Pornire configurare mediu LXD..."
    echo

    check_root
    check_prerequisites
    install_lxd
    initialize_lxd
    create_base_container
    configure_base_container
    stop_base_container

    echo
    print_info "======================================"
    print_info "Configurare mediu LXD completă!"
    print_info "======================================"
    print_info "Container de bază: $BASE_CONTAINER"
    print_info "Utilizator SSH: $SSH_USER"
    print_info "Parolă SSH: $SSH_PASS"
    echo
    print_info "Pașii următori:"
    print_info "  1. Rulează create-test-nodes.sh pentru a crea containere de test"
    print_info "  2. Rulează setup-ssh-access.sh pentru a activa SSH fără parolă"
}

if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    print_usage
    exit 0
fi

main "$@"
