#!/bin/bash

# Gensyn Backup Script
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

print_header "GENSYN BACKUP UTILITY"

# Check if rl-swarm directory exists
if [ ! -d "$HOME/rl-swarm" ]; then
    print_error "rl-swarm directory not found at $HOME/rl-swarm"
    print_message "Please make sure Gensyn is installed and running first."
    exit 1
fi

cd "$HOME/rl-swarm"

# Create backup directory with timestamp
BACKUP_DIR="$HOME/gensyn_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

print_message "Creating backup in: $BACKUP_DIR"

# Backup swarm.pem (CRITICAL)
if [ -f "swarm.pem" ]; then
    cp swarm.pem "$BACKUP_DIR/"
    print_message "✓ swarm.pem backed up (CRITICAL FILE)"
    SWARM_EXISTS=true
else
    print_error "✗ swarm.pem not found - THIS IS CRITICAL!"
    print_warning "Without this file, your contribution will be lost."
    SWARM_EXISTS=false
fi

# Backup userData.json (Optional)
if [ -f "userData.json" ]; then
    cp userData.json "$BACKUP_DIR/"
    print_message "✓ userData.json backed up"
else
    print_warning "- userData.json not found (optional file)"
fi

# Backup userApiKey.json (Optional)
if [ -f "userApiKey.json" ]; then
    cp userApiKey.json "$BACKUP_DIR/"
    print_message "✓ userApiKey.json backed up"
else
    print_warning "- userApiKey.json not found (optional file)"
fi

# Backup configuration files if they exist
if [ -f "config.json" ]; then
    cp config.json "$BACKUP_DIR/"
    print_message "✓ config.json backed up"
fi

if [ -f ".env" ]; then
    cp .env "$BACKUP_DIR/"
    print_message "✓ .env backed up"
fi

# Create backup info file
cat > "$BACKUP_DIR/backup_info.txt" << EOF
Gensyn Backup Information
========================
Backup Date: $(date)
Backup Location: $BACKUP_DIR
Node IP: $(curl -s https://ipinfo.io/ip 2>/dev/null || echo "Unable to fetch")
System: $(uname -a)

Files Backed Up:
$(ls -la "$BACKUP_DIR/")

IMPORTANT NOTES:
- swarm.pem is the most critical file - keep it safe!
- This backup contains your node identity
- Never share these files publicly
- Store multiple copies in different locations

Created by bokiko - https://github.com/bokiko
EOF

# Create archive
print_message "Creating compressed archive..."
cd "$HOME"
tar -czf "gensyn_backup_$(date +%Y%m%d_%H%M%S).tar.gz" "$(basename "$BACKUP_DIR")"

print_header "BACKUP SUMMARY"
print_message "Backup completed successfully!"
print_message ""
print_message "Backup location: $BACKUP_DIR"
print_message "Archive created: $HOME/gensyn_backup_$(date +%Y%m%d_%H%M%S).tar.gz"
print_message ""
print_message "Files backed up:"
ls -la "$BACKUP_DIR/"

if [ "$SWARM_EXISTS" = "true" ]; then
    print_message ""
    print_message "✓ CRITICAL: swarm.pem file successfully backed up"
    print_message "Keep this file safe - it contains your node identity!"
else
    print_error ""
    print_error "✗ CRITICAL: swarm.pem file NOT found!"
    print_error "Your node may not be properly initialized."
    print_error "Run the node setup first, then backup again."
fi

print_message ""
print_message "SECURITY RECOMMENDATIONS:"
print_message "• Store backup in multiple secure locations"
print_message "• Never share your swarm.pem file"
print_message "• Keep backups offline when possible"
print_message "• Test backup restoration periodically"
print_message ""
print_message "To restore from this backup:"
print_message "1. Copy files from backup directory to ~/rl-swarm/"
print_message "2. Ensure proper file permissions: chmod 600 ~/rl-swarm/swarm.pem"
print_message "3. Restart your node"
print_message ""
print_message "Created by bokiko - https://github.com/bokiko"