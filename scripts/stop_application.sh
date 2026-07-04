#!/bin/bash
echo "=== ApplicationStop: Stopping existing container ==="

# Stop and remove existing container if running
if docker ps -q --filter "name=classroom-chat" | grep -q .; then
    echo "Stopping running container..."
    docker stop classroom-chat
    docker rm classroom-chat
elif docker ps -aq --filter "name=classroom-chat" | grep -q .; then
    echo "Removing stopped container..."
    docker rm classroom-chat
fi

echo "=== ApplicationStop complete ==="
