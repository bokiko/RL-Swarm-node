#!/bin/bash

# Node.js Installation Script
# Created by bokiko - https://github.com/bokiko

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
}

print_header "NODE.JS INSTALLER"

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   print_error "This script should not be run as root. Please run as a regular user."
   exit 1
fi

# Check if Node.js is already installed
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    print_warning "Node.js is already installed: $NODE_VERSION"
    read -p "Do you want to reinstall/update Node.js? (y/N): " -r
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_message "Keeping existing Node.js installation."
        exit 0
    fi
fi

# Detect system architecture and OS
ARCH=$(uname -m)
OS=$(uname -s)

print_message "Detected system: $OS $ARCH"

# Set Node.js version
NODE_VERSION="20.12.2"

case "$ARCH" in
    x86_64)
        ARCH="x64"
        ;;
    aarch64|arm64)
        ARCH="arm64"
        ;;
    armv7l)
        ARCH="armv7l"
        ;;
    *)
        print_error "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

case "$OS" in
    Linux)
        PLATFORM="linux"
        ;;
    Darwin)
        PLATFORM="darwin"
        ;;
    *)
        print_error "Unsupported operating system: $OS"
        exit 1
        ;;
esac

# Create temporary directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

print_message "Downloading Node.js v$NODE_VERSION for $PLATFORM-$ARCH..."

# Download Node.js
NODE_PACKAGE="node-v$NODE_VERSION-$PLATFORM-$ARCH.tar.xz"
DOWNLOAD_URL="https://nodejs.org/dist/v$NODE_VERSION/$NODE_PACKAGE"

if ! curl -f -L -o "$NODE_PACKAGE" "$DOWNLOAD_URL"; then
    print_error "Failed to download Node.js from $DOWNLOAD_URL"
    print_message "Trying alternative installation method..."
    
    # Alternative: Install via package manager
    if command -v apt &> /dev/null; then
        print_message "Installing Node.js via apt..."
        curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
        sudo apt-get install -y nodejs
    elif command -v yum &> /dev/null; then
        print_message "Installing Node.js via yum..."
        curl -fsSL https://rpm.nodesource.com/setup_20.x | sudo bash -
        sudo yum install -y nodejs npm
    else
        print_error "Cannot install Node.js automatically. Please install manually."
        exit 1
    fi
    
    # Verify installation
    if command -v node &> /dev/null && command -v npm &> /dev/null; then
        print_message "Node.js installed successfully via package manager"
        print_message "Node.js version: $(node --version)"
        print_message "npm version: $(npm --version)"
        exit 0
    else
        print_error "Package manager installation failed"
        exit 1
    fi
fi

print_message "Extracting Node.js..."
tar -xf "$NODE_PACKAGE"

# Create installation directory
INSTALL_DIR="$HOME/.nodejs"
print_message "Installing Node.js to $INSTALL_DIR..."

# Remove existing installation
if [ -d "$INSTALL_DIR" ]; then
    rm -rf "$INSTALL_DIR"
fi

# Move Node.js to installation directory
mv "node-v$NODE_VERSION-$PLATFORM-$ARCH" "$INSTALL_DIR"

# Add to PATH
print_message "Configuring PATH..."

# Add to .bashrc
if ! grep -q "nodejs/bin" "$HOME/.bashrc" 2>/dev/null; then
    echo "" >> "$HOME/.bashrc"
    echo "# Node.js" >> "$HOME/.bashrc"
    echo "export PATH=\"\$HOME/.nodejs/bin:\$PATH\"" >> "$HOME/.bashrc"
    print_message "Added Node.js to .bashrc"
fi

# Add to .profile
if ! grep -q "nodejs/bin" "$HOME/.profile" 2>/dev/null; then
    echo "" >> "$HOME/.profile"
    echo "# Node.js" >> "$HOME/.profile"
    echo "export PATH=\"\$HOME/.nodejs/bin:\$PATH\"" >> "$HOME/.profile"
    print_message "Added Node.js to .profile"
fi

# Add to current session
export PATH="$HOME/.nodejs/bin:$PATH"

# Clean up
cd "$HOME"
rm -rf "$TEMP_DIR"

# Verify installation
print_header "VERIFYING INSTALLATION"

if command -v node &> /dev/null; then
    NODE_VER=$(node --version)
    print_message "✓ Node.js installed successfully: $NODE_VER"
else
    print_error "✗ Node.js installation failed"
    exit 1
fi

if command -v npm &> /dev/null; then
    NPM_VER=$(npm --version)
    print_message "✓ npm installed successfully: v$NPM_VER"
else
    print_error "✗ npm installation failed"
    exit 1
fi

# Update npm to latest version
print_message "Updating npm to latest version..."
npm install -g npm@latest

print_header "INSTALLATION COMPLETE"
print_message "Node.js and npm have been installed successfully!"
print_message ""
print_message "Current versions:"
print_message "• Node.js: $(node --version)"
print_message "• npm: $(npm --version)"
print_message ""
print_message "IMPORTANT: Restart your terminal or run:"
print_message "source ~/.bashrc"
print_message ""
print_message "Installation directory: $INSTALL_DIR"
print_message "PATH has been updated in ~/.bashrc and ~/.profile"
print_message ""
print_message "You can now use 'node' and 'npm' commands!"
print_message ""
print_message "Created by bokiko - https://github.com/bokiko"