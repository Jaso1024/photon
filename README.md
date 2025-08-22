# Photon - Secure Multi-PC Remote Control System

Photon enables secure remote control of multiple PCs from a single master interface, using Sunshine/Moonlight with complete network isolation via Docker containers.

## How It Works

1. **Master PC** runs the Photon Master UI - a Qt application that manages connections to multiple remote PCs
2. **Remote PCs** run Sunshine in isolated Docker containers with no internet access
3. **Security** - All external network access is blocked at the container level
4. **Control** - Switch between PCs instantly using keyboard shortcuts (F1-F12)

## Quick Start

### Prerequisites for macOS

```bash
# Install XQuartz for GUI support
brew install --cask xquartz
# Logout and login again after installing

# Install Docker Desktop
brew install --cask docker
```

### 1. Setup Master PC

```bash
# Clone the repository
git clone https://github.com/Jaso1024/photon.git
cd photon

# For macOS users: Use the start script
./start-photon.sh

# For build issues: Use simplified version
docker-compose -f docker-compose-simple.yml up -d
```

### 2. Configure Remote PCs

Edit `docker-compose.yml` to add your remote PCs:

```yaml
  remote-pc-1:
    container_name: photon-remote-1
    environment:
      - DISPLAY_NAME=Gaming PC
      - SUNSHINE_USER=gamer
      - SUNSHINE_PASS=securepass123
    networks:
      photon-net:
        ipv4_address: 172.20.0.10
```

### 3. Start the System

```bash
# Start all containers
docker-compose up -d

# Launch Photon Master UI
docker exec -it photon-master /photon/photon-master
```

### 4. Using Photon

- **F1-F12**: Switch between remote PCs instantly
- **ESC**: Disconnect from current PC
- **Mouse/Keyboard**: Automatically captured when connected
- **Audio/Video**: Streamed from the active PC

## Architecture

```
┌─────────────────┐
│  Photon Master  │
│   (Master PC)   │
└────────┬────────┘
         │
    ┌────┴────┐
    │ Docker  │
    │ Network │ (Isolated - No Internet)
    └────┬────┘
         │
    ┌────┴────┬──────────┬──────────┐
    │         │          │          │
┌───▼───┐ ┌──▼───┐ ┌───▼───┐ ┌───▼───┐
│ PC 1  │ │ PC 2 │ │ PC 3  │ │ PC 4  │
│Sunshine│ │Sunshine│ │Sunshine│ │Sunshine│
└───────┘ └──────┘ └───────┘ └───────┘
```

## Security Features

- **Complete Network Isolation**: Containers cannot access the internet
- **No Telemetry**: Update checks and analytics disabled
- **Certificate-based Auth**: Secure pairing between master and remotes
- **Container Sandboxing**: Each remote PC runs in its own container

## Requirements

- Docker 20.10+
- Docker Compose 2.0+
- Qt6 (for Master UI)
- Linux host (Ubuntu 22.04 recommended)

## Configuration

### Adding Remote PCs

1. Edit `docker-compose.yml`
2. Copy an existing remote-pc service block
3. Update:
   - Container name
   - DISPLAY_NAME
   - IP address (must be unique in 172.20.0.0/16)
   - Credentials

### Network Settings

- Default subnet: 172.20.0.0/16
- Master: 172.20.0.2
- Remotes: 172.20.0.10+

### Performance Tuning

Edit container resources in `docker-compose.yml`:

```yaml
deploy:
  resources:
    limits:
      cpus: '4'
      memory: 8G
```

## Troubleshooting

### Cannot Connect to Remote PC

1. Check container status: `docker ps`
2. Verify network: `docker network inspect photon_photon-net`
3. Check logs: `docker logs photon-remote-1`

### Performance Issues

1. Ensure GPU passthrough is enabled
2. Check network latency between containers
3. Adjust streaming quality in Sunshine settings

### Security Verification

Run security check:
```bash
./scripts/verify-security.sh
```

## License

This project uses components from:
- Sunshine (GPL-3.0)
- Moonlight (GPL-3.0)