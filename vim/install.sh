echo "[vim] Remove symlink"
rm ~/.vim

echo "[vim] Create symlink"
ln -s $(pwd)/ ~/.vim

echo "[vim] Install Plug"
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

echo "[vim] Done."
