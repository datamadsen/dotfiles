#!/usr/bin/env bash

echo "[farv] Installing farv system-wide..."
echo "[farv] This will install farv to system directories and requires sudo access."
echo ""

# Check if we're in the right directory
if [ ! -f "bin/farv" ] || [ ! -d "bin/handlers" ]; then
    echo "[farv] Error: Must be run from the farv directory containing bin/farv"
    exit 1
fi

# Install binary to system location (requires sudo)
echo "[farv] Installing binary to /usr/bin/"
sudo cp bin/farv /usr/bin/farv
sudo chmod +x /usr/bin/farv

# Create system directories
echo "[farv] Creating system directories"
sudo mkdir -p /usr/share/farv/{themes/{light,dark},handlers}

# Install system themes
echo "[farv] Installing system themes"
if [ -d "themes/light" ]; then
    sudo cp -r themes/light/* /usr/share/farv/themes/light/ 2>/dev/null || true
fi
if [ -d "themes/dark" ]; then
    sudo cp -r themes/dark/* /usr/share/farv/themes/dark/ 2>/dev/null || true
fi

# Install system handlers
echo "[farv] Installing system handlers"  
sudo cp bin/handlers/*.sh /usr/share/farv/handlers/
sudo chmod +x /usr/share/farv/handlers/*.sh

# Install completions to system locations
echo "[farv] Installing completion scripts"
sudo mkdir -p /usr/share/{bash-completion/completions,zsh/site-functions,fish/vendor_completions.d}

# Generate and install completions
echo "[farv] Generating completions..."
farv --generate-completion bash | sudo tee /usr/share/bash-completion/completions/farv > /dev/null
farv --generate-completion zsh | sudo tee /usr/share/zsh/site-functions/_farv > /dev/null  
farv --generate-completion fish | sudo tee /usr/share/fish/vendor_completions.d/farv.fish > /dev/null

# Create user configuration directory (no sudo needed)
echo "[farv] Setting up user configuration"
FARV_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}/farv"
mkdir -p "$FARV_CONFIG_HOME"/{themes/{light,dark},handlers}

# Create user config file
if [ ! -f "$FARV_CONFIG_HOME/config" ]; then
    echo "[farv] Creating user configuration file"
    cat > "$FARV_CONFIG_HOME/config" << 'EOF'
# Farv user configuration
# Uncomment and modify as needed

# HANDLER_TIMEOUT=10
# VERBOSE=true  
# DEFAULT_CATEGORY="dark"
EOF
fi

# Clean up old installation if it exists
echo "[farv] Cleaning up old installation"
rm -rf ~/.farv 2>/dev/null || true

echo ""
echo "[farv] Installation complete!"
echo ""
echo "System installation:"
echo "  Binary: /usr/bin/farv"
echo "  Themes: /usr/share/farv/themes/"
echo "  Handlers: /usr/share/farv/handlers/"
echo "  Completions: /usr/share/{bash-completion,zsh,fish}/"
echo ""
echo "User configuration:"
echo "  Config: $FARV_CONFIG_HOME/"
echo "  Current theme: $FARV_CONFIG_HOME/current (after first theme switch)"
echo ""
echo "Usage:"
echo "  farv list           # List available themes"
echo "  farv <theme>        # Switch to theme"
echo "  farv                # Interactive selection"
echo ""
echo "Customization:"
echo "  $FARV_CONFIG_HOME/themes/       # Add your custom themes here"
echo "  $FARV_CONFIG_HOME/handlers/     # Add/override handlers here"
echo ""
echo "Tab completion should work immediately in new shell sessions."
echo "To test: open a new terminal and try 'farv <Tab>'"