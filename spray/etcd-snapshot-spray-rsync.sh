#!/bin/bash

SNAPSHOT_HOST=${1}
SNAPSHOT_DIR=${2:-/var/home/core/etcd-snapshots}
THIS_HOST=$(hostname)

echo "--- Runtime ---"
echo "SNAPSHOT_HOST=${SNAPSHOT_HOST}"
echo "SNAPSHOT_DIR=${SNAPSHOT_DIR}"
echo "RSYNC=$(which rsync)"
echo "SSH=$(which ssh)"
echo "WHOAMI=$(whoami)"
env | sort
echo "---------------"

shopt -s nocasematch
if [[ "${SNAPSHOT_HOST}" != "${THIS_HOST}" ]]; then
    echo "This node (${THIS_HOST}) is not the etcd-snapshot target node (${SNAPSHOT_HOST})." 
    exit 0
fi

etcdenv="/etc/kubernetes/static-pod-resources/etcd-certs/configmaps/etcd-scripts/etcd.env"
if [ ! -f "${etcdenv}" ]; then
    echo "Required env dependencies not found (${etcdenv})"
    exit 1
fi
source "${etcdenv}"

set -x

nodes=$(compgen -A variable | grep ETCD_NAME)
for node in $nodes; do
    shopt -s nocasematch
    if [[ "${SNAPSHOT_HOST}" == "${!node}" ]]; then
        echo "Skipping candidate node (${!node}) since it's the etcd-snapshot-spray source node (${SNAPSHOT_HOST})." 
        continue
    fi

    echo "Copying from ${SNAPSHOT_HOST} to ${!node}"
    rsync --archive --delete --verbose --human-readable \
        --rsh 'ssh -l core -i /var/home/core/.ssh/id_rsa' \
        ${SNAPSHOT_DIR}/ \
        core@${!node}:${SNAPSHOT_DIR}/
done
