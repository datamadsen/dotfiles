#!/bin/sh
chsh --shell $(which zsh)

# Remove symlink
echo "[zsh] Remove symlinks"
rm ~/.zlogin
rm ~/.zshenv
rm ~/.zshrc
rm ~/.git-prompt.sh
rm ~/.ssh-start.sh
rm ~/.aliases
rm ~/.zsh_functions
rm ~/.utilities/prompt_pure_setup
rm ~/.utilities/async
rm ~/.utilities/keys.sh

# Create symlink
echo "[zsh] Create symlinks"
ln -s "$(pwd)/zlogin" ~/.zlogin
ln -s "$(pwd)/zshenv" ~/.zshenv
ln -s "$(pwd)/zshrc" ~/.zshrc
ln -s "$(pwd)/zsh_functions" ~/.zsh_functions
ln -s "$(pwd)/git-prompt.sh" ~/.git-prompt.sh
ln -s "$(pwd)/aliases" ~/.aliases
ln -s "$(pwd)/ssh-start.sh" ~/.ssh-start.sh
ln -s "$(pwd)/pure.zsh" ~/.utilities/prompt_pure_setup
ln -s "$(pwd)/async.zsh" ~/.utilities/async
ln -s "$(pwd)/keys.sh" ~/.utilities/keys.sh

# Create zsh history directory
echo "[zsh] Create history directory"
mkdir -p ~/.cache/zsh

echo "[zsh] Done - remember to source ~/.zshrc"
