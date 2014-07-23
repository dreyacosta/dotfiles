ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"

# https://github.com/rupa/z
# z, oh how i love you
mkdir -p ~/code/z
curl https://raw.githubusercontent.com/rupa/z/master/z.sh > ~/code/z/z.sh
chmod +x ~/code/z/z.sh

brew doctor

brew install wget
brew install ngrep
brew install htop
brew install nmap
brew install git bash-completion
brew install nvm
brew install mongodb

sudo npm install -g grunt-cli
sudo npm install -g bower

brew tap phinze/homebrew-cask
brew tap dreyacosta/homebrew-cask
brew install brew-cask

brew cask install dropbox
brew cask install virtualbox
brew cask install sublime-text
brew cask install iterm2
brew cask install google-chrome
# brew cask install google-chrome-canary
brew cask install google-hangouts
brew cask install opera
brew cask install opera-next
brew cask install firefox
brew cask install firefox-nightly
brew cask install webkit-nightly
brew cask install teamviewer

brew install mackup

git config --global user.name "David Rey"
git config --global user.email "david.rey.acosta@gmail.com"