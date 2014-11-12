# Remove symlink
echo " Remove symlink."
rm ~/.irssi

# Create symlink
echo " Create symlink."
ln -s $(pwd)/ ~/.irssi

echo " Done with irssi"
