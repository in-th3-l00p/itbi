expand_nodes() {
    local input=$1
    if [[ $input =~ (.*)\[([0-9]+)-([0-9]+)\] ]]; then
        local prefix="${BASH_REMATCH[1]}"
        local start="${BASH_REMATCH[2]}"
        local end="${BASH_REMATCH[3]}"
        for ((i=start; i<=end; i++)); do
            echo "${prefix}${i}"
        done
    else
        echo "$input"
    fi
}
