# Network Isolation for Sunshine/Moonlight

This setup provides complete network isolation for your Sunshine instances. **None of the Sunshine containers can access the internet** - they can only communicate with your local machine.

## How Network Isolation Works

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

## Key Security Features

1. **Complete Network Isolation**: Docker's "internal" networks have no route to the internet
2. **One-Way Communication**: Your Mac can reach the containers, but they can't reach the internet
3. **No Update Checks**: All automatic updates are disabled in the Sunshine configuration
4. **No Telemetry**: All telemetry is disabled in the Sunshine configuration 
5. **No External Connections**: Only your local machine can connect to the containers

## Usage

```bash
# One-time setup
./setup-isolated.sh

# Switch between PCs
./switch-pc.sh 1  # Switch to PC1
./switch-pc.sh 2  # Switch to PC2
./switch-pc.sh 3  # Switch to PC3
```

Then connect with Moonlight to `localhost` as usual.

## Verifying Network Isolation

To verify the containers cannot access the internet:

```bash
# Try to ping Google DNS from PC1
docker exec isolated-pc1 ping -c 1 8.8.8.8
# Should fail with network unreachable

# Try to connect to any external website
docker exec isolated-pc1 wget -q --timeout=5 https://example.com -O /dev/null
# Should fail with network unreachable
```

## How This Is Different

This approach:
- ✅ Provides TRUE network isolation (Docker's internal networks)
- ✅ Works with Moonlight's native app
- ✅ No complex builds required
- ✅ Simple switching between multiple PCs
- ✅ Sunshine containers cannot phone home or update
- ✅ No custom compiled applications needed