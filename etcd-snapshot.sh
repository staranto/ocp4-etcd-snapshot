#!/bin/bash

SNAPSHOT_HOST=${1}
SNAPSHOT_DIR=/tmp/${2:-etcd-snapshots}
SNAPSHOT_DAYS=${3:-7}
THIS_HOST=$(hostname -s)

shopt -s nocasematch
if [[ "${SNAPSHOT_HOST}" != "${THIS_HOST}" ]]; then
    echo "This host (${THIS_HOST}) is not the etcd-snapshot target (${SNAPSHOT_HOST})." 
    exit 0
fi

mkdir -p ${SNAPSHOT_DIR}

/usr/local/bin/cluster-backup.sh ${SNAPSHOT_DIR}

find ${SNAPSHOT_DIR} -type f -mtime +${SNAPSHOT_DAYS} -exec rm -f {} \;
