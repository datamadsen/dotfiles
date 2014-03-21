#!/bin/sh

# Replace placeholder in zshrc with completions src dir.
sed -e "s;{completions_src_dir};$(pwd)/zsh-completions/src;" zshrc > zshrc_with_completions

ln -s $(pwd)/profile ~/.profile
ln -s $(pwd)/zshrc_with_completions ~/.zshrc
ln -s $(pwd)/tmux.conf ~/.tmux.conf
