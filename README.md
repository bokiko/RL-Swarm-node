# Complete Guide to Install RL Swarm Node on Mini PC (No GPU Required)

## What is RL Swarm?

RL Swarm is a decentralized network designed for training reinforcement learning agents using distributed computing power. It's part of the Gensyn protocol, which allows anyone to contribute computational resources to AI training in exchange for rewards.

- **Official Website**: [https://gensyn.ai](https://gensyn.ai)
- **GitHub Repository**: [https://github.com/gensyn-ai/rl-swarm](https://github.com/gensyn-ai/rl-swarm)
- **Documentation**: [https://docs.gensyn.ai](https://docs.gensyn.ai)

### Why Run an RL Swarm Node?

- **Participate in AI Development**: Contribute to cutting-edge reinforcement learning without needing expensive hardware
- **Potential Rewards**: Earn rewards for contributing computational resources (subject to network incentive structures)
- **Repurpose Hardware**: Give new life to mini PCs or older hardware
- **Learn About Decentralized AI**: Get hands-on experience with the emerging field of decentralized AI infrastructure

### Node Requirements

RL Swarm is designed to be resource-efficient. Unlike many AI workloads, reinforcement learning can be effectively run on CPU-only setups, making it perfect for mini PCs and other modest hardware configurations.

This guide will walk you through setting up an RL Swarm node on a mini PC without a GPU. Perfect for repurposing older hardware while participating in the Gensyn network.

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

### Step 2: Install Required Tools

#### Install Git:
```bash
sudo apt install git -y
```

#### Install Python and dependencies:
```bash
sudo apt install python3 python3-pip python3-venv -y
```

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

### Step 4: Set Up a Virtual Environment (Optional)

```bash
python3 -m venv .venv
source .venv/bin/activate
```

Install dependencies if needed:
```bash
pip3 install -r requirements.txt
```

### Step 5: Configure for CPU-Only Use

Edit the Docker Compose file to ensure CPU-only operation:
```bash
nano docker-compose.yml
```

Comment out any GPU-related lines with `#` if present:
```yaml
# devices:
#   - /dev/nvidia0:/dev/nvidia0
```

Save and exit: `Ctrl+O`, `Enter`, `Ctrl+X`

### Step 6: Launch the RL Swarm Node

```bash
docker-compose up --build
```

This builds the containers and starts the node. The first run may take several minutes.

### Step 7: Access the Swarm UI

Open a browser and navigate to:
- Local access: `http://localhost:8080`
- Remote access: `http://<mini-pc-ip>:8080`

To find your IP address:
```bash
ip addr show
```

### Step 8: Set Up for Automatic Start on Boot (Optional)

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
ExecStart=/usr/bin/tmux new-session -d -s rl-swarm 'docker-compose up'
ExecStop=/usr/bin/tmux send-keys -t rl-swarm C-c && /usr/bin/tmux send-keys -t rl-swarm 'docker-compose down' Enter
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

Enable and start the service:
```bash
sudo systemctl enable rl-swarm.service
sudo systemctl start rl-swarm.service
```

### Step 9: Stop and Restart (As Needed)

To stop the node:
```bash
docker-compose down
```

To restart:
```bash
docker-compose up
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

### Resource Monitoring
Check system resource usage:
```bash
top
```

### Missing Files
Ensure all required files exist:
```bash
ls -l ~/rl-swarm
```
If anything is missing, re-clone the repository.

## Final Verification

- Docker works: `docker ps` shows no errors
- Node runs: `docker-compose up --build` starts without issues
- UI loads: `http://localhost:8080` displays the Swarm interface

## Notes

- This setup is optimized for CPU-only operation, making it perfect for mini PCs
- If running alongside other services like Bitcoin nodes, ensure you have sufficient resources
- After a reboot, if not using the systemd service, you'll need to manually restart with `docker-compose up`

---

*Guide published by bokiko | Twitter: [Join our community](https://x.com/bokiko_io)*
