#!/bin/bash

generate_ssh_keys() {
    if [[ -n "$SUDO_USER" ]]; then
        USER_HOME=$(eval echo ~$SUDO_USER)
        SSH_KEY_PATH="$USER_HOME/.ssh/id_rsa"
    fi

    print_info "Verificare chei SSH la $SSH_KEY_PATH..."

    if [[ -f "$SSH_KEY_PATH" ]]; then
        print_info "Cheile SSH există deja la $SSH_KEY_PATH"
        return 0
    fi

    print_info "Generare pereche de chei SSH..."

    mkdir -p "$(dirname $SSH_KEY_PATH)"

    if [[ -n "$SUDO_USER" ]]; then
        sudo -u "$SUDO_USER" ssh-keygen -t rsa -b 4096 -f "$SSH_KEY_PATH" -N "" -C "$SUDO_USER@lxd-test"
    else
        ssh-keygen -t rsa -b 4096 -f "$SSH_KEY_PATH" -N "" -C "$(whoami)@lxd-test"
    fi

    print_info "Chei SSH generate cu succes"
}
