#!/bin/sh

echo "Setting up your Mac..."

# Prompt for computer name
read -p "Enter computer name (default: mba): " COMPUTER_NAME
COMPUTER_NAME=${COMPUTER_NAME:-mba}
export COMPUTER_NAME

# Prompt for Git configuration
read -p "Enter your Git name (default: e-uzoi): " GIT_NAME
GIT_NAME=${GIT_NAME:-e-uzoi}

read -p "Enter your Git email (default: e-uzoi@gft.com): " GIT_EMAIL
GIT_EMAIL=${GIT_EMAIL:-e-uzoi@gft.com}

# Check for Oh My Zsh and install if we don't have it
if test ! $(which omz); then
  /bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/HEAD/tools/install.sh)"
fi

# Check for Homebrew and install if we don't have it
if test ! $(which brew); then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Detect architecture and set appropriate Homebrew path
  if [ "$(uname -m)" = "arm64" ]; then
    # Apple Silicon (M1/M2/M3)
    BREW_PREFIX="/opt/homebrew"
  else
    # Intel
    BREW_PREFIX="/usr/local"
  fi

  (
    echo
    echo "eval \"\$(${BREW_PREFIX}/bin/brew shellenv)\""
  ) >>$HOME/.zprofile
  eval "$(${BREW_PREFIX}/bin/brew shellenv)"
fi

# Removes .zshrc from $HOME (if it exists) and symlinks the .zshrc file from the .dotfiles
rm -rf $HOME/.zshrc
ln -s $(pwd)/.zshrc $HOME/.zshrc

# Symlink all application configurations from ~/.config
mkdir -p $HOME/.config
for config_dir in config/*/; do
  dir_name=$(basename "$config_dir")
  rm -rf "$HOME/.config/$dir_name"
  ln -s "$(pwd)/config/$dir_name" "$HOME/.config/$dir_name"
  echo "Symlinked $dir_name"
done

# Update Homebrew recipes
brew update

# Install all our dependencies with bundle (See Brewfile)
brew tap homebrew/bundle
brew bundle --file ./Brewfile

# Symlink the Mackup config file to the home directory
#ln -s .mackup.cfg $HOME/.mackup.cfg

# Configure Git
git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"
echo "Git configured with name: $GIT_NAME and email: $GIT_EMAIL"

# Set macOS preferences - we will run this last because this will reload the shell
source ./.macos
