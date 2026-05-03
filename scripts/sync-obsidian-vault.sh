#!/usr/bin/env bash
# sync-obsidian-vault.sh — rsync ~/vaults/obsidian między hostami (Mac ↔ Omarchy).
# Dwa kompy obok siebie w LAN: rsync over SSH = najprostsze, deterministyczne.
# Long-term alternatywa: Syncthing (real-time P2P, instaluje się przez aur-packages.txt).
#
# Użycie:
#   ./sync-obsidian-vault.sh push omarchy.local       # Mac → Omarchy (z Maca)
#   ./sync-obsidian-vault.sh pull mac.local           # Omarchy ← Mac (z Omarchy)
#   ./sync-obsidian-vault.sh push omarchy.local --dry # dry-run
#
# Wymaga: SSH key dodany na obu kompach + mDNS (Avahi na Omarchy, Bonjour na Macu).
# Test SSH: ssh omarchy.local hostname

set -uo pipefail

if [ $# -lt 2 ]; then
  echo "Użycie: $0 <push|pull> <target-host> [--dry]"
  echo "Przykład: $0 push omarchy.local"
  exit 1
fi

DIRECTION="$1"
TARGET="$2"
DRY_FLAG=""
[ "${3:-}" = "--dry" ] && DRY_FLAG="--dry-run"

VAULT_LOCAL="$HOME/vaults/obsidian"

# Sprawdź lokalny vault (przy push) / target istnieje (przy pull → tworzy się sam)
if [ "$DIRECTION" = "push" ] && [ ! -d "$VAULT_LOCAL" ]; then
  echo "✗ Brak lokalnego $VAULT_LOCAL — nie ma czego pushować"
  exit 1
fi

# rsync exclusions — workspace state, cache i system-junk per host
RSYNC_OPTS=(
  --archive
  --verbose
  --compress
  --delete
  --human-readable
  --exclude='.DS_Store'
  --exclude='.obsidian/workspace*'
  --exclude='.obsidian/cache/'
  --exclude='.obsidian/plugins/*/data.json'
  --exclude='.trash/'
  --exclude='*.swp'
  --exclude='.git/'  # vault NIE jest git, ale safety
)
[ -n "$DRY_FLAG" ] && RSYNC_OPTS+=("$DRY_FLAG")

# Test SSH dostępu do target
echo "→ test ssh $TARGET ..."
if ! ssh -o ConnectTimeout=5 -o BatchMode=yes "$TARGET" "echo OK" >/dev/null 2>&1; then
  echo "✗ SSH do $TARGET nie działa. Sprawdź:"
  echo "    ssh $TARGET hostname"
  echo "    Czy SSH server uruchomiony na targecie? (Mac: System Settings → Sharing → Remote Login)"
  echo "    Czy klucz w ~/.ssh/authorized_keys na targecie?"
  exit 1
fi

case "$DIRECTION" in
  push)
    echo "→ rsync PUSH: $VAULT_LOCAL/ → $TARGET:~/vaults/obsidian/"
    ssh "$TARGET" "mkdir -p ~/vaults/obsidian"
    rsync "${RSYNC_OPTS[@]}" "$VAULT_LOCAL/" "$TARGET:vaults/obsidian/"
    ;;
  pull)
    echo "→ rsync PULL: $TARGET:~/vaults/obsidian/ → $VAULT_LOCAL/"
    mkdir -p "$VAULT_LOCAL"
    rsync "${RSYNC_OPTS[@]}" "$TARGET:vaults/obsidian/" "$VAULT_LOCAL/"
    ;;
  *)
    echo "✗ Nieznany kierunek: $DIRECTION (musi być push|pull)"
    exit 1
    ;;
esac

echo ""
SIZE=$(du -sh "$VAULT_LOCAL" 2>/dev/null | cut -f1)
echo "✓ Vault size: $SIZE"
echo ""
echo "Tip: dla real-time sync (auto, w tle) zainstaluj Syncthing:"
echo "    Mac:     brew install syncthing"
echo "    Omarchy: sudo pacman -S syncthing"
echo "    Setup:   syncthing  # GUI: http://localhost:8384, dodaj device + folder"
