#!/bin/bash
# Simple native setup for macOS - no Docker needed!

echo "=== Simple Multi-PC Control Setup for macOS ==="
echo

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install Moonlight
echo "Installing Moonlight..."
brew install --cask moonlight

# Create launcher script
echo "Creating PC launcher script..."
cat > ~/bin/pc-control.sh << 'EOF'
#!/bin/bash
# Simple PC control launcher

# Configure your PCs here
PC1_IP="192.168.1.100"
PC2_IP="192.168.1.101"
PC3_IP="192.168.1.102"
PC4_IP="192.168.1.103"

case "$1" in
    1) echo "Connecting to PC 1..."; open -a Moonlight --args stream $PC1_IP Desktop ;;
    2) echo "Connecting to PC 2..."; open -a Moonlight --args stream $PC2_IP Desktop ;;
    3) echo "Connecting to PC 3..."; open -a Moonlight --args stream $PC3_IP Desktop ;;
    4) echo "Connecting to PC 4..."; open -a Moonlight --args stream $PC4_IP Desktop ;;
    list) 
        echo "Available PCs:"
        echo "  1. PC at $PC1_IP"
        echo "  2. PC at $PC2_IP"
        echo "  3. PC at $PC3_IP"
        echo "  4. PC at $PC4_IP"
        ;;
    *) 
        echo "Usage: pc [1-4|list]"
        echo "  pc 1     - Connect to PC 1"
        echo "  pc 2     - Connect to PC 2"
        echo "  pc list  - List all PCs"
        ;;
esac
EOF

chmod +x ~/bin/pc-control.sh
mkdir -p ~/bin

# Create alias
echo 'alias pc="~/bin/pc-control.sh"' >> ~/.zshrc

echo
echo "✓ Setup complete!"
echo
echo "Next steps:"
echo "1. Install Sunshine on each PC you want to control:"
echo "   https://github.com/LizardByte/Sunshine/releases"
echo
echo "2. Edit ~/bin/pc-control.sh to add your PC IP addresses"
echo
echo "3. Use the 'pc' command to connect:"
echo "   pc 1  - Connect to PC 1"
echo "   pc 2  - Connect to PC 2"
echo "   etc."
echo
echo "4. Optional: Set up macOS keyboard shortcuts in System Preferences"
echo "   to run 'pc 1', 'pc 2', etc."