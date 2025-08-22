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
