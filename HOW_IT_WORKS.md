# How Photon Works - Simple Explanation

## The Problem
You have multiple PCs but only one desk/monitor/keyboard/mouse. Switching between them is annoying.

## The Solution
Photon makes all your PCs appear on one screen. Press F1-F12 to instantly switch between them.

## Visual Overview

```
Your Desk:
┌─────────────┐
│  Monitor    │ ← Shows active PC
│  Keyboard   │ ← Controls active PC  
│  Mouse      │ ← Moves on active PC
└─────────────┘
       ↕
┌─────────────┐
│ Master PC   │ ← Runs Photon
│ (This one)  │
└─────────────┘
       ↕
  [F1] [F2] [F3] [F4] ← Press to switch
    ↓    ↓    ↓    ↓
┌────┐┌────┐┌────┐┌────┐
│PC 1││PC 2││PC 3││PC 4│ ← Your other PCs
└────┘└────┘└────┘└────┘
```

## Step-by-Step Process

1. **You press F2**
   - Photon disconnects from current PC
   - Connects to PC 2
   - Your monitor now shows PC 2's screen

2. **You type/click**
   - Photon captures your input
   - Sends it to PC 2
   - PC 2 responds as if you're sitting at it

3. **Video flows back**
   - PC 2's screen is compressed
   - Streamed to Master PC
   - Displayed on your monitor

## Why Docker?

Docker creates a "security bubble" around each connection:
- ❌ No internet access (can't phone home)
- ❌ No file system access (can't snoop)
- ✅ Only talks to your Master PC
- ✅ Completely isolated from everything else

## Network Flow

```
Master PC          Docker Network         Remote PCs
┌────────┐        ┌────────────┐        ┌─────────┐
│Photon  │←──────→│  Isolated  │←──────→│Sunshine │
│UI      │  LAN   │  Bridge    │  LAN   │Servers  │
└────────┘        └────────────┘        └─────────┘
                  No Internet Access!
```

## What You Need

- **Master PC**: Any Linux PC with Docker
- **Remote PCs**: Any PC that can run Sunshine
- **Network**: All PCs on same local network
- **No Internet**: Photon blocks all external connections

## Security Features

1. **Air-gapped**: No internet = no remote attacks
2. **Encrypted**: All streams are encrypted
3. **Isolated**: Each PC in its own container
4. **No tracking**: Telemetry/updates disabled

## Performance

- **Latency**: <5ms on local network
- **Quality**: Up to 4K 60fps per PC
- **Bandwidth**: ~50Mbps per active stream
- **CPU**: ~10% on modern hardware

## It's Like...

- **KVM Switch**: But over network
- **Remote Desktop**: But faster and secure
- **Game Streaming**: But for entire PCs
- **Screen Sharing**: But with full control