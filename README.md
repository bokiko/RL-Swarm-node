# Gensyn RL-Swarm Node Setup Guide

This guide provides simple step-by-step instructions for setting up a Gensyn RL-Swarm node on Ubuntu.

## Quick Setup

### Step 1: Install Prerequisites

```bash
# Update and upgrade packages
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Install other necessary tools
sudo apt install -y git tmux nano
```

Log out and log back in to apply docker group changes.

### Step 2: Clone the Repository

```bash
# Clone the repository
git clone https://github.com/gensyn-ai/rl-swarm.git

# Navigate to the repository
cd rl-swarm
```

### Step 3: Configure Node

```bash
# Create .env file
nano .env
```

Add the following to the .env file:
```
NODE_NAME=your-node-name
NODE_WALLET_ADDRESS=your-eth-wallet-address
```

Press `Ctrl+X`, then `Y` to save and exit.

### Step 4: Start the Node

Create a tmux session to keep the node running:

```bash
# Start a new tmux session
tmux new -s gensyn

# In the tmux session, start the node
docker-compose up
```

To detach from tmux: Press `Ctrl+B`, then `D`
To reattach later: `tmux attach -t gensyn`

### Step 5: Set Up Auto-restart

Create a startup script:

```bash
nano ~/start-gensyn.sh
```

Add the following content:
```bash
#!/bin/bash
cd ~/rl-swarm
tmux new-session -d -s gensyn 'docker-compose up'
```

Make it executable:
```bash
chmod +x ~/start-gensyn.sh
```

Set it to run on reboot:
```bash
crontab -e
```

Add this line:
```
@reboot ~/start-gensyn.sh
```

## Checking Node Status

To see if your node is running correctly:

```bash
# Check container status
docker ps

# To see node logs
docker-compose logs -f

# To get your node IP
hostname -I | awk '{print $1}'
```

## Basic Troubleshooting

If containers show as "unhealthy":

```bash
# Restart containers
docker-compose down
docker-compose up -d

# Check logs for errors
docker logs rl-swarm-fastapi-1
```

## Resources

- [Official Gensyn GitHub](https://github.com/gensyn-ai/rl-swarm)
- [Gensyn Documentation](https://docs.gensyn.ai/litepaper)

---

Created by [Cloudiko.io]
