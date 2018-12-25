#!/bin/sh

# Remove symlink
echo "[zsh] Remove symlinks"
rm ~/.zlogin
rm ~/.zshenv
rm ~/.zshrc
rm ~/.git-prompt.sh
rm ~/.ssh-start.sh
rm ~/.aliases
rm ~/.utilities/prompt_pure_setup
rm ~/.utilities/async

# Create symlink
echo "[zsh] Create symlinks"
ln -s $(pwd)/zlogin ~/.zlogin
ln -s $(pwd)/zshenv ~/.zshenv
ln -s $(pwd)/zshrc ~/.zshrc
ln -s $(pwd)/git-prompt.sh ~/.git-prompt.sh
ln -s $(pwd)/aliases ~/.aliases
ln -s $(pwd)/ssh-start.sh ~/.ssh-start.sh
ln -s $(pwd)/pure.zsh ~/.utilities/prompt_pure_setup
ln -s $(pwd)/async.zsh ~/.utilities/async

echo "[zsh] Done - remember to source ~/.zshrc"
