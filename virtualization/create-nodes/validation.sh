#!/bin/bash

validate_arguments() {
    if [[ $# -ne 2 ]]; then
        print_error "Număr invalid de argumente"
        print_usage
        exit 1
    fi

    NUM_NODES="$1"
    NAME_PREFIX="$2"

    if ! [[ "$NUM_NODES" =~ ^[0-9]+$ ]] || [[ "$NUM_NODES" -le 0 ]]; then
        print_error "Numărul de noduri trebuie să fie un întreg pozitiv"
        exit 1
    fi

    if ! [[ "$NAME_PREFIX" =~ ^[a-zA-Z0-9-]+$ ]]; then
        print_error "Prefixul numelui trebuie să conțină doar caractere alfanumerice și cratime"
        exit 1
    fi
}
