#!/bin/sh
set -e  # Exit on any command failure

IMAGE_NAME="blendfarm"
INSTANCES=${1:-1}  # Default to 1 instance if no parameter is provided

START_PORT=15000

# Function to check if port is free
is_port_free() {
    PORT=$1
    # Check if port is in use on the host (ss preferred, fallback to lsof)
    if ss -tuln | grep -q ":$PORT "; then
        return 1
    elif lsof -iTCP:"$PORT" -sTCP:LISTEN >/dev/null 2>&1; then
        return 1
    fi
    # Check if any Docker container is using it
    if docker ps --format '{{.Ports}}' | grep -q "$PORT->"; then
        return 1
    fi
    return 0
}

# Function to find next free port
find_free_port() {
    PORT=$START_PORT
    while true; do
        if is_port_free "$PORT"; then
            echo "$PORT"
            return
        fi
        PORT=$((PORT + 1))
    done
}

for i in $(seq 1 "$INSTANCES"); do
    PORT=$(find_free_port)

    CONTAINER_NAME="${IMAGE_NAME}_$(date +%s)_$i"

    echo "Starting container '$CONTAINER_NAME' on port $PORT..."

    docker run --gpus=all --shm-size=1g -p "$PORT":15000 --name "$CONTAINER_NAME" -d "$IMAGE_NAME"

    sleep 2  # Give Docker time to bind port properly

    START_PORT=$((PORT + 1))
done
