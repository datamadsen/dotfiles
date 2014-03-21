#!/bin/sh

echo "Replace placeholder in zshrc with completions src dir."
sed -e "s;{completions_src_dir};$(pwd)/zsh-completions/src;" zshrc > zshrc_with_completions

# Remove symlinks
echo "Remove symlinks:"
rm ~/.profile   && echo "  ~/.profile"
rm ~/.zshrc     && echo "  ~/.zshrc"
rm ~/.tmux.conf && echo "  ~/.tmux.conf"

# Create symlinks
echo "Create symlinks:"
ln -s $(pwd)/profile ~/.profile                 && echo "  ~/.profile"
ln -s $(pwd)/zshrc_with_completions ~/.zshrc    && echo "  ~/.zshrc"
ln -s $(pwd)/tmux.conf ~/.tmux.conf             && echo "  ~/.tmux.conf"
