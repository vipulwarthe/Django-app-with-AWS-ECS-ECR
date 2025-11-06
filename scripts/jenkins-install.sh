#!/bin/bash

set -e

echo "=============================================="
echo " Jenkins Installation Script (Java 21)"
echo "=============================================="

# Update System
echo "[1/6] Updating system..."
sudo apt-get update -y
sudo apt-get upgrade -y

# Install Java 21 (OpenJDK)
echo "[2/6] Installing OpenJDK 21..."
sudo apt-get install -y openjdk-21-jre

# Verify Java installation
echo "✅ Java Installed:"
java -version

# Add Jenkins Repository Key
echo "[3/6] Adding Jenkins repo key..."
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null

# Add Jenkins repo
echo "[4/6] Adding Jenkins repository..."
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

# Install Jenkins
echo "[5/6] Installing Jenkins..."
sudo apt-get update -y
sudo apt-get install -y jenkins

# Start & Enable Jenkins
echo "[6/6] Starting and enabling Jenkins..."
sudo systemctl start jenkins
sudo systemctl enable jenkins

echo "=============================================="
echo " ✅ Jenkins Installed Successfully (Java 21)"
echo "=============================================="

echo ""
echo "🔑 Jenkins Initial Admin Password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword

echo ""
echo "✅ Open Jenkins in browser:"
IP=$(curl -s ifconfig.me)
echo "👉 http://$IP:8080"
echo ""
echo "Login using the above password."
