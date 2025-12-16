#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Function for error handling
handle_error() {
    echo "Error on line $1"
    exit 1
}

# Trap error signals and call handle_error with the line number
trap 'handle_error $LINENO' ERR

# --- 1. System Setup and Dependencies ---

echo "--- 1. System Setup ---"
# Set Host Name
NEW_HOSTNAME="App-Server"
echo "Setting Host Name to: ${NEW_HOSTNAME}"
sudo hostnamectl set-hostname "${NEW_HOSTNAME}"

# Install core dependencies and update system
echo "Installing core dependencies and updating system..."
# Ubuntu uses apt-get. We also update the package list first.
sudo apt-get update -y
sudo apt-get upgrade -y
# 'software-properties-common' is roughly equivalent to 'yum-utils'
# 'openjdk-21-jdk' replaces 'java-21-amazon-corretto-devel'
sudo apt-get install -y openjdk-21-jdk git wget software-properties-common lvm2

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

# --- 3. Jenkins Installation ---

echo "--- 3. Jenkins Installation ---"
echo "Updating package index..."
sudo apt update -y

echo "Installing Jenkins dependencies (fontconfig)..."
sudo apt install fontconfig -y

echo "Adding Jenkins repository key..."
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key

echo "Adding Jenkins repository..."
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

echo "Updating package index for Jenkins..."
sudo apt-get update -y

echo "Installing Jenkins..."
sudo apt-get install jenkins -y

echo "Enabling and starting Jenkins service..."
sudo systemctl enable jenkins
sudo systemctl start jenkins


# --- 4. Git Clone and Build ---
echo "--- 4. Git Clone and Build ---"
# Clone the repository
git clone https://github.com/Ganil151/amazon-prime-video-kubernetes.git
