#!/bin/bash

check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "Acest script trebuie rulat ca root (folosește sudo)"
        exit 1
    fi
}

check_prerequisites() {
    print_info "Verificare prerequisite..."

    if [[ ! -f /etc/debian_version ]]; then
        print_error "Acest script este conceput pentru sisteme Ubuntu/Debian"
        exit 1
    fi
}

check_base_container() {
    print_info "Verificare existență container de bază '$BASE_CONTAINER'..."

    if ! lxc list | grep -q "$BASE_CONTAINER"; then
        print_error "Containerul de bază '$BASE_CONTAINER' nu a fost găsit"
        print_error "Rulează mai întâi setup-lxd-environment.sh"
        exit 1
    fi

    if lxc list "$BASE_CONTAINER" -c s | grep -q "RUNNING"; then
        print_warn "Containerul de bază rulează. Se oprește mai întâi..."
        lxc stop "$BASE_CONTAINER"
    fi
}
