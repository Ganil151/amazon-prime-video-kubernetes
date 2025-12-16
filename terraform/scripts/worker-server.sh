#!/bin/bash

set -e

NEW_HOSTNAME="Worker-Server"
echo "Setting Host Name to: ${NEW_HOSTNAME}"
sudo hostnamectl set-hostname "${NEW_HOSTNAME}"

echo "Updating package list..."
sudo apt-get update -y

echo "Installing Docker..."
sudo apt-get install docker.io -y

sudo usermod -aG docker ubuntu



sudo chmod 660 /var/run/docker.sock
sudo chown root:docker /var/run/docker.sock

sudo systemctl restart docker

docker --version

# --- 2. Java and Maven Configuration ---

echo "--- 2. Java and Maven Configuration ---"
# Install Maven
if ! command -v mvn &> /dev/null; then
    echo "Maven is not installed. Installing Maven..."
    sudo apt-get install -y maven
fi

# Set JAVA_HOME for OpenJDK 21 on Ubuntu (amd64)
# Path is standard for 'openjdk-21-jdk' package on Ubuntu
JAVA_HOME="/usr/lib/jvm/java-21-openjdk-amd64"

# Maven is typically installed to /usr/share/maven on Ubuntu as well
M2_HOME="/usr/share/maven"
# Verify Maven installation path
if [ ! -d "$M2_HOME" ]; then
    echo "WARNING: Could not confirm standard M2_HOME directory ($M2_HOME). Skipping M2_HOME export."
    M2_HOME="" 
fi

# Configure environment variables for the current user's profile
echo "Configuring environment variables (JAVA_HOME, M2_HOME) for current user..."
# Note: This block echoes the exports. To make them persistent, 
# you should redirect this output to ~/.bashrc or /etc/profile.d/env.sh
{
    echo "export JAVA_HOME=${JAVA_HOME}"
    if [ -n "$M2_HOME" ]; then
        echo "export M2_HOME=${M2_HOME}"
    fi
    echo "export PATH=\$PATH:\$HOME/bin:\$JAVA_HOME/bin"
    if [ -n "$M2_HOME" ]; then
        echo "export PATH=\$PATH:\$M2_HOME/bin"
    fi
} >> /etc/profile.d/java_maven.sh # I'll make this useful by writing to a system-wide profile file

# Apply the changes to the current session (best effort for script execution)
source /etc/profile.d/java_maven.sh

# --- 3. Kubectl Configuration ---
echo "--- 3. Kubectl Configuration ---"
# Update package list again to be sure
sudo apt update -y

# Install curl
sudo apt install curl -y

# Download the latest stable kubectl binary
curl -LO https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl

# Install kubectl
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl

# --- 4. Eksctl Configuration ---
echo "--- 4. Eksctl Configuration ---"
# Download and extract the latest eksctl binary
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp

# Move eksctl to /usr/local/bin to make it executable from anywhere
sudo mv /tmp/eksctl /usr/local/bin

# Verify installation
echo "Verifying kubectl and eksctl installation..."
kubectl version --client
eksctl version

# --- 5. Trivy Configuration ---
echo "--- 5. Trivy Configuration ---"
# Install necessary dependencies
sudo apt-get install wget apt-transport-https gnupg lsb-release -y

# Add the Trivy repository key
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null

# Add the Trivy repository to the sources list
echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list

# Update package lists
sudo apt-get update -y

# Install Trivy
sudo apt-get install trivy -y
