echo "brew update..."
brew update
brew list -1 > brew-formulas
brew cask list -1 > brew-casks
git add brew-formulas brew-casks
git diff --cached
