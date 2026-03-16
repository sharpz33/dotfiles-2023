#!/usr/bin/env bash

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
ln -s "$(pwd)/.zshrc" $HOME/.zshrc

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

# ─── OH MY ZSH PLUGINS ───────────────────────────────────────────────────────
# ZSH_CUSTOM=$DOTFILES w .zshrc → pluginy muszą być w $DOTFILES/plugins/
PLUGINS_DIR="$(pwd)/plugins"
mkdir -p "$PLUGINS_DIR"

[ ! -d "$PLUGINS_DIR/zsh-syntax-highlighting" ] && \
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
  "$PLUGINS_DIR/zsh-syntax-highlighting"

[ ! -d "$PLUGINS_DIR/zsh-autosuggestions" ] && \
  git clone https://github.com/zsh-users/zsh-autosuggestions \
  "$PLUGINS_DIR/zsh-autosuggestions"

[ ! -d "$PLUGINS_DIR/zsh-completions" ] && \
  git clone https://github.com/zsh-users/zsh-completions \
  "$PLUGINS_DIR/zsh-completions"

echo "Oh My Zsh plugins installed → $PLUGINS_DIR"

# ─── NODE (nvm) ──────────────────────────────────────────────────────────────
export NVM_DIR="$HOME/.nvm"
[ -s "$(brew --prefix)/opt/nvm/nvm.sh" ] && source "$(brew --prefix)/opt/nvm/nvm.sh"

nvm install --lts
nvm alias default lts/*
nvm use default
echo "Node $(node -v) active via nvm"

# ─── NPM GLOBALS ─────────────────────────────────────────────────────────────
echo "Installing global npm packages..."
grep -v '^#' "$(pwd)/npm-globals.txt" | grep -v '^$' | xargs npm install -g
echo "npm globals installed"

# ─── PYTHON (pyenv) ──────────────────────────────────────────────────────────
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

PYTHON_VERSION=$(pyenv latest 3)
pyenv install "$PYTHON_VERSION"
pyenv global "$PYTHON_VERSION"
echo "Python $(python3 --version) active via pyenv"

# ─── PIP GLOBALS ─────────────────────────────────────────────────────────────
echo "Installing global pip packages..."
# mlx works only on Apple Silicon – skip on Intel
if [ "$(uname -m)" = "arm64" ]; then
  pip3 install -r "$(pwd)/pip-requirements.txt"
else
  grep -v '^mlx' "$(pwd)/pip-requirements.txt" | pip3 install -r /dev/stdin
  echo "  (mlx pominięty – wymaga Apple Silicon)"
fi
echo "pip packages installed"

# ─── VS CODE EXTENSIONS ──────────────────────────────────────────────────────
if command -v code &>/dev/null; then
  echo "Installing VS Code extensions..."
  grep -v '^#' "$(pwd)/vscode-extensions.txt" | grep -v '^$' | xargs -L1 code --install-extension
  echo "VS Code extensions installed"
else
  echo "VS Code not found – extensions skipped (install VS Code first or run: cat vscode-extensions.txt | xargs -L1 code --install-extension)"
fi

# Configure Git
git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"
echo "Git configured with name: $GIT_NAME and email: $GIT_EMAIL"

# ─── DEFAULT APPS (duti) ──────────────────────────────────────────────────────
if echo "$GIT_EMAIL" | grep -qi "gft.com"; then
  CORPORATE=true bash "$(pwd)/duti-defaults.sh"
else
  bash "$(pwd)/duti-defaults.sh"
fi

# Set macOS preferences - we will run this last because this will reload the shell
source ./.macos

# ─── SSH KEY SETUP ───────────────────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  KROK: SSH Key"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  Sprawdzam czy masz już klucz SSH..."
echo ""

if [ -f "$HOME/.ssh/id_ed25519.pub" ]; then
  echo "  ✓ Klucz istnieje: ~/.ssh/id_ed25519.pub"
  echo ""
  echo "  Twój klucz publiczny:"
  echo ""
  cat "$HOME/.ssh/id_ed25519.pub"
  echo ""
else
  echo "  ✗ Brak klucza. Generuję nowy (ED25519)..."
  echo ""
  read -p "  Email do SSH key (default: $GIT_EMAIL): " SSH_EMAIL
  SSH_EMAIL=${SSH_EMAIL:-$GIT_EMAIL}
  ssh-keygen -t ed25519 -C "$SSH_EMAIL" -f "$HOME/.ssh/id_ed25519"
  eval "$(ssh-agent -s)"
  ssh-add "$HOME/.ssh/id_ed25519"
  echo ""
  echo "  Twój klucz publiczny:"
  echo ""
  cat "$HOME/.ssh/id_ed25519.pub"
  echo ""
fi

echo "  ─── Dodaj klucz do: ──────────────────────────────────────"
echo ""
echo "  GitHub:      https://github.com/settings/keys"
echo "  GFT GitLab:  https://git.gft.com/-/profile/keys"
echo "               (wymaga dostępu do sieci GFT / VPN)"
echo ""
echo "  Skopiuj klucz powyżej i wklej w obu serwisach."
echo "  Możesz też uruchomić: pbcopy < ~/.ssh/id_ed25519.pub"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
read -p "  Gotowe? Naciśnij ENTER żeby kontynuować... " _PAUSE
echo ""

# Weryfikacja połączenia z GitHub
echo "  Testuję połączenie SSH z GitHub..."
if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
  echo "  ✓ GitHub SSH działa"
else
  echo "  ⚠ GitHub SSH – brak potwierdzenia (może być OK, sprawdź ręcznie: ssh -T git@github.com)"
fi
echo ""

# ─── CLONE ~/Projects ────────────────────────────────────────────────────────
echo ""
read -p "Sklonować repozytoria do ~/Projects? (y/N): " CLONE_PROJECTS
if [[ "$CLONE_PROJECTS" =~ ^[Yy]$ ]]; then
  read -p "Klonować też repos GFT (wymaga VPN + SSH do git.gft.com)? (y/N): " CLONE_GFT
  if [[ "$CLONE_GFT" =~ ^[Yy]$ ]]; then
    bash "$(pwd)/bootstrap-projects.sh" --gft
  else
    bash "$(pwd)/bootstrap-projects.sh"
  fi
else
  echo "Pominięto. Uruchom później ręcznie: ~/.dotfiles/bootstrap-projects.sh"
fi
