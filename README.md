# Complete Guide to Install RL Swarm Node on Mini PC (No GPU Required)

## What is RL Swarm?

RL Swarm is a decentralized network for training reinforcement learning models, part of the Gensyn protocol ecosystem. The network enables users to contribute computing resources to train AI systems collaboratively.

- **Official Website**: [https://gensyn.ai](https://gensyn.ai)
- **GitHub Repository**: [https://github.com/gensyn-ai/rl-swarm](https://github.com/gensyn-ai/rl-swarm)
- **Documentation**: [https://docs.gensyn.ai](https://docs.gensyn.ai)

### Why Run an RL Swarm Node?

- **Participate in AI Development**: Contribute to decentralized AI training
- **Earn Rewards**: Potentially earn tokens for providing computational resources (when mainnet launches)
- **Repurpose Hardware**: Put idle computing resources to productive use
- **Join the Community**: Be part of an innovative decentralized AI infrastructure

### Hardware Requirements

- **CPU**: Any x86_64 processor (Intel/AMD) with 2+ cores
- **RAM**: Minimum 4GB (8GB+ recommended)
- **Storage**: At least 10GB free space
- **Network**: Stable internet connection
- **GPU**: Not required (this guide focuses on CPU-only setup)

## Prerequisites

- **Hardware**: Mini PC with at least 4GB RAM and a decent CPU (Intel i3 or equivalent)
- **OS**: Debian/Ubuntu-based Linux
- **Internet**: Stable connection for repository access and swarm participation
- **User**: Non-root user with sudo privileges

## Installation Guide

> **Note**: This guide is designed for running RL Swarm on a CPU-only mini PC. We'll be configuring the node to use port 3000 for the web interface.

### Step 1: Update Your System

Ensure your system is up to date:

```bash
sudo apt update && sudo apt upgrade -y
```

### Step 2: Install Docker and Docker Compose

RL Swarm runs in Docker containers, so we need to install Docker and Docker Compose:

#### Install Docker:
```bash
sudo apt install docker.io -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
```

#### Install Docker Compose:
```bash
sudo apt install docker-compose -y
```

#### Apply group changes:
Either log out and back in, or use this temporary fix:
```bash
newgrp docker
```

#### Verify Docker access:
```bash
docker ps
```

If you see permission errors, fix the socket permissions:
```bash
sudo chown root:docker /var/run/docker.sock
sudo chmod 660 /var/run/docker.sock
```

### Step 3: Clone and Prepare RL Swarm

#### Clone the Repository
```bash
cd $HOME
git clone https://github.com/gensyn-ai/rl-swarm.git
cd rl-swarm
```

#### Identify the Correct Docker Images
Let's examine the existing docker-compose file to find the correct images:

```bash
cat docker-compose.yml
```

Note down the container images used in the original file. If you see services like "fastapi" and "otel-collector", those are part of the official setup.

#### Clean Up Existing Containers
If you have leftover containers causing network errors:

```bash
# Force stop all running containers in this project
docker-compose kill

# List all running docker containers
docker ps

# Stop individual containers if needed
docker stop rl-swarm-otel-collector-1 rl-swarm-fastapi-1

# Remove containers
docker rm rl-swarm-otel-collector-1 rl-swarm-fastapi-1
```

#### Create Environment Configuration
Create a `.env` file to configure your node:

```bash
nano .env
```

Add the following content (adjusting values as needed):

```
# Node Configuration
NODE_NAME=my-rl-swarm-node
# CPU Limit (optional, remove to use all cores)
CPU_LIMIT=4
# If you're on CPU only, set to false
GPU_ENABLED=false
# Set the web UI port to 3000
PORT=3000
```

Save and exit: `Ctrl+O`, `Enter`, `Ctrl+X`

### Step 4: Launch with Original Configuration

Based on your terminal output, it appears that the repository already contains the correct configuration, but we're having issues with the Docker images. Instead of creating a custom configuration, let's use the original setup:

```bash
# Make sure you're in the repository directory
cd ~/rl-swarm

# Start using the original docker-compose.yml
docker-compose up -d
```

If you encounter image pulling errors, let's check what images are specified in the original file:

```bash
grep "image:" docker-compose.yml
```

#### Troubleshooting Network Issues

If you encounter network errors like "network has active endpoints":

```bash
# List all running containers from this project
docker-compose ps -a

# Try to force recreate everything
docker-compose up -d --force-recreate
```

If that doesn't work, you may need to manually remove specific containers:

```bash
# See all containers, including stopped ones
docker ps -a

# Stop and remove problematic containers
docker stop rl-swarm-otel-collector-1 rl-swarm-fastapi-1
docker rm rl-swarm-otel-collector-1 rl-swarm-fastapi-1
```

After cleaning up, try again:

```bash
docker-compose up -d
```

### Step 5: Access the Web Interface

After successfully starting the node, access the web interface:

- Local access: `http://localhost:3000`
- Remote access: `http://<mini-pc-ip>:3000`

To find your IP address:
```bash
ip addr show
```

The web interface allows you to monitor your node's activity and performance.

### Step 7: Set Up for Automatic Start on Boot

Create a systemd service file:
```bash
sudo nano /etc/systemd/system/rl-swarm.service
```

Add the following content:
```
[Unit]
Description=RL Swarm Node
After=network.target docker.service
Requires=docker.service

[Service]
Type=simple
User=$USER
WorkingDirectory=/home/$USER/rl-swarm
ExecStart=/usr/bin/docker-compose up
ExecStop=/usr/bin/docker-compose down
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

Enable and start the service:
```bash
sudo systemctl enable rl-swarm.service
sudo systemctl start rl-swarm.service
```

### Step 8: Managing Your Node

To stop the node:
```bash
cd ~/rl-swarm
docker-compose down
```

To start again manually:
```bash
cd ~/rl-swarm
docker-compose up -d
```

To check status:
```bash
docker-compose ps
```

To update to the latest version:
```bash
cd ~/rl-swarm
git pull
docker-compose down
docker-compose up -d
```

## Troubleshooting

### Docker Image Pull Errors
If you see "pull access denied" or "repository does not exist" errors:

```
Error response from daemon: pull access denied for gensyn/rl-swarm, repository does not exist
```

This means the Docker image name in the compose file is incorrect. Check the correct image names:

```bash
# First, check what images are specified in the original docker-compose.yml
grep "image:" docker-compose.yml
```

If you don't see any obvious public images, the repository may use a build process instead:

```bash
# Check if there's a build section instead of image
grep "build:" docker-compose.yml
```

If it uses a build section, you'll need to build the images locally:

```bash
docker-compose build
```

Then try running again:

```bash
docker-compose up -d
```

### Network Removal Errors
If you see "network has active endpoints" errors:

```
failed to remove network: network rl-swarm_default has active endpoints
```

Use these commands to clean up:

```bash
# Force stop all containers in this compose project
docker-compose down --remove-orphans

# If that doesn't work, find and remove the containers manually
docker ps -a
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)

# As a last resort, restart Docker service
sudo systemctl restart docker
```

### Container Not Starting
Check docker logs for errors:
```bash
docker-compose logs
```

### Resource Issues
Check system resource usage:
```bash
htop
```
(Install with `sudo apt install htop` if not available)

### Network Connectivity
Make sure your node can connect to the internet:
```bash
curl -I https://api.gensyn.ai
```

## Optimizing Your Node

### CPU Performance
For better performance, you can adjust the CPU allocation in your `.env` file:
```
CPU_LIMIT=4  # Set to number of cores you want to dedicate
```

### Resource Monitoring
Install and use Glances for comprehensive monitoring:
```bash
sudo apt install glances
glances
```

### Managing Disk Space
Docker can consume space over time. Clean up occasionally:
```bash
docker system prune -a
```

## Additional Resources

- Join the [Gensyn Discord](https://discord.gg/gensyn) for community support
- Check the [official documentation](https://docs.gensyn.ai) for updates
- Follow Gensyn on [Twitter](https://twitter.com/gensyn_ai) for announcements

## Conclusion

You now have a running RL Swarm node contributing to the Gensyn network! As the project evolves, make sure to keep your node updated by periodically running `git pull` in the rl-swarm directory and restarting your node.

---

*Guide published by bokiko | Discord: [Join our community](https://discord.gg/bokiko)*
