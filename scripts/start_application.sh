#!/bin/bash
set -e

echo "=== ApplicationStart: Starting Docker container ==="

# Read environment variables (IMDSv2)
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
REGION=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/region)
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
IMAGE_REPO_NAME="chat-app"
REPOSITORY_URI="$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$IMAGE_REPO_NAME"

# Run the container
docker run -d \
    --name classroom-chat \
    --restart unless-stopped \
    -p 3000:3000 \
    $REPOSITORY_URI:latest

# Verify container is running
sleep 3
if docker ps --filter "name=classroom-chat" --filter "status=running" | grep -q classroom-chat; then
    echo "Container is running successfully!"
    docker ps --filter "name=classroom-chat"
else
    echo "ERROR: Container failed to start"
    docker logs classroom-chat
    exit 1
fi

echo "=== ApplicationStart complete ==="
