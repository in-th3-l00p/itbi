#!/bin/bash

get_matching_containers() {
    local pattern="$1"
    local all_containers=$(lxc list -c n --format csv)
    local regex_pattern="${pattern//\*/.*}"

    MATCHING_CONTAINERS=()

    for container in $all_containers; do
        if [[ "$container" =~ $regex_pattern ]]; then
            MATCHING_CONTAINERS+=("$container")
        fi
    done
}

get_container_ip() {
    local container="$1"
    lxc list "$container" -c 4 --format csv | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | head -n1
}
