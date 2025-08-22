#!/bin/bash
# Setup script for ARM64 (Mac Silicon) isolated Sunshine instances

set -euo pipefail

echo "=== Setting up ARM64 Isolated Sunshine Instances ==="
echo

# Force dummy version for ARM64
export DOCKERFILE="Dockerfile.sunshine-dummy"

# Create config directories
mkdir -p sunshine-config/pc1
mkdir -p sunshine-config/pc2
mkdir -p sunshine-config/pc3

# Create basic sunshine config files
cat > sunshine-config/pc1/sunshine.conf << EOF
# PC1 configuration
cmd_args = []
origin_web_ui_allowed = false
upnp = false
# Disable automatic updates
autoUpdateCheck = false
# No external connections
external_ip = ""
# No telemetry
report_issue = false
EOF

# Copy the config to PC2 and PC3 with slight modifications
cp sunshine-config/pc1/sunshine.conf sunshine-config/pc2/sunshine.conf
cp sunshine-config/pc1/sunshine.conf sunshine-config/pc3/sunshine.conf

# Create script to forward ports to different PCs
cat > switch-pc.sh << 'EOF'
#!/bin/bash
# Script to switch between isolated PCs

case "$1" in
  1)
    echo "Switching to PC1 (172.30.0.10)..."
    docker exec network-bridge pkill socat
    docker exec -d network-bridge socat TCP-LISTEN:47984,fork,reuseaddr TCP:172.30.0.10:47984
    docker exec -d network-bridge socat TCP-LISTEN:47989,fork,reuseaddr TCP:172.30.0.10:47989
    docker exec -d network-bridge socat TCP-LISTEN:47990,fork,reuseaddr TCP:172.30.0.10:47990
    docker exec -d network-bridge socat UDP-LISTEN:48010,fork,reuseaddr UDP:172.30.0.10:48010
    ;;
  2)
    echo "Switching to PC2 (172.30.0.11)..."
    docker exec network-bridge pkill socat
    docker exec -d network-bridge socat TCP-LISTEN:47984,fork,reuseaddr TCP:172.30.0.11:47984
    docker exec -d network-bridge socat TCP-LISTEN:47989,fork,reuseaddr TCP:172.30.0.11:47989
    docker exec -d network-bridge socat TCP-LISTEN:47990,fork,reuseaddr TCP:172.30.0.11:47990
    docker exec -d network-bridge socat UDP-LISTEN:48010,fork,reuseaddr UDP:172.30.0.11:48010
    ;;
  3)
    echo "Switching to PC3 (172.30.0.12)..."
    docker exec network-bridge pkill socat
    docker exec -d network-bridge socat TCP-LISTEN:47984,fork,reuseaddr TCP:172.30.0.12:47984
    docker exec -d network-bridge socat TCP-LISTEN:47989,fork,reuseaddr TCP:172.30.0.12:47989
    docker exec -d network-bridge socat TCP-LISTEN:47990,fork,reuseaddr TCP:172.30.0.12:47990
    docker exec -d network-bridge socat UDP-LISTEN:48010,fork,reuseaddr UDP:172.30.0.12:48010
    ;;
  *)
    echo "Usage: $0 [1-3]"
    echo "  1: Switch to PC1"
    echo "  2: Switch to PC2"
    echo "  3: Switch to PC3"
    exit 1
    ;;
esac

echo "Ready! You can now connect Moonlight to localhost."
EOF

chmod +x switch-pc.sh

# Start the containers
echo "Starting containers..."
echo "This will take longer (10-15 min) since Sunshine needs to be built from source for ARM64"
docker-compose -f docker-compose-isolated.yml up -d

echo
echo "✓ Setup complete!"
echo
echo "Your isolated Sunshine instances are running with NO internet access."
echo
echo "To connect:"
echo "1. Install Moonlight on your Mac: brew install --cask moonlight"
echo "2. Add a PC with address 'localhost'"
echo "3. Use ./switch-pc.sh [1-3] to switch between PCs"
echo
echo "The containers are COMPLETELY isolated from the internet."
echo "Only local connections between your Mac and the containers are allowed."