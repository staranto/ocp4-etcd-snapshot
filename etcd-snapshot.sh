#!/bin/bash

SNAPSHOT_HOST=${1}
SNAPSHOT_DIR=${2:-/tmp/etcd-snapshots}
THIS_HOST=$(hostname -s)

shopt -s nocasematch
if [[ "${SNAPSHOT_HOST}" != "${THIS_HOST}" ]]; then
    echo "This host (${SNAPSHOT_HOST}) is not the etcd-snapshot target (${THIS_HOST})." 
    exit 0
fi

mkdir -p ${SNAPSHOT_DIR}

/usr/local/bin/cluster-backup.sh ${SNAPSHOT_DIR}


# 1. If we're not the $SNAPSHOT_HOST then stop without error.
# 2. mkdir -p $SNAPSHOT_DIR
# 3. Run cluster_backup.sh


# A cronjob pod does this...
# 4. Find delete stale files
# 5. Copy of new files.
