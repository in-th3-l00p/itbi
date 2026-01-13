#!/bin/bash
source ./shared/config.sh
source ./shared/parser.sh

nodes=()
while getopts "w:" opt; do
  case $opt in
    w) while read -r n; do nodes+=("$n"); done < <(expand_nodes "$OPTARG") ;;
  esac
done
shift $((OPTIND-1))

command=$1

for node in "${nodes[@]}"; do
    final_cmd=$(echo "$command" | sed "s/%u/${SSH_USER}/g; s/%h/${node}/g")
    ssh "${SSH_USER}@${node}" "$final_cmd" &
done
wait
