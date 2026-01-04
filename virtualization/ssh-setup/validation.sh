#!/bin/bash

validate_arguments() {
    if [[ $# -ne 1 ]]; then
        print_error "Număr invalid de argumente"
        print_usage
        exit 1
    fi

    PATTERN="$1"
}
