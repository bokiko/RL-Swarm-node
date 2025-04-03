Complete Guide to Install RL Swarm Node on Your Mini PC (No GPU)

Prerequisites
Hardware: Mini PC with at least 4GB RAM and a decent CPU (e.g., Intel i3 or equivalent). No GPU required.
OS: Debian/Ubuntu-based Linux (confirmed by your error messages).
Internet: Stable connection for cloning the repo and swarm participation.
User: You’re logged in as bokiko (non-root).

Step 1: Update Your System

Ensure your system is up to date to avoid compatibility issues.
Open a terminal and run:
bash


sudo apt update && sudo apt upgrade -y

Step 2: Install Required Tools

Install the essential software for RL Swarm: Git, Python, Docker, and Docker Compose.
Install Git:
bash


sudo apt install git -y
Install Python 3 and pip:
bash


sudo apt install python3 python3-pip -y
Verify: python3 --version (should be 3.6+).
Install Python venv (for virtual environments):
bash


sudo apt install python3-venv -y
Install Docker:
bash


sudo apt install docker.io -y
Start and enable Docker:
bash


sudo systemctl start docker sudo systemctl enable docker
Add bokiko to the docker group:
bash


sudo usermod -aG docker bokiko
Install Docker Compose:
bash


sudo apt install docker-compose -y
Apply Group Changes:
Log out and back in:
bash


exit
Then reconnect (e.g., via SSH or terminal login).
Or use this temporary fix:
bash


newgrp docker
Verify Docker Access:
bash


docker ps
If you see a list of containers (likely empty) and no permission denied error, you’re set. If you get a permission error, fix the socket:
bash


sudo chown root:docker /var/run/docker.sock sudo chmod 660 /var/run/docker.sock
Then retry docker ps.

Step 3: Clone the RL Swarm Repository

Download the RL Swarm code from GitHub.
Navigate to your home directory:
bash


cd $HOME
Clone the repo:
bash


git clone https://github.com/gensyn-ai/rl-swarm.git
Enter the directory:
bash


cd rl-swarm

Step 4: Set Up a Virtual Environment (Optional)

This isolates Python dependencies, though Docker handles most of the setup.
Create the virtual environment:
bash


python3 -m venv .venv
Activate it:
bash


source .venv/bin/activate
Your prompt should change to (.venv) bokiko@Bitcoin-Node:~/rl-swarm$.
Install Python dependencies (if applicable):
bash


pip3 install -r requirements.txt
If requirements.txt doesn’t exist, skip this—it’s not critical for Docker-based setup.
Deactivate when done (optional):
bash


deactivate

Step 5: Configure for CPU-Only Use

Since your mini PC has no GPU, ensure the setup defaults to CPU.
Check docker-compose.yml:
bash


nano docker-compose.yml
Look for GPU-related lines (e.g., devices or nvidia). Comment them out with # if present:
yaml


# devices: # - /dev/nvidia0:/dev/nvidia0
Save and exit: Ctrl+O, Enter, Ctrl+X.

Step 6: Launch the RL Swarm Node

Start the node using Docker Compose.
Build and run:
bash


docker-compose up --build
This builds the containers and starts the node. It may take a few minutes the first time.
If you get a permission denied error, use:
bash


sudo docker-compose up --build
But ideally, Step 2’s permission fixes should make sudo unnecessary.
Watch the logs in the terminal for startup messages (e.g., container creation, swarm connection).

Step 7: Access the Swarm UI

Monitor your node via the web interface.
Open a browser on your mini PC (or another device on the same network).
Go to: http://localhost:8080
If accessing remotely, use http://<mini-pc-ip>:8080 (find your IP with ip addr show).
If it doesn’t load, check the terminal logs for errors.

Step 8: Connect to the Gensyn Testnet (Optional)

To fully participate in the swarm:
Follow the "Connecting to the Gensyn Testnet" section in the GitHub README (scroll down on the repo page).
You may need to configure an on-chain identity—check the logs or README for details.

Step 9: Stop and Restart (As Needed)
Stop the node: Press Ctrl+C in the terminal, then:
bash


docker-compose down
Restart later: From ~/rl-swarm, run:
bash


docker-compose up

Troubleshooting
Docker Permission Denied:
Check: docker ps
Fix: sudo usermod -aG docker bokiko, then newgrp docker or log out/in.
Last resort: sudo chown root:docker /var/run/docker.sock.
Port Conflict:
If 8080 is in use: sudo lsof -i :8080, kill the process (sudo kill <PID>), or edit docker-compose.yml to use another port (e.g., 8081).
Resource Issues:
Check usage: top
If your Bitcoin node is running, it might compete for CPU/memory. Stop it temporarily if needed: sudo systemctl stop bitcoind (adjust service name as applicable).
Missing Files:
Ensure docker-compose.yml exists in ~/rl-swarm (ls -l). If not, re-clone the repo.

Final Verification
Docker works: docker ps shows no errors.
Node runs: docker-compose up --build starts without permission issues.
UI loads: http://localhost:8080 displays the Swarm interface.

Notes for Your Setup
Bitcoin-Node: If this mini PC is dedicated to a Bitcoin node, ensure it has enough resources (CPU/RAM) for both. RL Swarm is lightweight, but a busy Bitcoin node could slow it down.
No GPU: The setup defaults to CPU, so you’re good there.
Persistence: After a reboot, re-run docker-compose up in ~/rl-swarm to restart the node.
