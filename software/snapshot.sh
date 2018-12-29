echo "brew update..."
brew update
brew tap > brew-taps
brew list -1 > brew-formulas
brew cask list -1 > brew-casks
git add brew-taps brew-formulas brew-casks
git diff --cached
