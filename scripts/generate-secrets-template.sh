#!/usr/bin/env bash
# generate-secrets-template.sh — Mac-side: parsuje ~/.secrets → .secrets.tmpl.
# Tryby:
#   ./generate-secrets-template.sh            # stub (heurystyka op://, nic w 1P)
#   ./generate-secrets-template.sh --create   # MIGRACJA: tworzy brakujące itemy w 1P
#                                              z wartości z ~/.secrets, generuje template
#   ./generate-secrets-template.sh --check    # sprawdza co JEST/BRAK w 1P, nie zmienia nic
#
# Bezpieczeństwo:
#   - Wartości przechodzą do `op item create` (krótkotrwale w argv, lokalna sesja)
#   - Plik .secrets.tmpl ma TYLKO op:// references (nie wartości) → bezpieczny do commitu
#   - Plik ~/.secrets zostaje nietknięty
#   - Per-item interactive prompt (możesz pominąć/skrótem all/none)

set -o pipefail
# Uwaga: BEZ `set -u` — wartości tokenów mogą zawierać znaki interpretowane jako var refs
# w trybie strict, plus bash 3.2 (Mac default) ma kruchy unbound check.

MODE="stub"
VAULT_DEFAULT="Private"

for arg in "$@"; do
  case "$arg" in
    --create)  MODE="create" ;;
    --check)   MODE="check" ;;
    --stub)    MODE="stub" ;;
    --vault=*) VAULT_DEFAULT="${arg#--vault=}" ;;
    -h|--help)
      sed -n '2,15p' "$0" | sed 's/^# //'
      exit 0 ;;
    *) echo "Unknown flag: $arg"; exit 1 ;;
  esac
done

SECRETS="$HOME/.secrets"
DOTFILES_DIR="$HOME/.dotfiles"
TEMPLATE="$DOTFILES_DIR/.secrets.tmpl"

if [ ! -f "$SECRETS" ]; then
  echo "✗ Brak $SECRETS"
  echo
  if [ "$(uname -s)" = "Linux" ]; then
    echo "Wygląda że jesteś na Linuxie/Omarchy. Ten skrypt jest Mac-side — parsuje"
    echo "istniejący plain $SECRETS żeby wygenerować template do 1Password."
    echo
    echo "Tutaj odpal odwrotny kierunek (template → .secrets przez op inject):"
    echo "  eval \$(op signin)"
    echo "  $DOTFILES_DIR/scripts/secrets-inject.sh"
  else
    echo "Na Macu: utwórz $SECRETS z env varami formatu 'export VAR=value' najpierw,"
    echo "potem odpal ten skrypt z --create żeby zmigrować do 1Password."
  fi
  exit 1
fi

# Tryb create/check wymaga op CLI zalogowane
if [ "$MODE" != "stub" ]; then
  if ! command -v op >/dev/null 2>&1; then
    echo "✗ op CLI niezainstalowany (brew install 1password-cli)"
    exit 1
  fi
  if ! op vault list >/dev/null 2>&1; then
    echo "✗ op niezalogowany. Uruchom: eval \$(op signin)"
    exit 1
  fi
fi

# Wybór vault
if [ "$MODE" != "stub" ]; then
  echo "Dostępne vaulty:"
  op vault list --format=json 2>/dev/null | jq -r '.[] | "  \(.name)"'
  read -rp "Vault (default: $VAULT_DEFAULT): " VAULT
  VAULT="${VAULT:-$VAULT_DEFAULT}"
else
  VAULT="$VAULT_DEFAULT"
fi

# Backup template jeśli istnieje (do tmp/, gitignored)
if [ -f "$TEMPLATE" ] && [ "$MODE" != "check" ]; then
  mkdir -p "$DOTFILES_DIR/tmp"
  cp "$TEMPLATE" "$DOTFILES_DIR/tmp/secrets.tmpl.bak.$(date +%s)"
fi

# Helper: parsuj 1 linię "export VAR=value" lub "export VAR=\"value\""
# Bash internal — działa na bash 3.2+, nie psuje się przy '=' w wartości.
# Output (na stdout): "VAR<TAB>VALUE" (TAB jako separator, bezpieczny).
parse_secret_line() {
  local line="$1"
  # Strip leading "export "
  local rest="${line#export }"
  # VAR = wszystko do pierwszego "="
  local var="${rest%%=*}"
  # VAL = wszystko po pierwszym "="
  local val="${rest#*=}"
  # Strip leading/trailing podwójne cudzysłowy (jeśli są)
  if [ "${val:0:1}" = '"' ]; then
    val="${val:1}"           # remove leading "
    val="${val%\"}"          # remove trailing "
  fi
  printf '%s\t%s\n' "$var" "$val"
}

# Helper: sprawdź czy item istnieje w 1P
# WAŻNE: </dev/null żeby op nie zżerało stdin pętli while-read
op_item_exists() {
  local title="$1"
  op item get "$title" --vault="$VAULT" >/dev/null 2>&1 </dev/null
}

# Helper: stwórz item w 1P z wartości.
# Zwraca błąd ze stderr w globalnej zmiennej OP_ERR (do pokazania userowi).
op_item_create() {
  local title="$1"
  local value="$2"
  OP_ERR=$(op item create \
    --category="API Credential" \
    --title="$title" \
    --vault="$VAULT" \
    --tags="omarchy-migration,from-secrets" \
    "credential[password]=$value" \
    </dev/null 2>&1 >/dev/null)
  return $?
}

# Header template
if [ "$MODE" != "check" ]; then
  cat > "$TEMPLATE" <<EOF
# .secrets.tmpl — szablon dla \`op inject\`
# Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ") by generate-secrets-template.sh
# Vault: $VAULT
#
# Po edycji: \`op inject -i .secrets.tmpl -o ~/.secrets && chmod 600 ~/.secrets\`
# Wszystkie wartości plain-text TYLKO w 1Password — nigdy w tym pliku.

EOF
fi

# ─── ITERACJA ────────────────────────────────────────────────────────────────
SKIP_ALL=false
CREATED=0
EXISTS=0
SKIPPED=0
TOTAL=0

# Śledzimy unique vars przez delimited string (bash 3.2-compat — bez declare -A).
SEEN=":"

while IFS= read -r line; do
  case "$line" in
    "export "[A-Z_]*) ;;
    *) continue ;;
  esac
  PARSED=$(parse_secret_line "$line")
  VAR="${PARSED%%	*}"   # do pierwszego TAB
  VAL="${PARSED#*	}"    # po pierwszym TAB
  [ -z "$VAR" ] && continue
  case "$SEEN" in
    *":$VAR:"*) continue ;;  # duplikat
  esac
  SEEN="${SEEN}${VAR}:"
  TOTAL=$((TOTAL+1))

  printf "[%2d] %-30s " "$TOTAL" "$VAR"

  if op_item_exists "$VAR"; then
    echo "✓ exists in 1P"
    EXISTS=$((EXISTS+1))
    [ "$MODE" != "check" ] && echo "export $VAR=\"op://$VAULT/$VAR/credential\"" >> "$TEMPLATE"
    continue
  fi

  if [ "$MODE" = "check" ]; then
    echo "✗ MISSING in 1P (vault: $VAULT)"
    continue
  fi

  if [ "$MODE" = "stub" ]; then
    echo "↩ stub (no 1P check)"
    echo "export $VAR=\"op://$VAULT/$VAR/credential\"  # TODO: utwórz item lub --create" >> "$TEMPLATE"
    continue
  fi

  # MODE=create: interactive
  if $SKIP_ALL; then
    echo "↩ skip (skip-all)"
    SKIPPED=$((SKIPPED+1))
    echo "# export $VAR=\"op://$VAULT/$VAR/credential\"  # SKIPPED — utwórz ręcznie" >> "$TEMPLATE"
    continue
  fi

  echo "✗ MISSING"
  PREFIX="${VAL:0:6}"
  echo "    Wartość (z ~/.secrets, ${#VAL} znaków, prefix: ${PREFIX}…)"

  # AUTO_YES (po wybraniu 'a' wcześniej) → pomijaj prompt
  if [ "${AUTO_YES:-false}" = "true" ]; then
    ans="y"
    echo "    [auto-yes]"
  else
    # Czytaj z /dev/tty, nie ze stdin (pętla while-read zjada stdin)
    if [ -e /dev/tty ]; then
      read -rp "    Utworzyć item '$VAR' w vault '$VAULT'? [y/N/a=all/s=skip-all]: " ans </dev/tty
    else
      echo "    ⚠ brak /dev/tty (non-interactive shell) — domyślnie skip"
      ans=""
    fi
  fi

  case "$ans" in
    y|Y|a|A)
      if [ "$ans" = "a" ] || [ "$ans" = "A" ]; then
        # Auto-yes na resztę
        AUTO_YES=true
      fi
      if op_item_create "$VAR" "$VAL"; then
        echo "    ✓ utworzony w 1P"
        CREATED=$((CREATED+1))
        echo "export $VAR=\"op://$VAULT/$VAR/credential\"" >> "$TEMPLATE"
      else
        echo "    ✗ błąd op item create:"
        echo "       $OP_ERR" | head -3 | sed 's/^/       /'
        echo "# export $VAR=\"op://$VAULT/$VAR/credential\"  # CREATE FAILED" >> "$TEMPLATE"
      fi
      ;;
    s|S)
      SKIP_ALL=true
      SKIPPED=$((SKIPPED+1))
      echo "    ↩ skipping rest"
      echo "# export $VAR=\"op://$VAULT/$VAR/credential\"  # SKIPPED" >> "$TEMPLATE"
      ;;
    *)
      SKIPPED=$((SKIPPED+1))
      echo "    ↩ skip"
      echo "# export $VAR=\"op://$VAULT/$VAR/credential\"  # SKIPPED" >> "$TEMPLATE"
      ;;
  esac
done < <(grep -E '^export [A-Z_][A-Z0-9_]*=' "$SECRETS")

# Auto-yes mode: re-iterate dla niezacommitowanych?
# Prościej: podpowiedź user'owi że może odpalić ponownie z opcją 'a' od razu

# ─── SUMMARY ─────────────────────────────────────────────────────────────────
echo
echo "─── PODSUMOWANIE ───"
echo "  Wszystkich env var w ~/.secrets: $TOTAL"
echo "  Już w 1P:           $EXISTS"
[ "$MODE" = "create" ] && echo "  Utworzonych:        $CREATED"
[ "$MODE" = "create" ] && echo "  Pominiętych:        $SKIPPED"
[ "$MODE" != "check" ] && echo "  Template:           $TEMPLATE"

if [ "$MODE" = "check" ]; then
  echo
  echo "Aby utworzyć brakujące: $0 --create"
elif [ "$MODE" = "stub" ]; then
  echo
  echo "Aby zmigrować brakujące do 1P: $0 --create"
else
  echo
  echo "Test op inject (lokalnie): op inject -i $TEMPLATE -o /tmp/test && head -3 /tmp/test && rm /tmp/test"
  echo "Commit: cd $DOTFILES_DIR && git add .secrets.tmpl && git commit -m 'secrets: refresh template' && git push"
fi
