# Gensyn Node Update Guide

## 🔄 Before Updating

> **CRITICAL**: Always backup your files before updating!

### 1. Backup Your Files

```bash
~/backup_gensyn.sh
```

### 2. Stop Current Node

```bash
tmux attach-session -t gensyn
```

Stop the process with `Ctrl + C`, then detach with `Ctrl + B` followed by `D`

### 3. Kill Tmux Session

```bash
tmux kill-session -t gensyn
```

## 📥 Update Process

### Method 1: Automated Update (Recommended)

```bash
cd $HOME
wget -O update_gensyn.sh https://raw.githubusercontent.com/bokiko/RL-Swarm-node/main/update.sh
chmod +x update_gensyn.sh
./update_gensyn.sh
```

### Method 2: Manual Update

#### Step 1: Backup Current Installation

```bash
cp -r ~/rl-swarm ~/rl-swarm_backup_$(date +%Y%m%d)
```

#### Step 2: Update Repository

```bash
cd $HOME
rm -rf RL-Swarm-node
git clone https://github.com/bokiko/RL-Swarm-node.git
chmod +x RL-Swarm-node/gensyn.sh
```

#### Step 3: Update System Dependencies

```bash
sudo apt update && sudo apt upgrade -y
```

#### Step 4: Update Python Packages

```bash
pip3 install --upgrade pip
```

#### Step 5: Restore Your Files

If you have backed up files, restore them:

```bash
cp ~/gensyn_backup_*/swarm.pem ~/rl-swarm/ 2>/dev/null || echo "swarm.pem not found in backup"
cp ~/gensyn_backup_*/userData.json ~/rl-swarm/ 2>/dev/null || echo "userData.json not found"
cp ~/gensyn_backup_*/userApiKey.json ~/rl-swarm/ 2>/dev/null || echo "userApiKey.json not found"
```

#### Step 6: Set Proper Permissions

```bash
chmod 600 ~/rl-swarm/swarm.pem
```

#### Step 7: Restart Node

```bash
~/start_gensyn.sh
```

## 🔧 Update System Dependencies

### Update Node.js

```bash
curl -sSL https://raw.githubusercontent.com/bokiko/gensyn-guide/main/node.sh | bash
source ~/.bashrc
```

### Update Python

```bash
sudo apt install -y python3.10 python3.10-pip python3.10-venv
```

### Update System Packages

```bash
sudo apt update && sudo apt upgrade -y
sudo apt autoremove -y
```

## ✅ Verify Update

### 1. Check Node Status

```bash
tmux attach-session -t gensyn
```

Look for:
- No error messages
- Peer-ID appearing in logs
- Normal swarm operation

### 2. Check Versions

```bash
python3 --version
node --version
npm --version
```

### 3. Test Backup

```bash
~/backup_gensyn.sh
```

## 🆘 Troubleshooting Updates

### Issue: Node Won't Start After Update

**Solution:**
```bash
cd ~/rl-swarm
rm -rf venv/
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
./run_rl_swarm.sh
```

### Issue: Missing Dependencies

**Solution:**
```bash
sudo apt install -y python3 python3-venv python3-pip curl wget tmux git lsof nano unzip iproute2 build-essential
```

### Issue: Permission Errors

**Solution:**
```bash
sudo chown -R $USER:$USER ~/rl-swarm
chmod 600 ~/rl-swarm/swarm.pem
chmod +x ~/rl-swarm/run_rl_swarm.sh
```

### Issue: Tmux Session Conflicts

**Solution:**
```bash
tmux kill-server
tmux new-session -d -s gensyn
cd ~/rl-swarm && ./run_rl_swarm.sh
```

## 📋 Update Checklist

Before updating:
- [ ] Backup all important files
- [ ] Note your current Peer-ID
- [ ] Stop running node properly
- [ ] Check available disk space

During update:
- [ ] Follow steps in order
- [ ] Don't skip backup steps
- [ ] Verify each step completes
- [ ] Check for error messages

After update:
- [ ] Verify node starts correctly
- [ ] Check logs for errors
- [ ] Confirm Peer-ID matches
- [ ] Test backup functionality
- [ ] Monitor performance

## 🔄 Rollback Procedure

If update fails and you need to rollback:

### 1. Restore Backup

```bash
tmux kill-session -t gensyn
rm -rf ~/rl-swarm
cp -r ~/rl-swarm_backup_* ~/rl-swarm
```

### 2. Fix Permissions

```bash
chmod 600 ~/rl-swarm/swarm.pem
chmod +x ~/rl-swarm/run_rl_swarm.sh
```

### 3. Restart Node

```bash
~/start_gensyn.sh
```

## 📝 Update Notes

- Always backup before updating
- Updates may require node restart
- Some updates may need fresh installation
- Keep multiple backup copies
- Monitor node performance after updates

## 🆔 Version History

| Date | Version | Changes |
|------|---------|---------|
| 2025-05-27 | v1.0 | Initial release |

---

**Created by [bokiko](https://github.com/bokiko) | Follow for more guides**