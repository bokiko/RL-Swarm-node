# Gensyn Testnet Node Guide

## 💻 System Requirements

| Requirement | Details |
|---|---|
| CPU Architecture | arm64 or amd64 |
| Recommended RAM | 24 GB |
| CUDA Devices (Recommended) | RTX 3090, RTX 4070, RTX 4090, A100, H100 |
| Python Version | Python >= 3.10 |
| Operating System | Ubuntu 20.04+ / Debian 11+ |

> **Note**: GPU is recommended for better performance and higher winning rates. You can run without GPU but may experience OOM errors and lower success rates.

## 📥 Installation

### Step 1: Update System and Install Dependencies

```bash
sudo apt update && sudo apt upgrade -y
```

```bash
sudo apt install -y python3 python3-venv python3-pip curl wget tmux git lsof nano unzip iproute2 build-essential
```

### Step 2: Install Node.js and npm

```bash
curl -sSL https://raw.githubusercontent.com/bokiko/RL-Swarm-node/main/node.sh | bash
```

**Restart your terminal or run:**
```bash
source ~/.bashrc
```

### Step 3: Verify Installations

```bash
python3 --version
node --version
npm --version
```

### Step 4: Create Tmux Session

```bash
tmux new-session -d -s gensyn
```

### Step 5: Attach to Tmux Session

```bash
tmux attach-session -t gensyn
```

### Step 6: Clone and Run Gensyn

```bash
cd $HOME && rm -rf gensyn-testnet && git clone https://github.com/zunxbt/gensyn-testnet.git && chmod +x gensyn-testnet/gensyn.sh && ./gensyn-testnet/gensyn.sh
```

### Step 7: Configure Swarm

When prompted:
```
Would you like to push models you train in the RL swarm to the Hugging Face Hub? [y/N]
```
**Type:** `N` and press Enter

### Step 8: Detach from Tmux Session

Once you see the swarm interface running, detach from tmux:
- Press `Ctrl + B` then press `D`

## 🔄 Managing Your Node

### Check Node Status

**Attach to tmux session:**
```bash
tmux attach-session -t gensyn
```

**Detach from tmux session:**
- Press `Ctrl + B` then press `D`

### List All Tmux Sessions

```bash
tmux list-sessions
```

### Kill Tmux Session (if needed)

```bash
tmux kill-session -t gensyn
```

## 🔄️ Backup Your swarm.pem File

> **CRITICAL**: Back up your `swarm.pem` file immediately after setup. If you lose this file, your contribution will be lost forever.

### Method 1: Automated Backup (Recommended)

```bash
cd ~/rl-swarm
[ -f backup.sh ] && rm backup.sh; curl -sSL -O https://raw.githubusercontent.com/bokiko/RL-Swarm-node/main/backup.sh && chmod +x backup.sh && ./backup.sh
```

This will generate URLs to download:
- `swarm.pem` (REQUIRED)
- `userData.json` (Optional)
- `userApiKey.json` (Optional)

**Visit the provided URL and press `Ctrl + S` to save these files to your local computer.**

### Method 2: Manual Backup

```bash
cd ~/rl-swarm
nano backup_files.sh
```

**Add this content:**
```bash
#!/bin/bash
echo "Creating backup directory..."
mkdir -p ~/gensyn_backup
cp swarm.pem ~/gensyn_backup/
cp userData.json ~/gensyn_backup/ 2>/dev/null || echo "userData.json not found"
cp userApiKey.json ~/gensyn_backup/ 2>/dev/null || echo "userApiKey.json not found"
echo "Backup completed in ~/gensyn_backup/"
ls -la ~/gensyn_backup/
```

**Make executable and run:**
```bash
chmod +x backup_files.sh
./backup_files.sh
```

## 🟢 Node Status Monitoring

### 1. Check Logs

```bash
tmux attach-session -t gensyn
```

Look for your **Peer-ID** in the logs (you'll see it frequently)

### 2. Check Wins Online

1. Visit: [https://gensyn-node.vercel.app/](https://gensyn-node.vercel.app/)
2. Enter your **Peer-ID** from the logs
3. Check your win count - higher is better

### 3. Get Your Node IP

```bash
curl -s https://ipinfo.io/ip
```

## 🔄 Auto-Start Configuration

### Create Auto-Start Script

```bash
nano ~/start_gensyn.sh
```

**Add this content:**
```bash
#!/bin/bash
cd ~/rl-swarm
tmux new-session -d -s gensyn './run_rl_swarm.sh'
echo "Gensyn node started in tmux session 'gensyn'"
echo "Use 'tmux attach-session -t gensyn' to view logs"
```

**Make executable:**
```bash
chmod +x ~/start_gensyn.sh
```

### Add to System Startup (Optional)

```bash
crontab -e
```

**Add this line:**
```bash
@reboot /home/$USER/start_gensyn.sh
```

## ⚠️ Troubleshooting

### 🔴 Issue: Daemon Failed to Start in 15.0 Seconds

**Fix the timeout:**
```bash
nano $(python3 -c "import hivemind.p2p.p2p_daemon as m; print(m.__file__)")
```

**Find this line:**
```python
startup_timeout: float = 15,
```

**Change it to:**
```python
startup_timeout: float = 120,
```

**Save the file:**
- Press `Ctrl + X`
- Press `Y`
- Press `Enter`

**Restart the swarm:**
```bash
cd ~/rl-swarm
./run_rl_swarm.sh
```

### 🔴 Issue: Connected EOA Address Shows 0x0000000000000000000000000000000000000000

This means your contribution is not being recorded.

**Solution:**
1. Stop the current node
2. Delete the existing `swarm.pem` file
3. Start fresh with a new email address
4. Re-run the installation

### 🔴 Issue: Out of Memory (OOM) Errors

**If running without GPU:**
1. Increase system swap space
2. Close unnecessary applications
3. Consider using a system with more RAM

### 🔴 Issue: Tmux Session Lost

**Recover or recreate:**
```bash
tmux list-sessions
tmux attach-session -t gensyn
```

**If session doesn't exist:**
```bash
cd ~/rl-swarm
tmux new-session -d -s gensyn './run_rl_swarm.sh'
```

## 📋 Useful Commands

### General Tmux Commands
```bash
# List all sessions
tmux list-sessions

# Create new session
tmux new-session -d -s session_name

# Attach to session
tmux attach-session -t session_name

# Kill session
tmux kill-session -t session_name

# Detach from current session
Ctrl + B, then D
```

### Node Management
```bash
# Check if node is running
ps aux | grep python3

# Check system resources
htop

# Check disk space
df -h

# Check network connectivity
ping google.com
```

## 🆘 Support

If you encounter issues:

1. **Check logs** first by attaching to tmux session
2. **Verify all dependencies** are installed correctly
3. **Ensure sufficient system resources** (RAM, disk space)
4. **Check network connectivity**
5. **Review troubleshooting section** above

## 📝 Notes

- Always keep your `swarm.pem` file backed up
- Monitor your node regularly for optimal performance
- Higher GPU performance typically leads to better win rates
- Keep your system updated for security and performance

---

**Created by [bokiko](https://github.com/bokiko) | Follow for more guides**
