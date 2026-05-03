#!/usr/bin/env bash
# fresh-omarchy.sh — bootstrap Omarchy/Arch dla parytetu z Mac CC + skille.
# Idempotentny: można odpalać wielokrotnie, każdy krok sprawdza state.
# Min set: tylko to co potrzebne dla CC + skille + workflow Łukasza.
#
# Użycie:
#   ./fresh-omarchy.sh           # pełny bootstrap
#   ./fresh-omarchy.sh --dry     # dry-run (pokazuje co by zrobił)
#   ./fresh-omarchy.sh --skip-aur  # tylko pacman, pomiń yay/AUR

set -uo pipefail

# ─── ARGS ─────────────────────────────────────────────────────────────────────
DRY=false
SKIP_AUR=false
for arg in "$@"; do
  case "$arg" in
    --dry) DRY=true ;;
    --skip-aur) SKIP_AUR=true ;;
    *) echo "Unknown flag: $arg"; exit 1 ;;
  esac
done

# ─── COLORS / LOG ────────────────────────────────────────────────────────────
RED='\033[0;31m'; GRN='\033[0;32m'; YLW='\033[0;33m'; BLU='\033[0;34m'; CYN='\033[0;36m'; BLD='\033[1m'; NC='\033[0m'
log()   { echo -e "${BLU}→${NC} $1"; }
ok()    { echo -e "${GRN}✓${NC} $1"; }
warn()  { echo -e "${YLW}⚠${NC} $1"; }
err()   { echo -e "${RED}✗${NC} $1"; }
skip()  { echo -e "${CYN}↩${NC} $1"; }
section(){ echo -e "\n${BLD}── $1 ──${NC}"; }
run()   { $DRY && echo "  [dry] $*" || eval "$@"; }

# ─── PRE-FLIGHT ──────────────────────────────────────────────────────────────
section "PRE-FLIGHT"

if [ "$(uname -s)" != "Linux" ]; then
  err "To skrypt dla Linuxa (Omarchy/Arch). Na Macu uruchom fresh.sh."
  exit 1
fi

if ! command -v pacman >/dev/null 2>&1; then
  err "pacman nie znaleziony. Ten skrypt jest dla Arch/Omarchy."
  exit 1
fi

DOTFILES_DIR="$HOME/.dotfiles"
if [ ! -d "$DOTFILES_DIR" ]; then
  err "$DOTFILES_DIR nie istnieje. Sklonuj dotfiles repo najpierw."
  exit 1
fi

# Init log
LOG_DIR="$HOME/Projects/assistants/aibl/DRAFTS/omarchy-migration"
mkdir -p "$LOG_DIR" 2>/dev/null || mkdir -p "$DOTFILES_DIR/tmp"
LOG_FILE="${LOG_DIR:-$DOTFILES_DIR/tmp}/fresh-omarchy-$(date +%Y%m%d-%H%M%S).log"
echo "Log: $LOG_FILE"
exec > >(tee "$LOG_FILE") 2>&1

ok "Pre-flight OK | DRY=$DRY | SKIP_AUR=$SKIP_AUR"

# ─── GIT CONFIG (interactive) ────────────────────────────────────────────────
section "GIT CONFIG"
read -rp "Enter your Git name (default: e-uzoi): " GIT_NAME
GIT_NAME=${GIT_NAME:-e-uzoi}
read -rp "Enter your Git email (default: sharpz33@gmail.com): " GIT_EMAIL
GIT_EMAIL=${GIT_EMAIL:-sharpz33@gmail.com}

# ─── SYSTEM UPDATE ───────────────────────────────────────────────────────────
section "PACMAN UPDATE"
run "sudo pacman -Syu --noconfirm"

# ─── PACMAN PACKAGES ─────────────────────────────────────────────────────────
section "PACMAN PACKAGES"
PACMAN_LIST=$(grep -v '^#' "$DOTFILES_DIR/pacman-packages.txt" | grep -v '^$' | tr '\n' ' ')
log "Packages: $PACMAN_LIST"
run "sudo pacman -S --needed --noconfirm $PACMAN_LIST"

# ─── YAY (AUR helper) ────────────────────────────────────────────────────────
if ! $SKIP_AUR; then
  section "YAY (AUR helper)"
  if command -v yay >/dev/null 2>&1; then
    skip "yay already installed: $(yay --version | head -1)"
  else
    log "Installing yay from AUR..."
    if ! $DRY; then
      TMPD=$(mktemp -d)
      git clone https://aur.archlinux.org/yay.git "$TMPD/yay"
      (cd "$TMPD/yay" && makepkg -si --noconfirm)
      rm -rf "$TMPD"
    else
      echo "  [dry] would clone yay AUR + makepkg"
    fi
  fi

  # ─── AUR PACKAGES ──────────────────────────────────────────────────────────
  section "AUR PACKAGES"
  AUR_LIST=$(grep -v '^#' "$DOTFILES_DIR/aur-packages.txt" | grep -v '^$' | tr '\n' ' ')
  log "AUR packages: $AUR_LIST"
  run "yay -S --needed --noconfirm $AUR_LIST"
fi

# ─── OH MY ZSH ───────────────────────────────────────────────────────────────
section "OH MY ZSH"
if [ -d "$HOME/.oh-my-zsh" ]; then
  skip "oh-my-zsh already installed"
else
  log "Installing oh-my-zsh..."
  run 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/HEAD/tools/install.sh)" "" --unattended'
fi

# ─── ZSH PLUGINS (klonowane do $DOTFILES/plugins/) ──────────────────────────
section "ZSH PLUGINS"
PLUGINS_DIR="$DOTFILES_DIR/plugins"
mkdir -p "$PLUGINS_DIR"
for repo in zsh-syntax-highlighting zsh-autosuggestions zsh-completions; do
  if [ -d "$PLUGINS_DIR/$repo" ]; then
    skip "$repo already cloned"
  else
    run "git clone https://github.com/zsh-users/$repo.git $PLUGINS_DIR/$repo"
  fi
done

# ─── SHELL: chsh do zsh ─────────────────────────────────────────────────────
section "DEFAULT SHELL → zsh"
ZSH_PATH=$(command -v zsh)
if [ "$SHELL" != "$ZSH_PATH" ]; then
  log "Setting default shell to zsh ($ZSH_PATH)..."
  run "chsh -s $ZSH_PATH"
else
  skip "Default shell already zsh"
fi

# ─── SYMLINKS ─────────────────────────────────────────────────────────────────
section "SYMLINKS — .zshrc i ~/.config"
# .zshrc → .zshrc.omarchy
if [ -L "$HOME/.zshrc" ]; then
  skip ".zshrc already symlinked → $(readlink "$HOME/.zshrc")"
else
  [ -f "$HOME/.zshrc" ] && run "mv $HOME/.zshrc $HOME/.zshrc.bak.$(date +%s)"
  run "ln -s $DOTFILES_DIR/.zshrc.omarchy $HOME/.zshrc"
  ok "Symlinked .zshrc → .zshrc.omarchy"
fi

# .p10k.zsh
if [ ! -L "$HOME/.p10k.zsh" ] && [ -f "$DOTFILES_DIR/.p10k.zsh" ]; then
  [ -f "$HOME/.p10k.zsh" ] && run "mv $HOME/.p10k.zsh $HOME/.p10k.zsh.bak.$(date +%s)"
  run "ln -s $DOTFILES_DIR/.p10k.zsh $HOME/.p10k.zsh"
fi

# ~/.config/* (nvim, zed, ghostty, wezterm, alacritty, etc.)
mkdir -p "$HOME/.config"
for config_dir in "$DOTFILES_DIR"/config/*/; do
  dir_name=$(basename "$config_dir")
  if [ -L "$HOME/.config/$dir_name" ]; then
    skip "~/.config/$dir_name already symlinked"
  else
    [ -e "$HOME/.config/$dir_name" ] && run "mv $HOME/.config/$dir_name $HOME/.config/$dir_name.bak.$(date +%s)"
    run "ln -s $DOTFILES_DIR/config/$dir_name $HOME/.config/$dir_name"
    ok "Symlinked ~/.config/$dir_name"
  fi
done

# ─── NODE (nvm) ──────────────────────────────────────────────────────────────
section "NODE (nvm)"
if [ -s /usr/share/nvm/init-nvm.sh ]; then
  # shellcheck disable=SC1091
  source /usr/share/nvm/init-nvm.sh
elif [ -s "$HOME/.nvm/nvm.sh" ]; then
  export NVM_DIR="$HOME/.nvm"
  # shellcheck disable=SC1091
  \. "$NVM_DIR/nvm.sh"
fi

if command -v nvm >/dev/null 2>&1; then
  run "nvm install --lts"
  run "nvm alias default 'lts/*'"
  run "nvm use default"
  ok "Node $(node -v 2>/dev/null) active"
else
  warn "nvm nie wczytany w bieżącej sesji — zaloguj się ponownie i uruchom nvm install --lts"
fi

# ─── NPM GLOBALS ─────────────────────────────────────────────────────────────
section "NPM GLOBALS"
if command -v npm >/dev/null 2>&1; then
  NPM_LIST=$(grep -v '^#' "$DOTFILES_DIR/npm-globals.txt" | grep -v '^$' | tr '\n' ' ')
  log "npm globals: $NPM_LIST"
  run "npm install -g $NPM_LIST"
else
  warn "npm niedostępne — pomijam globals"
fi

# ─── PYTHON (pyenv) ──────────────────────────────────────────────────────────
section "PYTHON (pyenv)"
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv >/dev/null 2>&1; then
  eval "$(pyenv init -)" 2>/dev/null || true
  PYTHON_VERSION=$(pyenv latest 3 2>/dev/null || echo "3.12")
  log "Installing Python $PYTHON_VERSION via pyenv..."
  run "pyenv install -s $PYTHON_VERSION"
  run "pyenv global $PYTHON_VERSION"
fi

# ─── PIP GLOBALS (skip mlx — Apple Silicon only) ────────────────────────────
section "PIP GLOBALS"
if command -v pip3 >/dev/null 2>&1; then
  if [ -f "$DOTFILES_DIR/pip-requirements.txt" ]; then
    grep -vE '^(#|mlx|$)' "$DOTFILES_DIR/pip-requirements.txt" | run "pip3 install --user -r /dev/stdin"
  fi
fi

# ─── CLAUDE CODE (native installer) ──────────────────────────────────────────
section "CLAUDE CODE (native)"
if [ -x "$HOME/.local/bin/claude" ]; then
  skip "Claude Code już zainstalowany → $($HOME/.local/bin/claude --version 2>/dev/null || echo '?')"
else
  log "Installing Claude Code (native installer)..."
  run 'curl -fsSL https://claude.ai/install.sh | bash'
fi

# ─── GIT CONFIG ──────────────────────────────────────────────────────────────
section "GIT CONFIG"
run "git config --global user.name '$GIT_NAME'"
run "git config --global user.email '$GIT_EMAIL'"
run "git config --global init.defaultBranch main"
run "git config --global pull.rebase false"
ok "Git: $GIT_NAME <$GIT_EMAIL>"

# ─── SSH KEY ─────────────────────────────────────────────────────────────────
section "SSH KEY"
if [ -f "$HOME/.ssh/id_ed25519.pub" ]; then
  ok "Klucz SSH już istnieje:"
  cat "$HOME/.ssh/id_ed25519.pub"
else
  log "Generuję klucz ED25519..."
  run "ssh-keygen -t ed25519 -C '$GIT_EMAIL' -f $HOME/.ssh/id_ed25519 -N ''"
  eval "$(ssh-agent -s)"
  ssh-add "$HOME/.ssh/id_ed25519" 2>/dev/null
  ok "Klucz wygenerowany. Dodaj do GitHub: https://github.com/settings/keys"
  cat "$HOME/.ssh/id_ed25519.pub"
fi

# ─── 1PASSWORD CLI signin hint ──────────────────────────────────────────────
section "1PASSWORD CLI"
if command -v op >/dev/null 2>&1; then
  ok "op CLI installed: $(op --version)"
  if op vault list >/dev/null 2>&1; then
    ok "Already signed in"
  else
    warn "NIE zalogowany. Uruchom: eval \$(op signin)"
    warn "Potem: ~/.dotfiles/scripts/secrets-inject.sh — wygeneruje ~/.secrets"
  fi
else
  err "op CLI nie zainstalowany — sprawdź AUR aur-packages.txt"
fi

# ─── FINISH ──────────────────────────────────────────────────────────────────
section "DONE"
ok "Bootstrap zakończony. Log: $LOG_FILE"
echo ""
echo "Następne kroki:"
echo "  1. Zaloguj się ponownie do shell (nowy zsh + .zshrc)"
echo "  2. Uruchom: eval \$(op signin)"
echo "  3. Uruchom: ~/.dotfiles/scripts/secrets-inject.sh"
echo "  4. Sklonuj projekty: ~/.dotfiles/bootstrap-projects.sh"
echo "  5. Walidacja: ~/.dotfiles/scripts/validate-claude-setup.sh"
