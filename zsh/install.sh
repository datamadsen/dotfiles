#!/bin/sh

# Remove symlink
echo "[zsh] Remove symlinks"
rm ~/.zlogin
rm ~/.zshenv
rm ~/.zshrc
rm ~/.git-prompt.sh
rm ~/.ssh-start.sh
rm ~/.aliases
rm /usr/local/share/zsh/site-functions/prompt_pure_setup
rm /usr/local/share/zsh/site-functions/async

# Create symlink
echo "[zsh] Create symlinks"
ln -s $(pwd)/zlogin ~/.zlogin
ln -s $(pwd)/zshenv ~/.zshenv
ln -s $(pwd)/zshrc ~/.zshrc
ln -s $(pwd)/git-prompt.sh ~/.git-prompt.sh
ln -s $(pwd)/aliases ~/.aliases
ln -s $(pwd)/ssh-start.sh ~/.ssh-start.sh
ln -s $(pwd)/pure.zsh /usr/local/share/zsh/site-functions/prompt_pure_setup
ln -s $(pwd)/async.zsh /usr/local/share/zsh/site-functions/async

echo "[zsh] Done - remember to source ~/.zshrc"
