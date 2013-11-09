curl -L https://get.rvm.io | bash -s stable

ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go)"

# https://github.com/rupa/z
# z, oh how i love you
mkdir -p ~/code/z
curl https://raw.github.com/rupa/z/master/z.sh > ~/code/z/z.sh
chmod +x ~/code/z/z.sh

brew doctor

brew install wget
brew install htop
brew install nmap
brew install node
brew install mongodb

brew tap phinze/homebrew-cask
brew install brew-cask

brew cask install google-drive
brew cask install virtualbox
brew cask install sublime-text
brew cask install google-chrome
brew cask install opera
brew cask install firefox
brew cask install firefox-nightly
brew cask install opera-next
brew cask install team-viewer

wget https://github.com/dreyacosta/dotfiles/archive/master.zip

unzip master.zip

mv -v dotfiles-master/.* ~/

rm -rfv dotfiles-master/

rm -rf  ~/Library/Application\ Support/Sublime\ Text\ 2/

ln -s ~/Google\ Drive/Sublime ~/Library/Application\ Support/Sublime\ Text\ 2