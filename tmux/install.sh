# Remove symlink
echo " Remove symlink."
rm ~/.tmux.conf

# Create symlink
echo " Create symlink."
ln -s $(pwd)/tmux.conf ~/.tmux.conf

echo " Done with tmux - remember to source ~/.tmux.conf"
