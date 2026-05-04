#!/usr/bin/env bash
# secrets-inject.sh — wstrzykuje wartości z 1Password do ~/.secrets.
# Wymaga: op CLI zalogowany (eval $(op signin)).
# Idempotentny: nadpisuje ~/.secrets backupem.

set -uo pipefail

DOTFILES_DIR="$HOME/.dotfiles"
TEMPLATE="$DOTFILES_DIR/.secrets.tmpl"
TARGET="$HOME/.secrets"

# ─── PRE-FLIGHT ──────────────────────────────────────────────────────────────
if ! command -v op >/dev/null 2>&1; then
  echo "✗ op CLI nie zainstalowany. Mac: brew install 1password-cli. Arch: yay -S 1password-cli"
  exit 1
fi

if ! op vault list >/dev/null 2>&1; then
  echo "✗ op nie zalogowany. Uruchom: eval \$(op signin)"
  exit 1
fi

if [ ! -f "$TEMPLATE" ]; then
  echo "✗ Brak $TEMPLATE. Wygeneruj z Maca: ~/.dotfiles/scripts/generate-secrets-template.sh"
  exit 1
fi

# Backup obecnego ~/.secrets do dotfiles/tmp (gitignored)
if [ -f "$TARGET" ]; then
  mkdir -p "$DOTFILES_DIR/tmp"
  BACKUP="$DOTFILES_DIR/tmp/secrets.bak.$(date +%Y%m%d-%H%M%S)"
  cp "$TARGET" "$BACKUP"
  chmod 600 "$BACKUP"
  echo "→ backup: $BACKUP"
fi

# ─── INJECT ──────────────────────────────────────────────────────────────────
echo "→ op inject $TEMPLATE → $TARGET"
if op inject -i "$TEMPLATE" -o "$TARGET" -f 2>&1; then
  chmod 600 "$TARGET"
  echo "✓ $TARGET wygenerowany ($(grep -c '^export' "$TARGET") zmiennych, chmod 600)"
else
  echo "✗ op inject failed. Sprawdź op:// paths w $TEMPLATE."
  echo "  Tip: op item list  # listuje dostępne items"
  exit 1
fi

# ─── VERIFY ──────────────────────────────────────────────────────────────────
# Sprawdź ile zmiennych ma TODO (niezuzupełnione).
# UWAGA: grep -c bez matchów daje exit 1 i stdout="0" — || echo 0 dawało "0\n0".
TODOS=$(grep -c "TODO" "$TARGET" 2>/dev/null)
TODOS=${TODOS:-0}
if [ "$TODOS" -gt 0 ]; then
  echo "⚠ $TODOS zmiennych ma 'TODO' w wartości — sprawdź template."
fi

echo ""
echo "Załaduj do bieżącej sesji: source ~/.secrets"
echo "Auto-load: ~/.zshrc.omarchy już zawiera 'source ~/.secrets'."
