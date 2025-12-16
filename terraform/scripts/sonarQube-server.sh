#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Set Host Name
NEW_HOSTNAME="SonarQube-Server"
echo "Setting Host Name to: ${NEW_HOSTNAME}"
sudo hostnamectl set-hostname "${NEW_HOSTNAME}"

# Function for error handling
handle_error() {
    echo "Error on line $1"
    exit 1
}

# Trap error signals and call handle_error with the line number
trap 'handle_error $LINENO' ERR

# Update the package list
echo "Updating package list..."
sudo apt-get update -y

# Install Docker
echo "Installing Docker..."
sudo apt-get install docker.io -y

# Add the 'ubuntu' user to the 'docker' group
echo "Adding 'ubuntu' user to docker group..."
sudo usermod -aG docker ubuntu

# Add the 'jenkins' user to the 'docker' group if it exists
if id "jenkins" &>/dev/null; then
    echo "Adding 'jenkins' user to docker group..."
    sudo usermod -aG docker jenkins
else
    echo "User 'jenkins' does not exist. Skipping addition to docker group."
fi

# Note: 'newgrp docker' is removed because it starts a new shell session,
# which can interrupt script execution in non-interactive environments.
# Group changes take effect on next login.

# Set correct permissions for the Docker socket
echo "Configuring Docker socket permissions..."
sudo chmod 660 /var/run/docker.sock
sudo chown root:docker /var/run/docker.sock

# Restart Docker service to apply changes
echo "Restarting Docker service..."
sudo systemctl restart docker

# Verify installation
docker --version

# Run SonarQube container in detached mode with port mapping
# Uncomment the following line to start SonarQube automatically
# docker run -d --name sonar -p 9000:9000 sonarqube:lts-community
