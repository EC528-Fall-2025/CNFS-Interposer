# Start from a stable, lightweight Ubuntu base image
FROM ubuntu:24.04

# Set environment variables to non-interactive mode
ENV DEBIAN_FRONTEND=noninteractive

# Update the package lists, install the desired utilities, and clean up.
# This single RUN command ensures all layers are combined, minimizing image size.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        nfs-common \
        iputils-ping \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY ./virtiofsd /usr/bin/virtiofsd
RUN chmod +x /usr/bin/virtiofsd

RUN mkdir -p /mnt/nfs
COPY mount-worker.sh /mount-worker.sh
# --- ADDED: Make the script executable ---
RUN chmod +x /mount-worker.sh					

# Set the entrypoint to a command that keeps the container running, 
# typically /bin/bash for debugging or /bin/true for simple background tasks.
ENTRYPOINT ["/bin/bash"]
#ENTRYPOINT ["/mount-worker.sh"]
