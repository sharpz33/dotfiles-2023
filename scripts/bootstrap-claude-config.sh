#!/usr/bin/env bash
# bootstrap-claude-config.sh — sync globalnej konfiguracji Claude Code (~/.claude)
# między Mac a Omarchy przez git.
#
# UWAGA: ~/.claude zawiera 200+ MB cache/sessions/history. Repo trzyma WHITELIST:
#   CLAUDE.md, RTK.md, settings.json, commands/, hooks/, rules/, skills/, plugins/marketplaces/
#
# Wymaga ~/.claude/.gitignore (powstaje automatycznie z dotfiles).

set -uo pipefail

CLAUDE_DIR="$HOME/.claude"
DOTFILES_DIR="$HOME/.dotfiles"
GITIGNORE_SOURCE="$DOTFILES_DIR/.claude.gitignore"  # opcjonalny — patrz niżej
REMOTE_DEFAULT="git@github.com:sharpz33/claude-config.git"

cd "$CLAUDE_DIR" || { echo "✗ Brak $CLAUDE_DIR"; exit 1; }

# ─── 1. Upewnij się, że jest .gitignore ──────────────────────────────────────
if [ ! -f "$CLAUDE_DIR/.gitignore" ]; then
  echo "✗ Brak $CLAUDE_DIR/.gitignore — wygeneruj go ręcznie albo skopiuj z dotfiles."
  echo "  (nie pomogę automatycznie żeby nie nadpisać kontekstu jeśli istnieje)"
  exit 1
fi

# ─── 2. Init git repo jeśli brak ─────────────────────────────────────────────
if [ ! -d "$CLAUDE_DIR/.git" ]; then
  echo "→ git init w $CLAUDE_DIR"
  git init -b main
  echo ""
  echo "Następne kroki (jednorazowo, po init):"
  echo "  1. Stwórz prywatne repo na github (np. sharpz33/claude-config)"
  echo "  2. cd ~/.claude && git remote add origin <URL>"
  echo "  3. git add . && git commit -m 'initial'"
  echo "  4. git push -u origin main"
  echo ""
  echo "Potem na Omarchy:"
  echo "  rm -rf ~/.claude  # tylko jeśli świeża maszyna i CC nie zostawił niczego ważnego"
  echo "  git clone <URL> ~/.claude"
  exit 0
fi

# ─── 3. Status / sync ────────────────────────────────────────────────────────
echo "→ git status (whitelisted files)"
git status --short

REMOTE=$(git remote get-url origin 2>/dev/null || echo "")
if [ -z "$REMOTE" ]; then
  echo ""
  echo "⚠ Brak remote. Dodaj: git remote add origin $REMOTE_DEFAULT"
  exit 0
fi

echo ""
echo "Remote: $REMOTE"
echo ""
echo "Komendy:"
echo "  cd ~/.claude && git add -A && git commit -m 'msg' && git push   # Mac → remote"
echo "  cd ~/.claude && git pull                                          # Omarchy ← remote"
