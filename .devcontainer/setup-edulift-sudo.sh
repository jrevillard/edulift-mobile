#!/bin/bash

# EduLift DevContainer Setup Script
# Installs all E2E testing dependencies with root privileges

set -e

echo "🚀 Starting EduLift DevContainer setup..."

# Update package lists
echo "📦 Updating package lists..."
sudo apt-get update

# Install Android development dependencies
echo "🔧 Installing Android development tools..."
sudo apt-get install -y \
    openjdk-17-jdk \
    wget \
    gnupg \
    lsb-release \
    ca-certificates \
    net-tools \
    lsof \
    libgtk-3-dev \
    clang \
    cmake \
    ninja-build \
    mesa-utils \
    chromium \
    libsecret-1-dev \
    lcov

# Set up Java environment
export JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"

# Download and install Android Command Line Tools
echo "📱 Downloading and installing Android Command Line Tools..."
export ANDROID_HOME="/opt/android-sdk"
sudo mkdir -p ${ANDROID_HOME}/cmdline-tools && \
wget -O commandlinetools.zip "https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip" && \
sudo unzip commandlinetools.zip -d ${ANDROID_HOME}/cmdline-tools && \
sudo mv ${ANDROID_HOME}/cmdline-tools/cmdline-tools ${ANDROID_HOME}/cmdline-tools/latest && \
sudo rm commandlinetools.zip

# Accept Android SDK licenses and install components
echo "📱 Accepting Android SDK licenses and installing components..."
export PATH="${PATH}:${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/platform-tools"
yes | sudo ${ANDROID_HOME}/cmdline-tools/latest/bin/sdkmanager --licenses
sudo ${ANDROID_HOME}/cmdline-tools/latest/bin/sdkmanager "platform-tools" "platforms;android-33" "build-tools;33.0.2"

# Clean up package cache
echo "🧹 Cleaning up package cache..."
sudo apt-get autoremove -y
sudo apt-get autoclean

# Set up proper permissions
echo "🔒 Setting up permissions..."
sudo chown -R node:node /workspace
sudo chown -R node:node /home/node
sudo chown -R node:node /opt/android-sdk

# Configure IPv4-first for Docker-outside-of-Docker networking
echo "🌐 Configuring IPv4-first networking for DooD..."
# Set gai.conf to prefer IPv4
echo "precedence ::ffff:0:0/96  100" | sudo tee -a /etc/gai.conf
