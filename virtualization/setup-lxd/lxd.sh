#!/bin/bash

install_lxd() {
    print_info "Verificare instalare LXD..."

    if command -v lxd &> /dev/null; then
        print_info "LXD este deja instalat"
        return 0
    fi

    print_info "Instalare LXD prin snap..."
    snap install lxd

    if [[ -n "$SUDO_USER" ]]; then
        usermod -aG lxd "$SUDO_USER"
        print_info "Utilizatorul $SUDO_USER a fost adăugat la grupul lxd"
    fi

    print_info "LXD instalat cu succes"
}

initialize_lxd() {
    print_info "Verificare status inițializare LXD..."

    if lxc network list 2>/dev/null | grep -q lxdbr0; then
        print_info "LXD este deja inițializat"
        return 0
    fi

    print_info "Inițializare LXD cu configurare personalizată de rețea..."
    print_info "Se folosește subrețeaua $NETWORK_SUBNET pentru rețeaua bridge LXD..."

    cat <<EOF | lxd init --preseed
config: {}
networks:
- name: lxdbr0
  type: bridge
  config:
    ipv4.address: $NETWORK_ADDRESS
    ipv4.nat: "true"
    ipv6.address: none
storage_pools:
- name: default
  driver: dir
profiles:
- name: default
  devices:
    eth0:
      name: eth0
      network: lxdbr0
      type: nic
    root:
      path: /
      pool: default
      type: disk
EOF

    print_info "LXD inițializat cu succes cu rețeaua $NETWORK_SUBNET"
}
