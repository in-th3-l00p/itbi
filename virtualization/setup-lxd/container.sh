#!/bin/bash

create_base_container() {
    print_info "Verificare existență container de bază '$BASE_CONTAINER'..."

    if lxc list | grep -q "$BASE_CONTAINER"; then
        print_warn "Containerul de bază '$BASE_CONTAINER' există deja"
        read -p "Vrei să îl ștergi și să creezi unul nou? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_info "Oprire și ștergere container existent..."
            lxc stop "$BASE_CONTAINER" --force 2>/dev/null || true
            lxc delete "$BASE_CONTAINER" --force
        else
            print_info "Se păstrează containerul existent"
            return 0
        fi
    fi

    print_info "Creare container de bază din $IMAGE..."
    lxc launch "$IMAGE" "$BASE_CONTAINER"

    print_info "Se așteaptă ca containerul să fie gata..."
    sleep 5

    for i in {1..30}; do
        if lxc exec "$BASE_CONTAINER" -- systemctl is-system-running --wait 2>/dev/null | grep -qE "running|degraded"; then
            break
        fi
        sleep 2
    done

    print_info "Container de bază creat cu succes"
}

configure_base_container() {
    print_info "Configurare container de bază..."

    print_info "Actualizare liste pachete..."
    lxc exec "$BASE_CONTAINER" -- apt-get update

    print_info "Instalare server OpenSSH..."
    lxc exec "$BASE_CONTAINER" -- apt-get install -y openssh-server sudo

    print_info "Creare utilizator '$SSH_USER' cu parolă..."
    lxc exec "$BASE_CONTAINER" -- useradd -m -s /bin/bash "$SSH_USER"
    lxc exec "$BASE_CONTAINER" -- bash -c "echo '$SSH_USER:$SSH_PASS' | chpasswd"

    print_info "Configurare privilegii sudo..."
    lxc exec "$BASE_CONTAINER" -- usermod -aG sudo "$SSH_USER"
    lxc exec "$BASE_CONTAINER" -- bash -c "echo '$SSH_USER ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/$SSH_USER"
    lxc exec "$BASE_CONTAINER" -- chmod 0440 "/etc/sudoers.d/$SSH_USER"

    print_info "Activare și pornire serviciu SSH..."
    lxc exec "$BASE_CONTAINER" -- systemctl enable ssh
    lxc exec "$BASE_CONTAINER" -- systemctl start ssh

    print_info "Configurare SSH pentru autentificare cu parolă..."
    lxc exec "$BASE_CONTAINER" -- bash -c "sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config"
    lxc exec "$BASE_CONTAINER" -- bash -c "sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config"
    lxc exec "$BASE_CONTAINER" -- systemctl restart ssh

    print_info "Container de bază configurat cu succes"
}

stop_base_container() {
    print_info "Oprire container de bază..."
    lxc stop "$BASE_CONTAINER"
    print_info "Container de bază oprit și pregătit pentru clonare"
}
