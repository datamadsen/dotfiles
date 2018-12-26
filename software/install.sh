while read formula; do
	if brew ls --versions $formula > /dev/null; then
		echo "$formula already installed."
	else
		brew install $formula
	fi
done <brew-formulae

cat brew-taps | xargs brew tap

while read cask; do
	if brew cask ls --versions $cask > /dev/null; then
		echo "$cask already installed."
	else
		brew cask install $cask
	fi
done <brew-casks
