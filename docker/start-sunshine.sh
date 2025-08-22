#!/bin/bash
# Start script for Sunshine with security checks

# Verify no external network routes (only Docker internal network)
if ip route | grep -v "172\.\|10\.\|192\.168\." | grep -q "default"; then
    echo "ERROR: External network access detected. Aborting for security."
    exit 1
fi

# Set secure environment
export SUNSHINE_UPNP_ENABLED=false
export SUNSHINE_PUBLISH_ENABLED=false

# Remove any config that might enable external connections
CONFIG_DIR="$HOME/.config/sunshine"
mkdir -p "$CONFIG_DIR"

# Create minimal secure config if doesn't exist
if [ ! -f "$CONFIG_DIR/sunshine.conf" ]; then
    cat > "$CONFIG_DIR/sunshine.conf" << EOF
# Photon secure configuration
upnp = false
publish_enabled = false
origin_web_ui_allowed = lan
origin_pin_allowed = lan
log_level = warning
min_log_level = warning
EOF
fi

# Start Sunshine
cd /sunshine/build
exec ./sunshine --config "$CONFIG_DIR/sunshine.conf"