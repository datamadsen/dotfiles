echo "[vim] Remove symlink"
rm ~/.vim

echo "[vim] Create symlink"
ln -s $(pwd)/ ~/.vim

echo "[vim] Clone vundle"
git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/vundle

echo "[vim] Done - install plugins with \`vim +PluginInstall\`"
