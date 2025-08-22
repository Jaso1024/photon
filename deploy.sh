#!/bin/bash
# Photon deployment script

set -euo pipefail

echo "=== Photon Secure Multi-PC Control System ==="
echo

# Check prerequisites
check_command() {
    if ! command -v "$1" &> /dev/null; then
        echo "ERROR: $1 is not installed. Please install it first."
        exit 1
    fi
}

echo "Checking prerequisites..."
check_command docker
check_command docker-compose
check_command openssl

# Apply security patches to Sunshine
echo "Applying security patches to Sunshine..."
if [ -f "patches/sunshine-security.patch" ]; then
    cd Sunshine
    git apply ../patches/sunshine-security.patch || echo "Patch already applied or failed"
    cd ..
fi

# Build containers
echo "Building Docker containers..."
docker-compose build

# Generate certificates
echo "Generating secure certificates..."
chmod +x scripts/secure-pairing.sh
docker run --rm -v "$(pwd)/certs:/photon/certs" ubuntu:22.04 /bin/bash -c "
    apt-get update && apt-get install -y openssl && \
    /photon/certs/../scripts/secure-pairing.sh
"

# Start containers
echo "Starting Photon containers..."
docker-compose up -d

# Wait for containers to be ready
echo "Waiting for containers to initialize..."
sleep 10

# Show status
echo
echo "=== Deployment Complete ==="
echo
docker-compose ps
echo
echo "Photon Master UI should be accessible on your display."
echo "Press Ctrl+[1-9] for quick switching between PCs."
echo
echo "To stop Photon: docker-compose down"
echo "To view logs: docker-compose logs -f"