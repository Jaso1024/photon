# Photon - Network-Isolated Multi-PC Control

Photon lets you control multiple PCs securely from a single Mac, with complete network isolation to prevent any internet connectivity.

## Usage

```bash
# For Mac Silicon (ARM64)
./setup-arm.sh

# For Intel Macs (x86_64)
./setup-isolated.sh
```

This creates:
- Multiple isolated Sunshine containers with NO internet access
- A secure port-forwarding bridge to your Mac
- A simple script to switch between PCs

## Switching Between PCs

```bash
./switch-pc.sh 1  # Connect to PC1
./switch-pc.sh 2  # Connect to PC2
./switch-pc.sh 3  # Connect to PC3
```

Then connect with Moonlight to `localhost`.

## Verifying Network Isolation

The containers have NO internet access. You can verify this:

```bash
# Try to ping Google DNS (should fail)
docker exec isolated-pc1 ping -c 1 8.8.8.8
```

## Architecture

```
┌────────────────────┐
│                    │
│    Your Mac        │◄───── Internet (allowed)
│    (Moonlight)     │
│                    │
└─────────┬──────────┘
          │
          │ Local Only
          │
┌─────────▼──────────┐
│  Network Bridge    │
│  (Port Forwarding) │
└─────────┬──────────┘
          │
          │ 
┌─────────▼──────────┐
│ Internal Network   │
│ (Docker)           │◄───── Internet (BLOCKED)
└─────────┬──────────┘
          │
   ┌──────┴───────┐
   │              │
┌──▼─┐        ┌───▼─┐
│PC 1│        │PC 2 │
└────┘        └─────┘
```

## Features

1. **True Network Isolation**: Docker's internal network blocks all internet access
2. **Cross-Platform**: Works on both Mac Silicon (ARM64) and Intel Macs (x86_64)
3. **Easy Switching**: Switch between multiple PCs with a simple command
4. **Secure**: No update checks, no telemetry, no external connections

## Technical Details

- For ARM64, we build Sunshine from source
- For x86_64, we use the official AppImage
- The network bridge only forwards specific ports
- All containers are completely isolated from the internet