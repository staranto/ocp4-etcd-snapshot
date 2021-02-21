#!/bin/bash

SNAPSHOT_HOST=${1}
SNAPSHOT_DIR=${3:-/var/home/core/etcd-snapshots}
NFS_TGT=${2}
NFS_MP=${4:-/var/home/core/mnt/etcd-snapshots}
THIS_HOST=$(hostname)

echo "--- Runtime ---"
echo "SNAPSHOT_HOST=${SNAPSHOT_HOST}"
echo "SNAPSHOT_DIR=${SNAPSHOT_DIR}"
echo "NFS_TGT=${NFS_TGT}"
echo "NFS_MP=${NFS_MP}"
echo "WHOAMI=$(whoami)"
env | sort
echo "---------------"

shopt -s nocasematch
if [[ "${SNAPSHOT_HOST}" != "${THIS_HOST}" ]]; then
    echo "This node (${THIS_HOST}) is not the etcd-snapshot target node (${SNAPSHOT_HOST})." 
    exit 0
fi

set -x

mkdir -p ${NFS_MP}

echo "--- Pre-mount state ---"
ls -lta ${NFS_MP}

mount -t nfs ${NFS_TGT} ${NFS_MP}

echo "--- Post-mount state ---"
ls -lta ${NFS_MP}

rsync --archive --delete --human-readable --no-group --no-owner --verbose \
    ${SNAPSHOT_DIR}/ ${NFS_MP}

umount ${NFS_MP}