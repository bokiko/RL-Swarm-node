# Updated Gensyn RL-Swarm 72B Setup Guide for Ubuntu

This guide covers setting up a node for the latest Gensyn RL-Swarm system on Ubuntu, including support for the new 72B parameter models and multi-swarm capabilities.

## Prerequisites

- Ubuntu 20.04 or newer
- **Consumer tier**: GPU with 8GB+ VRAM
- **Powerful tier**: GPU with 24GB+ VRAM (for 72B parameter models)
- Minimum 16GB system RAM (32GB+ recommended for powerful tier)
- 4+ CPU cores

## Step 1: Install Required Software

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
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
sudo apt update && sudo apt install -y nvidia-container-toolkit
sudo systemctl restart docker

# Log out and log back in for Docker permissions to take effect
# (If using SSH, disconnect and reconnect)
```

## Step 2: Clone the Repository

```bash
# Clone the repo (or pull latest changes if already cloned)
git clone https://github.com/gensyn-ai/rl-swarm.git

# If you already have the repo, update it
# cd rl-swarm
# git pull

# Go to the project directory
cd rl-swarm
```

## Step 3: Configure Your Node

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
EMAIL_ADDRESS=your-email@example.com  # For multi-peer ID/EOA mapping

# Choose ONE of these two lines based on your GPU:
# For GPUs with 8GB-23GB VRAM (like RTX 2070, 3070, etc):
SWARM_TIER=consumer

# For GPUs with 24GB+ VRAM (like RTX 3090, 4090, A100, etc):
# SWARM_TIER=powerful

# GPU Configuration
NVIDIA_VISIBLE_DEVICES=all
```

Save and exit (Ctrl+X, then Y, then Enter).

## Step 4: Start Your Node

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

## Step 5: Set Up Auto-start (Optional)

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

Save and exit.

## Checking Node Status

To verify your node is running properly:

```bash
# Check if containers are running
docker ps

# Check logs
docker-compose logs -f

# Monitor GPU usage
nvidia-smi -l 5  # Updates every 5 seconds
```

## Understanding the Two Swarm Tiers

1. **Consumer Tier** (GSM8K dataset):
   - Requires 8GB+ VRAM
   - Suitable for consumer-grade GPUs
   - Lower computational requirements
   - Use `SWARM_TIER=consumer` in .env

2. **Powerful Tier** (DAPO-Math-17k dataset):
   - Supports models up to 72B parameters
   - Requires 24GB+ VRAM
   - Harder mathematical problems
   - Use `SWARM_TIER=powerful` in .env

## Troubleshooting

If containers show "unhealthy" status:

```bash
# Restart
docker-compose down
docker-compose up -d

# Check logs
docker logs rl-swarm-fastapi-1
```

GPU-related issues:

```bash
# Check GPU is visible to Docker
docker run --gpus all nvidia/cuda:11.8.0-base-ubuntu22.04 nvidia-smi

# If GPU not detected in container, restart NVIDIA services
sudo systemctl restart nvidia-docker
sudo systemctl restart docker
```

## Useful Commands

```bash
# View node logs
docker-compose logs -f

# Restart node
docker-compose restart

# Stop node
docker-compose down

# Start node in background
docker-compose up -d

# Update to latest version
git pull
docker-compose down
docker-compose pull
docker-compose up -d

# Get node IP
hostname -I | awk '{print $1}'
```

## Resources

- [Official GitHub Repository](https://github.com/gensyn-ai/rl-swarm)
- [Gensyn Documentation](https://docs.gensyn.ai/litepaper)
- [Consumer Swarm Dashboard](https://app.gensyn.ai/dashboard)
- [Powerful Swarm Dashboard](https://app.gensyn.ai/dashboard-hard)
