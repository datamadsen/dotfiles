#!/bin/sh
echo "Zsh"

# Give zsh_config_dig in zshrc a value.
echo " Search/replace zsh_config_dir placeholder with `pwd`."
sed -e "s#zsh_config_dir=.*#zsh_config_dir=`pwd`#" zshrc > zshrc.tmp && mv zshrc.tmp zshrc

# Make sure that the value in zshrc is not committed.
echo " Create git filters to not ignore zsh_config_dir value on commit."
git config filter.zsh_config_dir.smudge 'sed "s#zsh_config_dir=#zsh_config_dir=`pwd`#"'
git config filter.zsh_config_dir.clean 'sed "s#zsh_config_dir=.*#zsh_config_dir=#"'

# Remove symlink
echo " Remove symlink."
rm ~/.zshrc

# Create symlink
echo " Create symlink."
ln -s $(pwd)/zshrc ~/.zshrc

echo " Done with zsh - remember to source ~/.zshrc"
