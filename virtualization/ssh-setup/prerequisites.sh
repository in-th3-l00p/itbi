#!/bin/bash

check_prerequisites() {
    print_info "Verificare prerequisite..."

    if ! command -v sshpass &> /dev/null; then
        print_info "Instalare sshpass..."
        if [[ $EUID -eq 0 ]]; then
            apt-get update && apt-get install -y sshpass
        else
            sudo apt-get update && sudo apt-get install -y sshpass
        fi
    fi

    if ! command -v expect &> /dev/null; then
        print_info "Instalare expect..."
        if [[ $EUID -eq 0 ]]; then
            apt-get update && apt-get install -y expect
        else
            sudo apt-get update && sudo apt-get install -y expect
        fi
    fi
}
