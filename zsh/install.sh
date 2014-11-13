#!/bin/sh
echo "Zsh"

# Give zsh_config_dig in zshrc a value.
#echo "[zsh] Search/replace zsh_config_dir placeholder with `pwd`."
#sed -e "s#zsh_config_dir=.*#zsh_config_dir=`pwd`#" zshrc > zshrc.tmp && mv zshrc.tmp zshrc

# Make sure that the value in zshrc is not committed.
#echo "[zsh] Create git filters to not ignore zsh_config_dir value on commit."
#git config filter.zsh_config_dir.smudge 'sed "s#zsh_config_dir=#zsh_config_dir=`pwd`#"'
#git config filter.zsh_config_dir.clean 'sed "s#zsh_config_dir=.*#zsh_config_dir=#"'

# Remove symlink
echo "[zsh] Remove symlinks"
rm ~/.zlogin
rm ~/.zshenv
rm ~/.zshrc
rm ~/.git-prompt.sh

# Create symlink
echo "[zsh] Create symlinks."
ln -s $(pwd)/zlogin ~/.zlogin
ln -s $(pwd)/zshenv ~/.zshenv
ln -s $(pwd)/zshrc ~/.zshrc
ln -s $(pwd)/git-prompt.sh ~/.git-prompt.sh

echo "[zsh] Done - remember to source ~/.zshrc"
