#!/bin/bash
# Interactive setup script for adding remote PCs to Photon

set -euo pipefail

echo "=== Photon Remote PC Setup ==="
echo

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   echo "This script should not be run as root"
   exit 1
fi

# Function to validate IP address
validate_ip() {
    local ip=$1
    if [[ $ip =~ ^172\.20\.0\.([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])$ ]]; then
        return 0
    else
        return 1
    fi
}

# Function to check if IP is already used
check_ip_used() {
    local ip=$1
    if grep -q "$ip" docker-compose.yml 2>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Get next available IP
get_next_ip() {
    local last_ip=9
    for i in {10..250}; do
        if ! check_ip_used "172.20.0.$i"; then
            echo "172.20.0.$i"
            return
        fi
    done
    echo ""
}

# Collect information
echo "Enter display name for this PC (e.g., Gaming PC):"
read -r display_name

echo "Enter username for Sunshine access:"
read -r username

echo "Enter password for Sunshine access:"
read -s -r password
echo

# Get next available IP
suggested_ip=$(get_next_ip)
if [[ -z "$suggested_ip" ]]; then
    echo "Error: No available IP addresses in the 172.20.0.0/24 range"
    exit 1
fi

echo "Suggested IP address: $suggested_ip"
echo "Press Enter to accept or type a different IP (172.20.0.10-250):"
read -r custom_ip

if [[ -n "$custom_ip" ]]; then
    if validate_ip "$custom_ip"; then
        if check_ip_used "$custom_ip"; then
            echo "Error: IP $custom_ip is already in use"
            exit 1
        fi
        ip_address="$custom_ip"
    else
        echo "Error: Invalid IP address. Must be in range 172.20.0.10-250"
        exit 1
    fi
else
    ip_address="$suggested_ip"
fi

# Generate container name
container_name=$(echo "$display_name" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g')
container_name="photon-${container_name}"

# Create service entry
service_entry="
  ${container_name}:
    extends:
      service: sunshine-base
    container_name: ${container_name}
    hostname: ${container_name}
    environment:
      - DISPLAY_NAME=${display_name}
      - SUNSHINE_USER=${username}
      - SUNSHINE_PASS=${password}
    networks:
      photon-net:
        ipv4_address: ${ip_address}"

# Backup docker-compose.yml
cp docker-compose.yml docker-compose.yml.backup

# Add service to docker-compose.yml
# Find the line with "volumes:" and insert before it
awk -v entry="$service_entry" '
/^volumes:/ && !inserted {
    print entry
    print ""
    inserted = 1
}
{ print }
' docker-compose.yml > docker-compose.yml.tmp

mv docker-compose.yml.tmp docker-compose.yml

echo
echo "✓ Remote PC configured successfully!"
echo
echo "Details:"
echo "  Name: $display_name"
echo "  Container: $container_name"
echo "  IP: $ip_address"
echo "  Username: $username"
echo
echo "To apply changes:"
echo "  1. docker-compose down"
echo "  2. docker-compose up -d"
echo
echo "The new PC will be available in Photon Master after restart."