#!/bin/bash

SNAPSHOT_DIR=/home/core/etcd-snapshots
SNAPSHOT_DAYS=0
THIS_HOST=$(hostname)
VALID_DIRS="/home/core /var/home/core /tmp"

while [[ $# -gt 0 ]]; do
    k="$1"
    case $k in
        -f|--force)
            SNAPSHOT_FORCE="--force"
            shift
            ;;
        -h|--host)
            SNAPSHOT_HOST="$2"
            shift
            shift
            ;;
        -o|--output)
            SNAPSHOT_DIR="$2"
            shift
            shift
            ;;          
        -p|--purge)
            SNAPSHOT_DAYS="$2"
            shift
            shift
            ;;
        *)
            echo "Unknown argument: $0 $*"
            exit 1
    esac
done

echo "--- Runtime ---"
echo "Command Line=$0 $*"
echo "SNAPSHOT_HOST=${SNAPSHOT_HOST}"
echo "SNAPSHOT_DIR=${SNAPSHOT_DIR}"
echo "SNAPSHOT_DAYS=${SNAPSHOT_DAYS}"
echo "SNAPSHOT_FORCE=${SNAPSHOT_FORCE}"
echo "---------------"

set -x

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

/usr/local/bin/cluster-backup.sh ${SNAPSHOT_FORCE} ${SNAPSHOT_DIR}

chown -R core:core ${SNAPSHOT_DIR}

sleep 1

if [[ "${SNAPSHOT_DAYS}" == "0" ]]; then
    echo "Skipping snapshot purge."
    exit 0
fi

echo "--- Pre-purge state ---"
ls -l ${SNAPSHOT_DIR}

echo "--- Purging stale snapshots ---"
find ${SNAPSHOT_DIR} -type f -mtime ${SNAPSHOT_DAYS} -print -delete

echo "--- Post-purge state ---"
ls -l ${SNAPSHOT_DIR}

