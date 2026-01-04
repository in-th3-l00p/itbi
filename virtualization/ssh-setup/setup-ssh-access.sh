#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHARED_DIR="$SCRIPT_DIR/../shared"

source "$SHARED_DIR/config.sh"
source "$SHARED_DIR/output.sh"
source "$SCRIPT_DIR/validation.sh"
source "$SCRIPT_DIR/prerequisites.sh"
source "$SCRIPT_DIR/keys.sh"
source "$SCRIPT_DIR/containers.sh"
source "$SCRIPT_DIR/distribution.sh"

SSH_KEY_PATH="$HOME/.ssh/id_rsa"
CURRENT_USER=$(logname 2>/dev/null || echo $SUDO_USER)

LXC_CMD="lxc"
if ! lxc list &>/dev/null; then
    if sudo lxc list &>/dev/null; then
        LXC_CMD="sudo lxc"
    fi
fi

print_usage() {
    cat << EOF
Utilizare: $0 <pattern>

Configurează acces SSH fără parolă la containerele LXD prin distribuirea
cheilor SSH publice.

Argumente:
  pattern  Pattern pentru potrivirea numelor de containere (ex: "foo*" sau "foo[1-5]")

Exemple:
  $0 "foo*"        # Configurare SSH pentru toate containerele care încep cu "foo"
  $0 "foo[1-5]"    # Configurare SSH pentru foo1, foo2, foo3, foo4, foo5
  $0 "test*"       # Configurare SSH pentru toate containerele care încep cu "test"

Notă: Pattern-ul trebuie pus între ghilimele pentru a preveni expansiunea shell.
EOF
}

main() {
    validate_arguments "$@"
    check_prerequisites
    generate_ssh_keys
    get_matching_containers
    distribute_ssh_keys
    test_ssh_access
    display_summary
}

if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    print_usage
    exit 0
fi

main "$@"
