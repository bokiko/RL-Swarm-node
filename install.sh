#!/bin/bash

# Gensyn Testnet Node - Automated Installation Script
# Created by bokiko - https://github.com/bokiko

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
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

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   print_error "This script should not be run as root. Please run as a regular user."
   exit 1
fi

print_header "GENSYN TESTNET NODE INSTALLER"
print_message "Starting automated installation..."

# Check system requirements
print_header "CHECKING SYSTEM REQUIREMENTS"

# Check RAM
RAM_GB=$(free -g | awk '/^Mem:/{print $2}')
print_message "Available RAM: ${RAM_GB}GB"

if [ "$RAM_GB" -lt 8 ]; then
    print_warning "Less than 8GB RAM detected. 24GB is recommended for optimal performance."
fi

# Check disk space
DISK_SPACE=$(df -BG / | awk 'NR==2{print $4}' | sed 's/G//')
print_message "Available disk space: ${DISK_SPACE}GB"

if [ "$DISK_SPACE" -lt 20 ]; then
    print_error "Insufficient disk space. At least 20GB free space required."
    exit 1
fi

# Update system
print_header "UPDATING SYSTEM"
print_message "Updating package lists..."
sudo apt update

print_message "Upgrading system packages..."
sudo apt upgrade -y

# Install dependencies
print_header "INSTALLING DEPENDENCIES"
print_message "Installing required packages..."
sudo apt install -y python3 python3-venv python3-pip curl wget tmux git lsof nano unzip iproute2 build-essential

# Verify Python version
print_message "Checking Python version..."
PYTHON_VERSION=$(python3 --version | cut -d' ' -f2 | cut -d'.' -f1,2)
REQUIRED_VERSION="3.10"

if [ "$(printf '%s\n' "$REQUIRED_VERSION" "$PYTHON_VERSION" | sort -V | head -n1)" != "$REQUIRED_VERSION" ]; then
    print_error "Python 3.10+ required. Found version $PYTHON_VERSION"
    print_message "Installing Python 3.10..."
    sudo apt install -y python3.10 python3.10-venv python3.10-pip
    sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1
fi

# Install Node.js
print_header "INSTALLING NODE.JS"
print_message "Installing Node.js and npm..."

if ! command -v node &> /dev/null; then
    curl -sSL https://raw.githubusercontent.com/bokiko/gensyn-guide/main/node.sh | bash
    
    # Source bashrc to get node in PATH
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
else
    print_message "Node.js already installed"
fi

# Verify installations
print_header "VERIFYING INSTALLATIONS"
print_message "Python version: $(python3 --version)"
print_message "Node.js version: $(node --version 2>/dev/null || echo 'Not found - please restart terminal')"
print_message "npm version: $(npm --version 2>/dev/null || echo 'Not found - please restart terminal')"

# Check for existing installation
if [ -d "$HOME/rl-swarm" ]; then
    print_warning "Existing installation found at $HOME/rl-swarm"
    read -p "Do you want to remove it and start fresh? (y/N): " -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_message "Removing existing installation..."
        rm -rf "$HOME/gensyn-testnet"
        tmux kill-session -t gensyn 2>/dev/null || true
    else
        print_message "Keeping existing installation. Skipping clone step."
        SKIP_CLONE=true
    fi
fi

# Clone repository and setup
if [ "$SKIP_CLONE" != "true" ]; then
    print_header "SETTING UP GENSYN"
    print_message "Cloning Gensyn repository..."
    cd $HOME
    rm -rf gensyn-testnet
    git clone https://github.com/bokiko/gensyn-guide.git
    chmod +x gensyn-guide/gensyn.sh
fi

# Create auto-start script
print_header "CREATING AUTO-START SCRIPT"
print_message "Creating auto-start script..."

cat > "$HOME/start_gensyn.sh" << 'EOF'
#!/bin/bash
cd ~/rl-swarm
if tmux has-session -t gensyn 2>/dev/null; then
    echo "Gensyn session already exists. Attaching..."
    tmux attach-session -t gensyn
else
    echo "Starting new Gensyn session..."
    tmux new-session -d -s gensyn './run_rl_swarm.sh'
    echo "Gensyn node started in tmux session 'gensyn'"
    echo "Use 'tmux attach-session -t gensyn' to view logs"
fi
EOF

chmod +x "$HOME/start_gensyn.sh"

# Create backup script
print_message "Creating backup script..."

cat > "$HOME/backup_gensyn.sh" << 'EOF'
#!/bin/bash
echo "Creating backup directory..."
mkdir -p ~/gensyn_backup
cd ~/rl-swarm

if [ -f "swarm.pem" ]; then
    cp swarm.pem ~/gensyn_backup/
    echo "✓ swarm.pem backed up"
else
    echo "✗ swarm.pem not found"
fi

if [ -f "userData.json" ]; then
    cp userData.json ~/gensyn_backup/
    echo "✓ userData.json backed up"
else
    echo "- userData.json not found (optional)"
fi

if [ -f "userApiKey.json" ]; then
    cp userApiKey.json ~/gensyn_backup/
    echo "✓ userApiKey.json backed up"
else
    echo "- userApiKey.json not found (optional)"
fi

echo ""
echo "Backup completed in ~/gensyn_backup/"
echo "Files in backup:"
ls -la ~/gensyn_backup/
EOF

chmod +x "$HOME/backup_gensyn.sh"

# Final instructions
print_header "INSTALLATION COMPLETE"
print_message "Installation completed successfully!"
print_message ""
print_message "Next steps:"
print_message "1. Restart your terminal or run: source ~/.bashrc"
print_message "2. Run the setup: cd $HOME && ./gensyn-guide/gensyn.sh"
print_message "3. When prompted about Hugging Face Hub, type 'N'"
print_message "4. After setup, run: ~/backup_gensyn.sh to backup your files"
print_message ""
print_message "Useful commands:"
print_message "• Start node: ~/start_gensyn.sh"
print_message "• View logs: tmux attach-session -t gensyn"
print_message "• Detach from logs: Ctrl+B then D"
print_message "• Backup files: ~/backup_gensyn.sh"
print_message "• Get IP: curl -s https://ipinfo.io/ip"
print_message ""
print_warning "IMPORTANT: Always backup your swarm.pem file after initial setup!"
print_message ""
print_message "Guide created by bokiko - https://github.com/bokiko"