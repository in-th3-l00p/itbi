#!/bin/bash

get_matching_containers() {
    print_info "Căutare containere care se potrivesc cu pattern-ul '$PATTERN'..."

    local all_containers=$($LXC_CMD list -c n --format csv)
    local regex_pattern="${PATTERN//\*/.*}"

    MATCHING_CONTAINERS=()

    for container in $all_containers; do
        if [[ "$container" =~ $regex_pattern ]]; then
            if $LXC_CMD list "$container" -c s --format csv | grep -q "RUNNING"; then
                MATCHING_CONTAINERS+=("$container")
            else
                print_warn "Containerul '$container' nu rulează, se omite..."
            fi
        fi
    done

    if [[ ${#MATCHING_CONTAINERS[@]} -eq 0 ]]; then
        print_error "Nu s-au găsit containere care rulează și se potrivesc cu pattern-ul '$PATTERN'"
        exit 1
    fi

    print_info "S-au găsit ${#MATCHING_CONTAINERS[@]} container(e) potrivite:"
    for container in "${MATCHING_CONTAINERS[@]}"; do
        echo "  - $container"
    done
    echo
}
