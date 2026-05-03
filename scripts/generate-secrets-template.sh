#!/usr/bin/env bash
# generate-secrets-template.sh — Mac-side: parse ~/.secrets → generate .secrets.tmpl
# Output: $DOTFILES/.secrets.tmpl z op:// stubami do uzupełnienia ręcznie.
# Po edycji op:// paths: commit + push, na Omarchy git pull + scripts/secrets-inject.sh.

set -uo pipefail

SECRETS="${1:-$HOME/.secrets}"
DOTFILES_DIR="$HOME/.dotfiles"
TEMPLATE="$DOTFILES_DIR/.secrets.tmpl"

if [ ! -f "$SECRETS" ]; then
  echo "✗ Brak $SECRETS"
  exit 1
fi

if [ -f "$TEMPLATE" ]; then
  read -rp "$TEMPLATE już istnieje. Nadpisać? (y/N): " ans
  [[ "$ans" =~ ^[Yy]$ ]] || { echo "Anulowano."; exit 0; }
  cp "$TEMPLATE" "$TEMPLATE.bak.$(date +%s)"
fi

cat > "$TEMPLATE" <<'EOF'
# .secrets.tmpl — szablon dla `op inject`
#
# Każda linia `export VAR="op://Vault/Item/field"` zostanie przez
# `op inject` zamieniona na realną wartość z 1Password.
#
# Po uzupełnieniu op:// paths:
#   git add .secrets.tmpl && git commit -m "secrets: update op:// refs"
#   git push
# Na Omarchy:
#   git pull && ~/.dotfiles/scripts/secrets-inject.sh
#
# Konwencja sugerowana (możesz zmienić):
#   - vault: "Private" lub "Work"
#   - item: nazwa serwisu (np. "Anthropic API", "AWS aibl-admin")
#   - field: "credential" (default dla API Credentials), "password" (Login items)
#
# Bez wartości plaintext! Tylko `op://...` references.

EOF

# Wyciągnij nazwy env var z ~/.secrets (bez wartości) i wygeneruj stub
grep -E '^export [A-Z_][A-Z0-9_]*=' "$SECRETS" | \
  sed -E 's/^export ([A-Z_][A-Z0-9_]*)=.*/\1/' | \
  sort -u | \
  while read -r var; do
    # Heurystyka domyślnego vault/item per nazwa
    case "$var" in
      ANTHROPIC_*)        echo "export $var=\"op://Private/Anthropic API/credential\"" ;;
      OPENAI_*)           echo "export $var=\"op://Private/OpenAI API/credential\"" ;;
      AZURE_*)            echo "export $var=\"op://Private/Azure OpenAI/credential\"" ;;
      AIRTABLE_*)         echo "export $var=\"op://Private/Airtable/credential\"" ;;
      TELEGRAM_*)         echo "export $var=\"op://Private/Telegram bot/credential\"" ;;
      RESEND_*)           echo "export $var=\"op://Private/Resend/credential\"" ;;
      GMAIL_*)            echo "export $var=\"op://Private/Gmail App Password/credential\"" ;;
      FAKTUROWNIA_*)      echo "export $var=\"op://Private/Fakturownia/credential\"" ;;
      INSTAPAPER_*)       echo "export $var=\"op://Private/Instapaper/email\"" ;;
      GFT_LLM_*)          echo "export $var=\"op://Work/GFT LLM Router/credential\"" ;;
      DOCINTEL_*)         echo "export $var=\"op://Work/Azure DocIntel/credential\"" ;;
      STORAGE_CONN)       echo "export $var=\"op://Work/Azure Storage/connection-string\"" ;;
      LITELLM_*)          echo "export $var=\"op://Work/LiteLLM/credential\"" ;;
      CLOUDFLARE_*)       echo "export $var=\"op://Private/Cloudflare/credential\"" ;;
      DISCORD_*)          echo "export $var=\"op://Private/Discord webhook/credential\"" ;;
      *)                  echo "export $var=\"op://Private/TODO-set-vault-item/credential\"  # TODO" ;;
    esac
  done >> "$TEMPLATE"

echo ""
echo "✓ Wygenerowany template: $TEMPLATE"
echo ""
echo "Linijek: $(grep -c '^export' "$TEMPLATE")"
echo ""
echo "Następne kroki:"
echo "  1. Otwórz $TEMPLATE i sprawdź op:// paths (większość to heurystyka — popraw nazwy item w 1P)"
echo "  2. Test lokalnie: op inject -i $TEMPLATE -o /tmp/test-secrets && head -5 /tmp/test-secrets"
echo "  3. Jeśli OK: git add .secrets.tmpl && git commit && git push"
echo "  4. Na Omarchy: git pull + ~/.dotfiles/scripts/secrets-inject.sh"
