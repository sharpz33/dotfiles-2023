#!/bin/sh

echo "Setting up your Mac..."

# Check for Homebrew and install if we don't have it
if test ! $(which brew); then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  (
    echo
    echo 'eval "$(/usr/local/bin/brew shellenv)"'
  ) >>$HOME/.zprofile
  eval "$(/usr/local/bin/brew shellenv)"
fi

# Update Homebrew recipes
brew update

# Install all our dependencies with bundle (See Brewfile)
brew tap homebrew/bundle
brew bundle --file ./Brewfile

# Set macOS preferences - we will run this last because this will reload the shell
source ./.macos

# Import Karabiner configuration
DESTINATION_CONFIG_PATH=~/.config/karabiner/karbiner.json
cp ./karabiner.json "$DESTINATION_CONFIG_PATH"
launchctl kickstart -k gui/$(id -u)/org.pqrs.service.agent.karabiner_console_user_server
