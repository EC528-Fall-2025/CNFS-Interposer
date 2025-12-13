#!/bin/bash

# --- 1. Read the mount parameters from environment variables ---
NFS_SOURCE=${NFS_SOURCE}
NFS_TARGET=${NFS_TARGET_PATH}
#MOUNT_OPTS=${MOUNT_OPTS}
MOUNT_OPTS=nolock

if [ -z "$NFS_SOURCE" ] || [ -z "$NFS_TARGET" ]; then
    echo "ERROR: Missing required NFS_SOURCE or NFS_TARGET environment variable." >&2
    exit 1
fi

# --- 2. Create the target directory (crucial for mount to succeed) ---
mkdir -p "${NFS_TARGET}"

# --- 3. Execute the mount command ---
echo "Attempting to mount NFS ${NFS_SOURCE} to ${NFS_TARGET} with options ${MOUNT_OPTS}"

# Note: The 'mount' command needs to be installed in the Kata container image.
mount -t nfs -o "${MOUNT_OPTS}" "${NFS_SOURCE}" "${NFS_TARGET}"

if [ $? -ne 0 ]; then
    echo "ERROR: NFS mount failed." >&2
    exit 1
fi

echo "NFS mount successful. Worker process sleeping indefinitely."

# --- 4. Keep the container alive ---
# Since this is a dedicated worker, it must not exit immediately after mounting.
# The container lives as long as the volume is published.
exec sleep infinity
