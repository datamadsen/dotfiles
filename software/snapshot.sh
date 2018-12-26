echo "brew update..."
brew update
brew tap > brew-taps
brew list -1 > brew-formulae
brew cask list -1 > brew-casks
git add brew-taps brew-formulae brew-casks
git diff --cached
