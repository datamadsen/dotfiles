#!/bin/sh

# Remove symlink
echo "[zsh] Remove symlinks"
rm ~/.zlogin
rm ~/.zshenv
rm ~/.zshrc
rm ~/.git-prompt.sh
rm ~/.aliases

# Create symlink
echo "[zsh] Create symlinks"
ln -s $(pwd)/zlogin ~/.zlogin
ln -s $(pwd)/zshenv ~/.zshenv
ln -s $(pwd)/zshrc ~/.zshrc
ln -s $(pwd)/git-prompt.sh ~/.git-prompt.sh
ln -s $(pwd)/aliases ~/.aliases

echo "[zsh] Done - remember to source ~/.zshrc"
