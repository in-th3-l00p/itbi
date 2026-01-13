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

remote_src=$1
local_dest=$2

for node in "${nodes[@]}"; do
    mkdir -p "${local_dest}/${node}"
    scp -r "${SSH_USER}@${node}:${remote_src}" "${local_dest}/${node}/" &
done
wait
