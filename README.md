# Gensyn RL-Swarm Complete Setup Guide

This guide provides straightforward instructions for setting up a Gensyn RL-Swarm node, with specific information for both Ubuntu and WSL2 users.

## Hardware Requirements

- **CPU:** Minimum 16GB RAM (more recommended for larger models)
- **GPU:** 
  - Consumer tier (Math GSM8K): GPU with ≥8GB VRAM
  - Powerful tier (Math Hard DAPO-17K): GPU with ≥24GB VRAM
  - CPU-only mode is also possible but not recommended

## Ubuntu Setup

### Step 1: Install Prerequisites

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt install -y nodejs

# Verify Node.js installation
node -v

# Install Yarn
sudo npm install -g yarn
yarn -v

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Install other dependencies
sudo apt install -y git tmux

# For GPU support, install NVIDIA drivers
sudo apt install -y nvidia-driver-525
```

Log out and log back in for Docker permissions to take effect.

### Step 2: Clone the Repository

```bash
# Clone the repo
git clone https://github.com/gensyn-ai/rl-swarm.git

# Navigate to the project directory
cd rl-swarm
```

### Step 3: Start Your Node

```bash
# Start the node using the script
./run_rl_swarm.sh
```

During setup, you'll be asked a series of questions:

1. Select whether to pull the latest version (answer 'Y')
2. Choose which swarm to join:
   - Option A: Math (GSM8K dataset) - For systems with >8GB VRAM
   - Option B: Math Hard (DAPO-Math 17K dataset) - For powerful systems

3. Select model size in billions of parameters:
   - 0.5B, 1.5B: For low-end GPUs (8GB VRAM)
   - 7B: For mid-range GPUs (16GB VRAM)
   - 32B, 72B: For high-end GPUs (≥24GB VRAM)

### Step 4: Identity Verification

After starting your node, you'll need to verify your identity:

1. The system will send a verification email to the address you provided
2. Look for logs indicating "Waiting for userData.json to be created..."
3. Access the web UI by opening `http://localhost:3000` in your browser
4. Log in with your email and complete verification

### Step 5: Backup Important Files

Backup your identity file to avoid losing your progress:

```bash
# Copy the identity file to a safe location
cp ./swarm.pem ~/swarm.pem
```

## WSL2 Setup

For Windows users using WSL2:

### Step 1: Install Docker Desktop

1. Download and install Docker Desktop for Windows
2. Enable WSL2 integration in Docker Desktop settings
3. Enable GPU support in Docker Desktop (if using NVIDIA GPU)

### Step 2: Follow Ubuntu Steps in WSL2

Open your WSL2 terminal and follow the Ubuntu setup steps above.

### Step 3: Access the Web UI

For WSL2 users, to access the login page:

1. When connecting via SSH (for remote machines):
   ```bash
   ssh username@ip-address -L 3000:localhost:3000
   ```

2. For local WSL2, just navigate to `http://localhost:3000` in your browser

## Running Multiple Nodes

To run multiple nodes with the same wallet:

1. Each node must have a unique name
2. Use the same email address for all nodes
3. Complete verification once, and all nodes will be linked

## Updating Your Node

If an update is available:

```bash
# Backup your identity file
cp ./swarm.pem ~/swarm.pem

# Update the repository
git pull

# If needed, clean the repository
git reset --hard origin/main

# Restore your identity file
cp ~/swarm.pem ./swarm.pem

# Restart your node
./run_rl_swarm.sh
```

## Troubleshooting

If you encounter issues:

- Check if verification email was sent
- Verify ports are correctly forwarded if using SSH
- If you see "EVM Wallet: 0x0000000000000000000000000000000000000000", your on-chain participation isn't being tracked

## Swarm Options

1. **Math (GSM8K dataset)**:
   - For consumer hardware (>8GB VRAM)
   - Use smaller models (0.5B or 1.5B)
   - Less computational requirements

2. **Math Hard (DAPO-Math 17K dataset)**:
   - For powerful hardware (≥24GB VRAM)
   - Use larger models (7B, 32B, or 72B)
   - Tackles more complex problems

## Resources

- [Official GitHub Repository](https://github.com/gensyn-ai/rl-swarm)
- [Consumer Dashboard](https://app.gensyn.ai/dashboard)
- [Powerful Dashboard](https://app.gensyn.ai/dashboard-hard)
