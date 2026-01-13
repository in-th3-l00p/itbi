#!/bin/bash
source ./shared/config.sh
source ./shared/parser.sh

nodes=()
exclude=()

while getopts "w:x:" opt; do
  case $opt in
    w) while read -r n; do nodes+=("$n"); done < <(expand_nodes "$OPTARG") ;;
    x) while read -r n; do exclude+=("$n"); done < <(expand_nodes "$OPTARG") ;;
  esac
done
shift $((OPTIND-1))

src=$1
dest=$2

for node in "${nodes[@]}"; do
    [[ " ${exclude[*]} " =~ " ${node} " ]] && continue
    scp -r "$src" "${SSH_USER}@${node}:${dest}" & 
done
wait
