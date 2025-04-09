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

### Step 3: Clone the RL Swarm Repository

```bash
cd $HOME
git clone https://github.com/gensyn-ai/rl-swarm.git
cd rl-swarm
```

### Step 4: Configure the Node

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
```

Save and exit: `Ctrl+O`, `Enter`, `Ctrl+X`

### Step 5: Launch the RL Swarm Node

Start the containers with Docker Compose:

```bash
docker-compose up -d
```

This runs the containers in detached mode (in the background).

To view the logs:
```bash
docker-compose logs -f
```

Press `Ctrl+C` to exit the logs view while keeping the containers running.

### Step 6: Access the Web Interface

The RL Swarm node provides a web interface for monitoring and management:

- Local access: `http://localhost:8080`
- Remote access: `http://<mini-pc-ip>:8080`

To find your IP address:
```bash
ip addr show
```

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

### Docker Permission Issues
If you see "permission denied" errors:
```bash
sudo usermod -aG docker $USER
newgrp docker
```

### Port Conflicts
If port 8080 is already in use:
```bash
sudo lsof -i :8080
```
Then either kill the process or edit `docker-compose.yml` to use a different port.

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
