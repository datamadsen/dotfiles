# Remove symlink
echo "[vim] Remove symlink"
rm ~/.vim

# Create symlink
echo "[vim] Create symlink"
ln -s $(pwd)/ ~/.vim

echo "[vim] Done - install plugins with \`vim +PluginInstall\`"
