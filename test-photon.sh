#!/bin/bash
# Quick test script for Photon

echo "=== Photon Test Setup ==="
echo
echo "This will set up a minimal test environment."
echo

# Use the simplified docker-compose
docker-compose -f docker-compose-simple.yml up -d

echo
echo "✓ Test environment started!"
echo
echo "To connect to the test container:"
echo "  docker exec -it photon-master /bin/bash"
echo
echo "To stop:"
echo "  docker-compose -f docker-compose-simple.yml down"