#!/bin/sh
set -e  # Exit on any command failure

echo "Stopping all running 'blendfarm' containers..."

# Find all container IDs with names starting with 'blendfarm_'
CONTAINER_IDS=$(docker ps --filter "name=blendfarm_" --format "{{.ID}}")

if [ -z "$CONTAINER_IDS" ]; then
    echo "No 'blendfarm' containers are running."
    exit 0
fi

# Stop all matching containers
docker stop $CONTAINER_IDS

echo "All 'blendfarm' containers have been stopped."
