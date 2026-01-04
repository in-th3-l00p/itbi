#!/bin/bash

wait_for_network() {
    print_info "Se așteaptă ca rețeaua să fie gata pe toate containerele..."
    echo

    for i in $(seq 1 "$NUM_NODES"); do
        CONTAINER_NAME="${NAME_PREFIX}${i}"

        if ! lxc list | grep -q "^| $CONTAINER_NAME "; then
            continue
        fi

        print_info "[$i/$NUM_NODES] Se așteaptă rețeaua pe '$CONTAINER_NAME'..."

        for attempt in {1..30}; do
            IP=$(get_container_ip "$CONTAINER_NAME")
            if [[ -n "$IP" ]]; then
                print_info "[$i/$NUM_NODES] Containerul '$CONTAINER_NAME' a primit IP: $IP"
                break
            fi
            sleep 1
        done

        if [[ -z "$IP" ]]; then
            print_warn "[$i/$NUM_NODES] Nu s-a putut obține IP pentru '$CONTAINER_NAME'"
        fi
    done

    echo
    print_info "Configurare rețea completă"
}

update_hosts_file() {
    print_info "Actualizare $HOSTS_FILE cu adresele IP ale containerelor..."

    sed -i "/^.*${NAME_PREFIX}[0-9]*.*${HOSTS_MARKER}/d" "$HOSTS_FILE"

    for i in $(seq 1 "$NUM_NODES"); do
        CONTAINER_NAME="${NAME_PREFIX}${i}"

        if ! lxc list | grep -q "^| $CONTAINER_NAME "; then
            continue
        fi

        IP=$(get_container_ip "$CONTAINER_NAME")

        if [[ -n "$IP" ]]; then
            echo "$IP $CONTAINER_NAME  $HOSTS_MARKER" >> "$HOSTS_FILE"
            print_info "Adăugat: $IP -> $CONTAINER_NAME"
        fi
    done

    print_info "/etc/hosts actualizat cu succes"
}
