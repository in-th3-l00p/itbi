#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHARED_DIR="$SCRIPT_DIR/../shared"

source "$SHARED_DIR/config.sh"
source "$SHARED_DIR/output.sh"
source "$SHARED_DIR/checks.sh"
source "$SCRIPT_DIR/validation.sh"
source "$SCRIPT_DIR/containers.sh"
source "$SCRIPT_DIR/cleanup.sh"

print_usage() {
    cat << EOF
Utilizare: $0 <pattern>

Oprește și șterge containerele LXD care se potrivesc cu un pattern și înlătură
intrările lor din /etc/hosts.

Argumente:
  pattern  Pattern pentru potrivirea numelor de containere (ex: "foo*" sau "test*")

Exemple:
  $0 "foo*"      # Șterge toate containerele care încep cu "foo"
  $0 "test*"     # Șterge toate containerele care încep cu "test"
  $0 "node*"     # Șterge toate containerele care încep cu "node"

Notă:
  - Pattern-ul trebuie pus între ghilimele pentru a preveni expansiunea shell
  - Containerul de bază (base-ubuntu) este protejat și nu va fi șters
  - Vei fi solicitat să confirmi înainte de ștergere

ATENȚIE: Această operațiune nu poate fi anulată!
EOF
}

main() {
    validate_arguments "$@"
    check_root
    get_matching_containers
    confirm_deletion
    stop_containers
    delete_containers
    cleanup_hosts_file
    cleanup_ssh_known_hosts
    display_summary
}

if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]] || [[ $# -eq 0 ]]; then
    print_usage
    exit 0
fi

main "$@"
