#!/bin/bash

# Gensyn Node Update Script
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

print_header "GENSYN NODE UPDATER"

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   print_error "This script should not be run as root. Please run as a regular user."
   exit 1
fi

print_message "Starting Gensyn node update process..."

# Step 1: Backup current files
print_header "STEP 1: BACKING UP CURRENT FILES"

if [ -d "$HOME/rl-swarm" ]; then
    print_message "Creating backup of current installation..."
    BACKUP_DIR="$HOME/rl-swarm_backup_$(date +%Y%m%d_%H%M%S)"
    cp -r "$HOME/rl-swarm" "$BACKUP_DIR"
    print_message "✓ Backup created at: $BACKUP_DIR"
    
    # Run backup script if it exists
    if [ -f "$HOME/backup_gensyn.sh" ]; then
        print_message "Running backup script..."
        "$HOME/backup_gensyn.sh"
    fi
else
    print_warning "No existing rl-swarm installation found."
fi

# Step 2: Stop current node
print_header "STEP 2: STOPPING CURRENT NODE"

print_message "Stopping tmux session..."
if tmux has-session -t gensyn 2>/dev/null; then
    tmux kill-session -t gensyn
    print_message "✓ Tmux session 'gensyn' stopped"
else
    print_message "No running tmux session found"
fi

# Step 3: Update system
print_header "STEP 3: UPDATING SYSTEM"

print_message "Updating package lists..."
sudo apt update

print_message "Upgrading system packages..."
sudo apt upgrade -y

print_message "Installing any missing dependencies..."
sudo apt install -y python3 python3-venv python3-pip curl wget tmux git lsof nano unzip iproute2 build-essential

# Step 4: Update repository
print_header "STEP 4: UPDATING REPOSITORY"

cd "$HOME"

print_message "Removing old repository..."
rm -rf RL-Swarm-node

print_message "Cloning latest repository..."
git clone https://github.com/bokiko/RL-Swarm-node.git

print_message "Setting permissions..."
chmod +x RL-Swarm-node/gensyn.sh
chmod +x RL-Swarm-node/install.sh
chmod +x RL-Swarm-node/backup.sh
chmod +x RL-Swarm-node/node.sh

print_message "✓ Repository updated"

# Step 5: Update Node.js
print_header "STEP 5: UPDATING NODE.JS"

print_message "Updating Node.js..."
curl -sSL https://raw.githubusercontent.com/bokiko/RL-Swarm-node/main/node.sh | bash

print_message "Sourcing bashrc..."
source ~/.bashrc 2>/dev/null || true

# Step 6: Restore backup files
print_header "STEP 6: RESTORING BACKUP FILES"

if [ -d "$BACKUP_DIR" ]; then
    print_message "Restoring critical files..."
    
    # Create rl-swarm directory if it doesn't exist
    mkdir -p "$HOME/rl-swarm"
    
    # Restore swarm.pem if it exists
    if [ -f "$BACKUP_DIR/swarm.pem" ]; then
        cp "$BACKUP_DIR/swarm.pem" "$HOME/rl-swarm/"
        chmod 600 "$HOME/rl-swarm/swarm.pem"
        print_message "✓ swarm.pem restored"
    else
        print_warning "swarm.pem not found in backup"
    fi
    
    # Restore other files
    for file in userData.json userApiKey.json config.json; do
        if [ -f "$BACKUP_DIR/$file" ]; then
            cp "$BACKUP_DIR/$file" "$HOME/rl-swarm/"
            print_message "✓ $file restored"
        fi
    done
else
    print_warning "No backup directory found to restore from"
fi

# Step 7: Update helper scripts
print_header "STEP 7: UPDATING HELPER SCRIPTS"

print_message "Updating start script..."
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

print_message "Updating backup script..."
curl -sSL -o "$HOME/backup_gensyn.sh" https://raw.githubusercontent.com/bokiko/RL-Swarm-node/main/backup.sh
chmod +x "$HOME/backup_gensyn.sh"

# Step 8: Verify update
print_header "STEP 8: VERIFYING UPDATE"

print_message "Checking versions..."
print_message "Python: $(python3 --version)"
print_message "Node.js: $(node --version 2>/dev/null || echo 'Not found - restart terminal')"
print_message "npm: $(npm --version 2>/dev/null || echo 'Not found - restart terminal')"

print_message "Checking file permissions..."
if [ -f "$HOME/rl-swarm/swarm.pem" ]; then
    ls -la "$HOME/rl-swarm/swarm.pem"
else
    print_warning "swarm.pem not found - you may need to run initial setup"
fi

# Final instructions
print_header "UPDATE COMPLETE"
print_message "Gensyn node update completed successfully!"
print_message ""
print_message "Next steps:"
print_message "1. Restart your terminal or run: source ~/.bashrc"
print_message "2. Start the node: ~/start_gensyn.sh"
print_message "3. Check logs: tmux attach-session -t gensyn"
print_message ""
print_message "If you encounter issues:"
print_message "• Run fresh setup: cd $HOME && ./RL-Swarm-node/gensyn.sh"
print_message "• Check troubleshooting in README.md"
print_message "• Restore from backup if needed"
print_message ""
print_message "Backup location: $BACKUP_DIR"
print_message ""
print_message "Updated by bokiko - https://github.com/bokiko"