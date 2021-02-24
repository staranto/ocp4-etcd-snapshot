#!/bin/bash

SNAPSHOT_HOST=${1}
SNAPSHOT_DIR=${2:-/home/core/etcd-snapshots}
SNAPSHOT_DAYS=${3:-0}
THIS_HOST=$(hostname)
VALID_DIRS="/home/core /var/home/core /tmp"

echo "--- Runtime ---"
echo "SNAPSHOT_HOST=${SNAPSHOT_HOST}"
echo "SNAPSHOT_DIR=${SNAPSHOT_DIR}"
echo "SNAPSHOT_DAYS=${SNAPSHOT_DAYS}"
echo "---------------"

shopt -s nocasematch
if [[ "pod-mode" != "${SNAPSHOT_HOST}" ]] && [[ "${THIS_HOST}" != ${SNAPSHOT_HOST}* ]]; then
    echo "This node (${THIS_HOST}) is not the etcd-snapshot target node (${SNAPSHOT_HOST})." 
    exit 0
fi

valid=0
for h in ${VALID_DIRS}; do
    if  [[ "${SNAPSHOT_DIR}" =~ ^${h}/[a-zA-z0-9_]+.* ]]; then
        valid=1
        break
    fi
done
if [[ "${valid}" == "0"  ]]; then
    echo "${SNAPSHOT_DIR} is not a valid target directory."
    exit 1
fi

mkdir -p ${SNAPSHOT_DIR}

/usr/local/bin/cluster-backup.sh ${SNAPSHOT_DIR}

chown -R core:core ${SNAPSHOT_DIR}

sleep 1

if [[ "${SNAPSHOT_DAYS}" == "0" ]]; then
    echo "Skipping snapshot purge."
    exit 0
fi

echo "--- Pre-purge state ---"
ls -l ${SNAPSHOT_DIR}

echo "--- Purging stale snapshots ---"
find ${SNAPSHOT_DIR} -type f -mtime +${SNAPSHOT_DAYS} -print -delete
