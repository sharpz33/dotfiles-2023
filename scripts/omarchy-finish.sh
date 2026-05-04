#!/usr/bin/env bash
# omarchy-finish.sh — kontynuacja po fresh-omarchy.sh.
# Sekretu już są (eval $(op signin) + scripts/secrets-inject.sh wcześniej).
# Ten skrypt: clone ~/.claude, clone projekty, validate. Idempotentny — odpalaj wielokrotnie.
#
# Wymaga: op CLI signed in (lub desktop integration ON), SSH key na GitHub.

set -uo pipefail

DOTFILES_DIR="$HOME/.dotfiles"
LOG_DIR="$HOME/Projects/assistants/aibl/DRAFTS/omarchy-migration"
mkdir -p "$LOG_DIR" 2>/dev/null || mkdir -p "$DOTFILES_DIR/tmp"
LOG="${LOG_DIR:-$DOTFILES_DIR/tmp}/omarchy-finish-$(date +%Y%m%d-%H%M%S).log"
exec > >(tee "$LOG") 2>&1

# Colors
GRN='\033[0;32m'; YLW='\033[0;33m'; RED='\033[0;31m'; BLU='\033[0;34m'; BLD='\033[1m'; NC='\033[0m'
ok()    { echo -e "${GRN}✓${NC} $1"; }
warn()  { echo -e "${YLW}⚠${NC} $1"; }
err()   { echo -e "${RED}✗${NC} $1"; }
log()   { echo -e "${BLU}→${NC} $1"; }
section(){ echo; echo -e "${BLD}── $1 ──${NC}"; }

# ─── SYMLINKS (idempotent) ───────────────────────────────────────────────────
# Jeśli ktoś nie odpalił fresh-omarchy.sh albo .zshrc się rozjechał — naprawiamy.
section "SYMLINKS"

# .zshrc → dotfiles/.zshrc.omarchy
if [ -L "$HOME/.zshrc" ] && [ "$(readlink "$HOME/.zshrc")" = "$DOTFILES_DIR/.zshrc.omarchy" ]; then
  ok "~/.zshrc → .zshrc.omarchy (już)"
else
  [ -e "$HOME/.zshrc" ] && {
    BAK="$HOME/.zshrc.bak.$(date +%s)"
    mv "$HOME/.zshrc" "$BAK"
    warn "backup: $BAK"
  }
  ln -s "$DOTFILES_DIR/.zshrc.omarchy" "$HOME/.zshrc"
  ok "~/.zshrc → $DOTFILES_DIR/.zshrc.omarchy"
fi

# .p10k.zsh
if [ -f "$DOTFILES_DIR/.p10k.zsh" ] && [ ! -L "$HOME/.p10k.zsh" ]; then
  [ -e "$HOME/.p10k.zsh" ] && mv "$HOME/.p10k.zsh" "$HOME/.p10k.zsh.bak.$(date +%s)"
  ln -s "$DOTFILES_DIR/.p10k.zsh" "$HOME/.p10k.zsh"
  ok "~/.p10k.zsh → dotfiles"
fi

# ~/.config/* (nvim, zed, ghostty, wezterm)
mkdir -p "$HOME/.config"
for config_dir in "$DOTFILES_DIR"/config/*/; do
  [ -d "$config_dir" ] || continue
  dir_name=$(basename "$config_dir")
  if [ -L "$HOME/.config/$dir_name" ] && [ "$(readlink "$HOME/.config/$dir_name")" = "$DOTFILES_DIR/config/$dir_name" ]; then
    continue   # już dobrze, milcz
  fi
  [ -e "$HOME/.config/$dir_name" ] && mv "$HOME/.config/$dir_name" "$HOME/.config/$dir_name.bak.$(date +%s)"
  ln -s "$DOTFILES_DIR/config/$dir_name" "$HOME/.config/$dir_name"
  ok "~/.config/$dir_name → dotfiles"
done

# ─── PRE-FLIGHT ──────────────────────────────────────────────────────────────
section "PRE-FLIGHT"
[ "$(uname -s)" = "Linux" ] || { err "skrypt dla Linuxa"; exit 1; }

# 1. ~/.secrets musi być wygenerowany
if [ ! -f "$HOME/.secrets" ]; then
  err "Brak ~/.secrets. Najpierw: eval \$(op signin) + $DOTFILES_DIR/scripts/secrets-inject.sh"
  exit 1
fi
EXPORTS=$(grep -c '^export' "$HOME/.secrets" 2>/dev/null)
EXPORTS=${EXPORTS:-0}
ok "~/.secrets — $EXPORTS eksportów"

# 2. SSH do GitHub
# StrictHostKeyChecking=accept-new — auto-accept fingerprint przy pierwszym połączeniu
# (klasyczny problem świeżej maszyny: brak github.com w known_hosts → BatchMode blokuje).
SSH_OUT=$(ssh -o ConnectTimeout=5 \
              -o StrictHostKeyChecking=accept-new \
              -o BatchMode=yes \
              -T git@github.com 2>&1 || true)
if echo "$SSH_OUT" | grep -q "successfully authenticated"; then
  ok "GitHub SSH działa: $(echo "$SSH_OUT" | head -1)"
else
  err "SSH do GitHub nie działa. Output:"
  echo "$SSH_OUT" | sed 's/^/    /'
  echo
  echo "  Diagnostyka:"
  echo "    1. Klucz publiczny: cat ~/.ssh/id_ed25519.pub"
  echo "    2. Dodaj na: https://github.com/settings/keys"
  echo "    3. Test ręcznie: ssh -T git@github.com"
  echo "    4. Verbose: ssh -vT git@github.com 2>&1 | grep -E 'Offering|denied'"
  exit 1
fi

# ─── 1. CLAUDE CONFIG (~/.claude) ────────────────────────────────────────────
section "1. CLAUDE CONFIG (~/.claude)"
CLAUDE_REMOTE="git@github.com:sharpz33/claude-config.git"

if [ -d "$HOME/.claude/.git" ]; then
  log "~/.claude już jest git repo, robię pull..."
  (cd "$HOME/.claude" && git pull --ff-only)
  ok "~/.claude up-to-date"
else
  if [ -d "$HOME/.claude" ]; then
    BACKUP="$HOME/.claude.fresh-backup-$(date +%s)"
    warn "~/.claude istnieje (nie-git) — przenoszę do $BACKUP"
    mv "$HOME/.claude" "$BACKUP"
  fi
  log "Klonuję $CLAUDE_REMOTE → ~/.claude"
  if git clone "$CLAUDE_REMOTE" "$HOME/.claude"; then
    ok "Sklonowane"
  else
    err "Klonowanie failed. Czy repo $CLAUDE_REMOTE istnieje? Czy SSH key dodany?"
    exit 1
  fi
fi

# Hooks executable (git nie zachowuje +x w niektórych config)
if [ -d "$HOME/.claude/hooks" ]; then
  chmod +x "$HOME/.claude/hooks"/*.sh 2>/dev/null
  ok "hooks/*.sh — chmod +x"
fi

# ─── 2. PROJEKTY (~/Projects) ────────────────────────────────────────────────
section "2. PROJEKTY"
if [ -x "$DOTFILES_DIR/bootstrap-projects.sh" ]; then
  log "Odpalam bootstrap-projects.sh (bez GFT — domowa sieć)"
  bash "$DOTFILES_DIR/bootstrap-projects.sh"
else
  err "Brak $DOTFILES_DIR/bootstrap-projects.sh"
  exit 1
fi

# ─── 3. RELOAD shell env ────────────────────────────────────────────────────
section "3. RELOAD ENV"
# shellcheck disable=SC1091
source "$HOME/.secrets" 2>/dev/null || true
ok "Sekrety załadowane do bieżącej sesji"

# ─── 4. WALIDACJA ────────────────────────────────────────────────────────────
section "4. WALIDACJA"
log "Odpalam validate-claude-setup.sh"
echo
if bash "$DOTFILES_DIR/scripts/validate-claude-setup.sh"; then
  ok "WSZYSTKO OK — setup gotowy do produkcji"
else
  RC=$?
  warn "Walidacja wykryła $RC fail(ów). Otwórz log validate-*.log i napraw, ponów."
fi

# ─── DONE ────────────────────────────────────────────────────────────────────
section "DONE"
ok "Log z tej sesji: $LOG"
echo
echo "Następne kroki:"
echo "  • Obsidian vault (z Maca): ~/.dotfiles/scripts/sync-obsidian-vault.sh push <omarchy-host>"
echo "  • Sprawdź CC: cd ~/Projects/assistants/aibl && claude"
echo "  • Heal pętla: jak validate krzyknie, otwórz CC w aibl i powiedz \"napraw failujące rzeczy z validate-*.log\""
