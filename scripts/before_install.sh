#!/bin/bash
set -e

echo "=== BeforeInstall: Setting up environment ==="

# Install Docker if not already installed
if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    yum update -y
    yum install -y docker
    systemctl start docker
    systemctl enable docker
    usermod -aG docker ec2-user
fi

# Start Docker service if not running
if ! systemctl is-active --quiet docker; then
    systemctl start docker
fi

# Install AWS CLI v2 if not present
if ! command -v aws &> /dev/null; then
    echo "Installing AWS CLI..."
    yum install -y unzip
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip -o awscliv2.zip
    ./aws/install --update
    rm -rf awscliv2.zip aws
fi

# Clean up old app directory
if [ -d /home/ec2-user/app ]; then
    rm -rf /home/ec2-user/app
fi

mkdir -p /home/ec2-user/app

echo "=== BeforeInstall complete ==="
