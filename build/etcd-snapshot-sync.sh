#!/bin/bash

SOURCE_DIR=${1}
TARGET_DIR=${2} 

echo "--- Runtime ---"
echo "SOURCE_DIR=${SOURCE_HOST}"
echo "TARGET_DIR=${TARGET_DIR}"
echo "RSYNC=$(which rsync)"
echo "WHOAMI=$(whoami)"
echo "---------------"

echo "Copying from ${SOURCE_DIR} to ${TARGET_DIR}"
rsync --archive --delete --verbose --human-readable \
    --chown $(stat -c "%u" /target-dir):$(stat -c "%g" /target-dir) \
    /source-dir/ /target-dir/