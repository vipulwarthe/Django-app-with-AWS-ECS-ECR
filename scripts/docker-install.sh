#!/bin/bash
set -e

echo "==============================="
echo " Installing Docker on Ubuntu"
echo "==============================="

# Update system
sudo apt-get update -y
sudo apt-get upgrade -y

echo "[1/6] Removing older Docker versions..."
sudo apt-get remove -y docker docker-engine docker.io containerd runc || true

echo "[2/6] Installing dependencies..."
sudo apt-get install -y ca-certificates curl gnupg lsb-release apt-transport-https software-properties-common

echo "[3/6] Adding Docker GPG key..."
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo "[4/6] Adding Docker repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "[5/6] Installing Docker Engine..."
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "✅ Docker installed successfully!"

echo "[6/6] Starting and enabling Docker..."
sudo systemctl start docker
sudo systemctl enable docker

echo "✅ Docker service started & enabled"

echo "Adding current user to docker group..."
sudo usermod -aG docker $USER
sudo chown $USER /var/run/docker.sock

echo "✅ User added to docker group"
echo "⚠️ Logout & login again to use Docker without sudo"

echo "============ DONE ============"
docker --version
docker compose version || true
