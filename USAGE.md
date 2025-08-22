# How to Use Photon - Step by Step

## Overview

Photon lets you control multiple PCs from one keyboard/mouse/monitor. Press F1-F12 to instantly switch between PCs.

## Initial Setup (One Time)

### 1. Install Prerequisites

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install docker.io docker-compose

# Add yourself to docker group
sudo usermod -aG docker $USER
# Log out and back in for this to take effect
```

### 2. Clone and Deploy Photon

```bash
# Get the code
git clone https://github.com/yourusername/photon.git
cd photon

# Run deployment
./deploy.sh
```

### 3. Add Your Remote PCs

For each PC you want to control:

```bash
./setup-remote-pc.sh
```

Enter:
- Display name (e.g., "Gaming PC")
- Username (create a new one)
- Password (make it secure)
- Accept suggested IP or enter custom

### 4. Start Everything

```bash
docker-compose up -d
```

## Daily Usage

### Starting Photon

1. On your master PC, open terminal:
```bash
cd photon
docker-compose up -d
```

2. Launch the Photon UI:
```bash
docker exec -it photon-master photon-master
```

### Controlling Remote PCs

- **F1-F12**: Switch to PC 1-12 instantly
- **ESC**: Disconnect from current PC
- **All input**: Automatically sent to active PC

### Example Workflow

1. Press **F1** → Connected to Gaming PC
2. Play games, use apps normally
3. Press **F2** → Instantly on Work PC  
4. Check emails, edit documents
5. Press **F3** → Now on Media Server
6. Start a movie
7. Press **ESC** → Back to master PC

### Shutting Down

```bash
# Stop all containers
docker-compose down

# Or just close the Photon Master window
```

## What Actually Happens

1. **Master PC** runs Photon UI (shows which PC is active)
2. **Each Remote PC** appears as a Sunshine game stream
3. **Network isolation** ensures no internet access
4. **Input** is captured and sent to active PC only
5. **Video/Audio** streams from active PC to your monitor

## Tips

- **Low Latency**: Use wired ethernet for all PCs
- **Quality**: Adjust bitrate in config for each PC
- **Security**: Change default passwords immediately
- **Performance**: Give containers enough CPU/RAM

## Common Tasks

### Add Another PC
```bash
./setup-remote-pc.sh
docker-compose restart
```

### Remove a PC
Edit `docker-compose.yml` and remove the PC section

### Change PC Order
Edit `docker-compose.yml` and rearrange sections

### View Logs
```bash
docker logs photon-gaming-pc
```

## Troubleshooting

**Can't connect to a PC?**
```bash
# Check if container is running
docker ps | grep photon

# Test connection
docker exec photon-master ping <pc-ip>
```

**Black screen?**
- Ensure remote PC has monitor connected or dummy plug
- Check Sunshine is running: `docker logs <container>`

**Input lag?**
- Switch to wired connection
- Reduce streaming quality in config
- Check CPU usage on remote PC