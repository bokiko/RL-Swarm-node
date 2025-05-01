# Complete Gensyn RL-Swarm 72B Setup Guide

This guide covers setting up a Gensyn RL-Swarm node on both native Ubuntu and WSL2, including support for the new 72B parameter models and multi-swarm capabilities.

## Ubuntu Setup (Recommended)

### Prerequisites

- Ubuntu 20.04 or newer
- **Consumer tier**: GPU with 8GB+ VRAM
- **Powerful tier**: GPU with 24GB+ VRAM (for 72B parameter models)
- Minimum 16GB system RAM (32GB+ recommended for powerful tier)
- 4+ CPU cores

### Step 1: Install Required Software

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install dependencies
sudo apt install -y git curl wget tmux nvidia-driver-525

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Install NVIDIA Container Toolkit for GPU support
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-container/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-container/$distribution/nvidia-container.list | sudo tee /etc/apt/sources.list.d/nvidia-container.list
sudo apt update && sudo apt install -y nvidia-container-toolkit
sudo systemctl restart docker

# Log out and log back in for Docker permissions to take effect
# (If using SSH, disconnect and reconnect)
```

### Step 2: Clone the Repository

```bash
# Clone the repo
git clone https://github.com/gensyn-ai/rl-swarm.git

# Go to the project directory
cd rl-swarm
```

### Step 3: Configure Your Node

Create the configuration file:

```bash
# Create .env file
nano .env
```

Add these lines to the file (replace with your information):

```
# Basic Configuration
NODE_NAME=your-unique-node-name
NODE_WALLET_ADDRESS=your-ethereum-wallet-address
EMAIL_ADDRESS=your-email@example.com

# Choose ONE of these based on your GPU:
# For GPUs with 8GB-23GB VRAM (like RTX 2070, 3070, etc):
SWARM_TIER=consumer

# For GPUs with 24GB+ VRAM (like RTX 3090, 4090, A100, etc):
# SWARM_TIER=powerful

# GPU Configuration
NVIDIA_VISIBLE_DEVICES=all
```

### Step 4: Start Your Node

First, test your GPU setup:

```bash
# Verify NVIDIA drivers are installed correctly
nvidia-smi

# Test NVIDIA Docker
docker run --gpus all nvidia/cuda:11.8.0-base-ubuntu22.04 nvidia-smi
```

Start the node using tmux (keeps it running when you disconnect):

```bash
# Create a new tmux session
tmux new -s gensyn

# Inside tmux, start the node
docker-compose up

# To detach from tmux (keeps node running): 
# Press Ctrl+B, then D
```

To reattach to the tmux session later:

```bash
tmux attach -t gensyn
```

### Step 5: Complete Identity Verification

When you first start your node:

1. **Check logs for verification email**:
   - The system will send a verification email to the address you provided
   - Look for an email from Gensyn with a verification link
   - Click the link to verify your email and complete registration

2. **Check registration status**:
   - After verification, your node will be registered on the network
   - View your node in the appropriate dashboard:
     - Consumer tier: https://app.gensyn.ai/dashboard
     - Powerful tier: https://app.gensyn.ai/dashboard-hard

### Step 6: Set Up Auto-start

Create a startup script:

```bash
nano ~/start-gensyn.sh
```

Add the following:

```bash
#!/bin/bash
sleep 30  # Wait for system to fully boot
cd ~/rl-swarm
docker-compose down  # Ensure clean start
tmux new-session -d -s gensyn 'docker-compose up'
```

Make it executable and set up auto-start:

```bash
chmod +x ~/start-gensyn.sh

# Configure auto-start using crontab
crontab -e
```

Add this line to the crontab file:

```
@reboot ~/start-gensyn.sh
```

## WSL2 Setup (Alternative)

If you're using Windows Subsystem for Linux (WSL2), follow these steps instead:

### Step 1: Install Docker Desktop for Windows

1. **Download and install Docker Desktop** from https://www.docker.com/products/docker-desktop/
2. **Enable WSL2 integration** in Docker Desktop Settings → Resources → WSL Integration
3. **Enable GPU support** in Docker Desktop Settings → Resources → NVIDIA GPU (if using NVIDIA GPU)

### Step 2: Set Up in WSL2

Open your WSL2 Ubuntu terminal and run:

```bash
# Install required tools
sudo apt update && sudo apt install -y git tmux

# Clone the repository
git clone https://github.com/gensyn-ai/rl-swarm.git
cd rl-swarm

# Create .env file
nano .env
```

Add the same configuration as in the Ubuntu setup:

```
NODE_NAME=your-unique-node-name
NODE_WALLET_ADDRESS=your-ethereum-wallet-address
EMAIL_ADDRESS=your-email@example.com
SWARM_TIER=consumer  # or powerful for 24GB+ VRAM GPUs
NVIDIA_VISIBLE_DEVICES=all
```

Start the node:

```bash
# Create tmux session
tmux new -s gensyn

# Start node
docker-compose up

# Detach from tmux: Ctrl+B, then D
```

For auto-start in WSL2, you'll need to create a Windows scheduled task or start manually after WSL boots.

## Multi-Node Setup

To run multiple nodes with the same wallet:

1. Each node must have a unique `NODE_NAME`
2. Use the same `EMAIL_ADDRESS` and `NODE_WALLET_ADDRESS` across all nodes
3. Complete email verification once, and all nodes will be linked to your account

## Understanding the Two Swarm Tiers

1. **Consumer Tier** (GSM8K dataset):
   - Requires 8GB+ VRAM
   - Suitable for consumer-grade GPUs
   - Use `SWARM_TIER=consumer` in .env

2. **Powerful Tier** (DAPO-Math-17k dataset):
   - Supports models up to 72B parameters
   - Requires 24GB+ VRAM
   - Use `SWARM_TIER=powerful` in .env

## Checking Node Status

```bash
# Check if containers are running
docker ps

# Check logs
docker-compose logs -f

# Monitor GPU usage
nvidia-smi -l 5
```

## Troubleshooting

GPU-related issues:

```bash
# Check if NVIDIA drivers are working
nvidia-smi

# For WSL2: Ensure GPU support is enabled in Docker Desktop settings

# Test GPU in Docker
docker run --gpus all nvidia/cuda:11.8.0-base-ubuntu22.04 nvidia-smi
```

Container issues:

```bash
# Restart containers
docker-compose down
docker-compose up -d

# Check logs
docker logs rl-swarm-fastapi-1
```

Email verification issues:

```bash
# Check for email-related logs
docker-compose logs -f | grep -i email

# If no email received, verify your email address in .env and restart
```

## Useful Commands

```bash
# View node logs
docker-compose logs -f

# Restart node
docker-compose restart

# Update to latest version
git pull
docker-compose down
docker-compose pull
docker-compose up -d
```

## Resources

- [Official GitHub Repository](https://github.com/gensyn-ai/rl-swarm)
- [Gensyn Documentation](https://docs.gensyn.ai/litepaper)
- [Consumer Swarm Dashboard](https://app.gensyn.ai/dashboard)
- [Powerful Swarm Dashboard](https://app.gensyn.ai/dashboard-hard)
