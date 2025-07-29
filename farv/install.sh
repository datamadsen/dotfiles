#!/usr/bin/env bash

# Remove old symlink
echo "[farv] Remove old symlink"
rm -f ~/.farv

# Create symlink
echo "[farv] Create symlink"
ln -s "$(pwd)" ~/.farv

# Create directory structure for modular scripts
echo "[farv] Create bin directory structure"
mkdir -p ~/.farv/bin/handlers

# Copy and make scripts executable
echo "[farv] Install modular farv scripts"
cp bin/farv ~/.farv/bin/farv
cp bin/handlers/*.sh ~/.farv/bin/handlers/
chmod +x ~/.farv/bin/farv
chmod +x ~/.farv/bin/handlers/*.sh

# Update PATH if needed
if [[ ":$PATH:" != *":$HOME/.farv/bin:"* ]]; then
    echo "[farv] Adding ~/.farv/bin to PATH in ~/.zshrc"
    echo '' >> ~/.zshrc
    echo '# farv theme manager' >> ~/.zshrc
    echo 'export PATH="$HOME/.farv/bin:$PATH"' >> ~/.zshrc
    echo "[farv] Please restart your shell or run: source ~/.zshrc"
fi

echo "[farv] Done - modular farv is now installed"
echo "[farv] The farv command is available and supports tab completion"