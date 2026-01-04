#!/bin/bash

create_containers() {
    print_info "Creare $NUM_NODES containere cu prefixul '$NAME_PREFIX'..."
    echo

    for i in $(seq 1 "$NUM_NODES"); do
        CONTAINER_NAME="${NAME_PREFIX}${i}"

        if lxc list | grep -q "^| $CONTAINER_NAME "; then
            print_warn "Containerul '$CONTAINER_NAME' există deja, se omite..."
            continue
        fi

        print_info "[$i/$NUM_NODES] Copiere container '$CONTAINER_NAME'..."
        lxc copy "$BASE_CONTAINER" "$CONTAINER_NAME"
    done

    echo
    print_info "Toate containerele au fost copiate cu succes"
}

configure_and_start_containers() {
    print_info "Configurare și pornire containere..."
    echo

    for i in $(seq 1 "$NUM_NODES"); do
        CONTAINER_NAME="${NAME_PREFIX}${i}"

        if ! lxc list | grep -q "^| $CONTAINER_NAME "; then
            continue
        fi

        print_info "[$i/$NUM_NODES] Pornire container '$CONTAINER_NAME'..."
        lxc start "$CONTAINER_NAME" 2>/dev/null || print_warn "Containerul rulează deja"

        sleep 2

        print_info "[$i/$NUM_NODES] Setare hostname pentru '$CONTAINER_NAME'..."
        lxc exec "$CONTAINER_NAME" -- bash -c "echo '$CONTAINER_NAME' > /etc/hostname"
        lxc exec "$CONTAINER_NAME" -- hostname "$CONTAINER_NAME"

        lxc exec "$CONTAINER_NAME" -- bash -c "sed -i 's/127.0.1.1.*/127.0.1.1\t$CONTAINER_NAME/' /etc/hosts"
    done

    echo
    print_info "Toate containerele au fost pornite și configurate"
}
