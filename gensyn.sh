#!/bin/bash

# Gensyn Testnet Setup Script
# Created by bokiko - https://github.com/bokiko

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
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

print_step() {
    echo -e "${PURPLE}[STEP]${NC} $1"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   print_error "This script should not be run as root. Please run as a regular user."
   exit 1
fi

print_header "GENSYN TESTNET SETUP"
print_message "Starting Gensyn RL Swarm setup..."

# Verify prerequisites
print_step "Checking prerequisites..."

# Check Python
if ! command -v python3 &> /dev/null; then
    print_error "Python3 is not installed. Please run the installation script first."
    exit 1
fi

PYTHON_VERSION=$(python3 --version | cut -d' ' -f2 | cut -d'.' -f1,2)
REQUIRED_VERSION="3.10"

if [ "$(printf '%s\n' "$REQUIRED_VERSION" "$PYTHON_VERSION" | sort -V | head -n1)" != "$REQUIRED_VERSION" ]; then
    print_error "Python 3.10+ required. Found version $PYTHON_VERSION"
    exit 1
fi

print_message "✓ Python version: $(python3 --version)"

# Check Node.js
if ! command -v node &> /dev/null; then
    print_error "Node.js is not installed. Please run the installation script first."
    exit 1
fi

print_message "✓ Node.js version: $(node --version)"

# Check npm
if ! command -v npm &> /dev/null; then
    print_error "npm is not installed. Please install Node.js first."
    exit 1
fi

print_message "✓ npm version: $(npm --version)"

# Check available disk space
AVAILABLE_SPACE=$(df -BG / | awk 'NR==2{print $4}' | sed 's/G//')
if [ "$AVAILABLE_SPACE" -lt 10 ]; then
    print_warning "Low disk space: ${AVAILABLE_SPACE}GB available. 20GB+ recommended."
fi

# Check available RAM
AVAILABLE_RAM=$(free -g | awk '/^Mem:/{print $2}')
if [ "$AVAILABLE_RAM" -lt 8 ]; then
    print_warning "Low RAM: ${AVAILABLE_RAM}GB available. 24GB+ recommended for optimal performance."
fi

# Create working directory
print_step "Setting up working directory..."
cd "$HOME"

# Clone or update RL Swarm repository
if [ -d "rl-swarm" ]; then
    print_warning "Existing rl-swarm directory found."
    read -p "Do you want to remove it and start fresh? (y/N): " -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_message "Removing existing rl-swarm directory..."
        rm -rf rl-swarm
    else
        print_message "Keeping existing directory. Updating..."
        cd rl-swarm
        git pull origin main || print_warning "Could not update repository"
        cd "$HOME"
    fi
fi

if [ ! -d "rl-swarm" ]; then
    print_message "Cloning RL Swarm repository..."
    git clone https://github.com/gensyn-ai/rl-swarm.git
    if [ $? -ne 0 ]; then
        print_error "Failed to clone rl-swarm repository"
        exit 1
    fi
fi

cd rl-swarm

# Check for CUDA availability
print_step "Checking CUDA availability..."
if command -v nvidia-smi &> /dev/null; then
    print_message "✓ NVIDIA GPU detected:"
    nvidia-smi --query-gpu=name,memory.total --format=csv,noheader
    CUDA_AVAILABLE=true
else
    print_warning "No NVIDIA GPU detected. Running in CPU mode."
    print_warning "Performance may be limited without GPU acceleration."
    CUDA_AVAILABLE=false
fi

# Create Python virtual environment
print_step "Creating Python virtual environment..."
if [ -d "venv" ]; then
    print_message "Removing existing virtual environment..."
    rm -rf venv
fi

python3 -m venv venv
source venv/bin/activate

print_message "✓ Virtual environment created and activated"

# Upgrade pip
print_message "Upgrading pip..."
pip install --upgrade pip

# Install requirements
print_step "Installing Python dependencies..."
if [ -f "requirements.txt" ]; then
    pip install -r requirements.txt
else
    print_warning "requirements.txt not found. Installing common dependencies..."
    pip install torch torchvision torchaudio
    pip install transformers
    pip install datasets
    pip install hivemind
    pip install wandb
    pip install numpy pandas matplotlib seaborn
fi

# Install CUDA-specific packages if available
if [ "$CUDA_AVAILABLE" = true ]; then
    print_message "Installing CUDA-optimized packages..."
    pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
fi

print_message "✓ Python dependencies installed"

# Create run script
print_step "Creating run script..."
cat > run_rl_swarm.sh << 'EOF'
#!/bin/bash

# Activate virtual environment
source venv/bin/activate

# Set environment variables
export PYTHONPATH="${PYTHONPATH}:$(pwd)"
export CUDA_VISIBLE_DEVICES=0

# Check if swarm.pem exists
if [ ! -f "swarm.pem" ]; then
    echo "swarm.pem not found. This appears to be a first run."
    echo "The swarm will generate a new identity."
fi

# Run the RL swarm
python -m rl_swarm.main "$@"
EOF

chmod +x run_rl_swarm.sh

print_message "✓ Run script created"

# Create configuration file if it doesn't exist
if [ ! -f "config.json" ]; then
    print_step "Creating default configuration..."
    cat > config.json << 'EOF'
{
    "device": "auto",
    "batch_size": 32,
    "learning_rate": 3e-4,
    "max_epochs": 100,
    "save_interval": 10,
    "log_interval": 1,
    "wandb_project": "gensyn-rl-swarm",
    "model_name": "gpt2",
    "push_to_hub": false
}
EOF
    print_message "✓ Default configuration created"
fi

# Create backup reminder
print_step "Setting up backup reminder..."
cat > backup_reminder.txt << 'EOF'
IMPORTANT: BACKUP YOUR FILES!

After your first successful run, make sure to backup:

1. swarm.pem (CRITICAL - contains your node identity)
2. userData.json (optional but recommended)
3. userApiKey.json (optional but recommended)

Use the backup script:
~/backup_gensyn.sh

Or manually copy these files to a safe location.

WITHOUT swarm.pem, your contribution history will be lost!
EOF

print_message "✓ Backup reminder created"

# Final setup
print_header "SETUP COMPLETE"
print_message "Gensyn RL Swarm setup completed successfully!"
print_message ""
print_message "Configuration:"
print_message "• Working directory: $(pwd)"
print_message "• Python virtual environment: venv/"
print_message "• Run script: run_rl_swarm.sh"
print_message "• CUDA available: $CUDA_AVAILABLE"
print_message ""
print_message "To start the swarm:"
print_message "1. Make sure you're in tmux session"
print_message "2. Run: ./run_rl_swarm.sh"
print_message ""
print_message "The swarm will ask about Hugging Face Hub:"
print_message "Type 'N' when prompted about pushing models"
print_message ""
print_warning "CRITICAL: After first run, backup your swarm.pem file!"
print_warning "Use: ~/backup_gensyn.sh"
print_message ""
print_message "Monitor your node at: https://gensyn-node.vercel.app/"
print_message ""
print_message "Starting the swarm now..."

# Start the swarm
print_step "Launching RL Swarm..."
./run_rl_swarm.sh