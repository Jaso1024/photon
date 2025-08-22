#!/bin/bash
# Start script for Photon with proper environment setup

set -euo pipefail

echo "=== Starting Photon ==="
echo

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Detected macOS"
    
    # Check if XQuartz is installed
    if ! command -v xquartz &> /dev/null; then
        echo "ERROR: XQuartz is required for GUI support on macOS"
        echo "Install with: brew install --cask xquartz"
        echo "Then logout and login again"
        exit 1
    fi
    
    # Set DISPLAY for macOS
    export DISPLAY=host.docker.internal:0
    
    # Ensure XQuartz allows connections
    echo "Configuring XQuartz..."
    defaults write org.xquartz.X11 enable_iglx -bool true
    defaults write org.xquartz.X11 nolisten_tcp -bool false
    
    # Allow connections from Docker
    xhost +localhost 2>/dev/null || true
    
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "Detected Linux"
    
    # Use the existing DISPLAY or default
    export DISPLAY=${DISPLAY:-:0}
    
    # Allow Docker to connect to X11
    xhost +local:docker 2>/dev/null || true
else
    echo "Unsupported OS: $OSTYPE"
    exit 1
fi

echo "DISPLAY set to: $DISPLAY"
echo

# Create .env file for docker-compose
cat > .env <<EOF
DISPLAY=$DISPLAY
EOF

# Start containers
echo "Starting Docker containers..."
docker-compose up -d

echo
echo "✓ Photon started successfully!"
echo
echo "To view logs: docker-compose logs -f"
echo "To stop: docker-compose down"
echo
echo "Launch Photon Master UI with:"
echo "  docker exec -it photon-master /photon-master/build/photon-master"