#!/usr/bin/env bash
# validate-claude-setup.sh — kompleksowa walidacja środowiska CC + skille.
# Cross-platform (Mac + Omarchy). Pass/fail per test, exit code = liczba fail.
#
# Output: ~/Projects/assistants/aibl/DRAFTS/omarchy-migration/validate-{host}-{date}.log

set -uo pipefail
. "$HOME/.dotfiles/lib/os-detect.sh" 2>/dev/null || true

# Load nvm jeśli istnieje (md-to-pdf, gws itp. są w nvm node bin)
if [ -s "$HOME/.nvm/nvm.sh" ]; then
  # shellcheck disable=SC1091
  \. "$HOME/.nvm/nvm.sh"
elif [ -s /usr/share/nvm/init-nvm.sh ]; then
  # shellcheck disable=SC1091
  source /usr/share/nvm/init-nvm.sh
elif command -v brew >/dev/null 2>&1 && [ -s "$(brew --prefix)/opt/nvm/nvm.sh" ]; then
  # shellcheck disable=SC1091
  source "$(brew --prefix)/opt/nvm/nvm.sh"
fi
# Source secrets żeby env vary były widoczne
[ -f "$HOME/.secrets" ] && source "$HOME/.secrets" 2>/dev/null || true

HOSTNAME_SHORT=$(hostname -s 2>/dev/null || hostname)
DATE=$(date +%Y-%m-%d-%H%M)
LOG_DIR="$HOME/Projects/assistants/aibl/DRAFTS/omarchy-migration"
mkdir -p "$LOG_DIR" 2>/dev/null
LOG="$LOG_DIR/validate-${HOSTNAME_SHORT}-${DATE}.log"

exec > >(tee "$LOG") 2>&1

PASS=0
FAIL=0
SKIP=0

# ─── helpers ─────────────────────────────────────────────────────────────────
ok()    { echo "  ✓ $1"; PASS=$((PASS+1)); }
fail()  { echo "  ✗ $1${2:+ — $2}"; FAIL=$((FAIL+1)); }
skipt() { echo "  ↩ $1${2:+ — $2}"; SKIP=$((SKIP+1)); }
section(){ echo; echo "── $1 ──"; }

# Generic: command is available
need_cmd() {
  if command -v "$1" >/dev/null 2>&1; then ok "$1 ($("$1" --version 2>&1 | head -1 | tr -d '\n' | cut -c1-60))"
  else fail "$1" "missing"; fi
}

# Optional command (skip if missing)
opt_cmd() {
  if command -v "$1" >/dev/null 2>&1; then ok "$1 ($("$1" --version 2>&1 | head -1 | tr -d '\n' | cut -c1-60))"
  else skipt "$1" "optional, missing"; fi
}

# Env var present (don't echo value)
need_env() {
  if [ -n "${!1:-}" ]; then ok "\$$1 set"
  else fail "\$$1" "missing in env"; fi
}

# File exists
need_file() {
  if [ -f "$1" ]; then ok "$1"
  else fail "$1" "missing"; fi
}

# Dir exists
need_dir() {
  if [ -d "$1" ]; then ok "$1/"
  else fail "$1/" "missing"; fi
}

# ─── HEADER ──────────────────────────────────────────────────────────────────
echo "════════════════════════════════════════════════════════════════"
echo "  Claude Code Setup Validation"
echo "  Host:   $HOSTNAME_SHORT"
echo "  OS:     $(uname -s) $(uname -r)"
echo "  Date:   $DATE"
echo "  Log:    $LOG"
echo "════════════════════════════════════════════════════════════════"

# ─── 1. CORE CLI ─────────────────────────────────────────────────────────────
section "1. CORE CLI"
for cmd in git curl wget rsync ssh jq zsh bash; do need_cmd "$cmd"; done

# ─── 2. LANGUAGES ────────────────────────────────────────────────────────────
section "2. LANGUAGES"
need_cmd python3
need_cmd pip3
need_cmd node
need_cmd npm
opt_cmd pyenv
opt_cmd nvm

# ─── 3. SEARCH / FILES / EDITOR ──────────────────────────────────────────────
section "3. SEARCH / EDITOR"
for cmd in rg fd fzf bat eza nvim; do need_cmd "$cmd"; done
opt_cmd zed
opt_cmd ghostty

# ─── 4. CLOUD / DEVOPS ───────────────────────────────────────────────────────
section "4. CLOUD / DEVOPS"
need_cmd gh
opt_cmd op
opt_cmd aws
opt_cmd gcloud
opt_cmd az
opt_cmd lazygit

# ─── 5. SKILLS DEPENDENCIES ──────────────────────────────────────────────────
section "5. SKILLS DEPENDENCIES"
need_cmd md-to-pdf
need_cmd pandoc
need_cmd ffmpeg
opt_cmd yt-dlp

# ─── 6. CLAUDE CODE BINARY ───────────────────────────────────────────────────
section "6. CLAUDE CODE"
if command -v claude >/dev/null 2>&1; then
  ok "claude binary: $(command -v claude) → $(claude --version 2>/dev/null || echo '?')"
else
  fail "claude" "binary missing — install via: curl -fsSL https://claude.ai/install.sh | bash"
fi

# ─── 7. CLAUDE CODE CONFIG (~/.claude) ───────────────────────────────────────
section "7. CC CONFIG (~/.claude)"
need_dir "$HOME/.claude"
need_file "$HOME/.claude/settings.json"
need_dir "$HOME/.claude/skills"
need_dir "$HOME/.claude/hooks"
# Hook musi być executable (na Omarchy git pull może zgubić chmod +x)
HOOK="$HOME/.claude/hooks/rtk-rewrite.sh"
if [ -f "$HOOK" ]; then
  if [ -x "$HOOK" ]; then ok "$HOOK (executable)"
  else fail "$HOOK" "not executable — chmod +x"; fi
fi
# Settings JSON parsable
if command -v jq >/dev/null 2>&1 && [ -f "$HOME/.claude/settings.json" ]; then
  if jq empty "$HOME/.claude/settings.json" 2>/dev/null; then ok "settings.json valid JSON"
  else fail "settings.json" "invalid JSON"; fi
fi

# ─── 8. PROJECT REPOS (~/Projects) ───────────────────────────────────────────
section "8. PROJECT REPOS"
need_dir "$HOME/Projects/assistants"
need_dir "$HOME/Projects/assistants/aibl"
need_dir "$HOME/Projects/assistants/aiul"
need_dir "$HOME/Projects/assistants/ai-money-lab"
need_dir "$HOME/Projects/clients"
need_file "$HOME/Projects/assistants/aibl/CLAUDE.md"

# ─── 8b. OBSIDIAN VAULT ──────────────────────────────────────────────────────
section "8b. OBSIDIAN VAULT"
if [ -d "$HOME/vaults/obsidian" ]; then
  NOTE_COUNT=$(find "$HOME/vaults/obsidian" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
  VAULT_SIZE=$(du -sh "$HOME/vaults/obsidian" 2>/dev/null | cut -f1)
  ok "~/vaults/obsidian/ ($NOTE_COUNT notatek MD, $VAULT_SIZE)"
  if [ -d "$HOME/vaults/obsidian/.obsidian" ]; then
    ok ".obsidian/ config present"
  else
    fail ".obsidian/" "config missing — vault może być niesynchronizowany"
  fi
else
  fail "~/vaults/obsidian/" "missing — odpal sync-obsidian-vault.sh"
fi
opt_cmd obsidian

# ─── 9. SECRETS / ENV VARS ───────────────────────────────────────────────────
section "9. SECRETS / ENV VARS"
need_file "$HOME/.secrets"
# Source secrets jeśli nie auto-loaded
if [ -f "$HOME/.secrets" ]; then
  # shellcheck disable=SC1090
  source "$HOME/.secrets" 2>/dev/null || true
fi
for v in ANTHROPIC_API_KEY OPENAI_KEY AZURE_API_KEY FAKTUROWNIA_API_TOKEN \
         INSTAPAPER_EMAIL CLOUDFLARE_API_TOKEN DISCORD_WEBHOOK_MAIL; do
  need_env "$v"
done

# ─── 10. 1PASSWORD CLI ───────────────────────────────────────────────────────
section "10. 1PASSWORD CLI"
if command -v op >/dev/null 2>&1; then
  if op vault list >/dev/null 2>&1; then ok "op signed in"
  else fail "op" "not signed in — run: eval \$(op signin)"; fi
else
  skipt "op CLI" "missing (optional but recommended)"
fi

# ─── 11. AWS / GCLOUD IDENTITY ───────────────────────────────────────────────
section "11. CLOUD IDENTITY"
if command -v aws >/dev/null 2>&1; then
  ARN=$(aws sts get-caller-identity --query Arn --output text 2>/dev/null || echo "")
  if [ -n "$ARN" ]; then ok "AWS: $ARN"
  else fail "aws sts" "not configured"; fi
fi
if command -v gcloud >/dev/null 2>&1; then
  ACC=$(gcloud config get-value account 2>/dev/null || echo "")
  if [ -n "$ACC" ] && [ "$ACC" != "(unset)" ]; then ok "gcloud: $ACC"
  else fail "gcloud" "no active account"; fi
fi
if command -v gh >/dev/null 2>&1; then
  if gh auth status >/dev/null 2>&1; then ok "gh authenticated"
  else fail "gh auth" "run: gh auth login"; fi
fi

# ─── 12. NETWORK APIS ────────────────────────────────────────────────────────
section "12. NETWORK APIS"
# AIBL Network API (jeśli jest API key — z memory: Bearer ak_...)
if [ -n "${AIBL_NETWORK_API_KEY:-}" ]; then
  CODE=$(curl -s -o /dev/null -w "%{http_code}" \
    -H "Authorization: Bearer $AIBL_NETWORK_API_KEY" \
    https://api.labclub.ai/v1/profile 2>/dev/null || echo "000")
  case "$CODE" in
    200|404) ok "AIBL Network API reachable (HTTP $CODE)" ;;
    *) fail "AIBL Network API" "HTTP $CODE" ;;
  esac
else
  skipt "AIBL Network API" "no AIBL_NETWORK_API_KEY"
fi

# n8n API (jeśli jest token — sprawdzić)
if [ -n "${N8N_API_KEY:-}" ]; then
  CODE=$(curl -s -o /dev/null -w "%{http_code}" \
    -H "X-N8N-API-KEY: $N8N_API_KEY" \
    --max-time 5 \
    https://200barstudio.com/api/v1/workflows 2>/dev/null)
  CODE=${CODE:-000}
  case "$CODE" in
    200) ok "n8n API reachable (HTTP $CODE)" ;;
    *) fail "n8n API" "HTTP $CODE" ;;
  esac
else
  skipt "n8n API" "no N8N_API_KEY"
fi

# Anthropic API ping
if [ -n "${ANTHROPIC_API_KEY:-}" ]; then
  CODE=$(curl -s -o /dev/null -w "%{http_code}" \
    -H "x-api-key: $ANTHROPIC_API_KEY" \
    -H "anthropic-version: 2023-06-01" \
    https://api.anthropic.com/v1/models 2>/dev/null || echo "000")
  case "$CODE" in
    200) ok "Anthropic API reachable (HTTP $CODE)" ;;
    *) fail "Anthropic API" "HTTP $CODE" ;;
  esac
fi

# ─── 13. PDF GENERATION (md-to-pdf) ──────────────────────────────────────────
section "13. PDF GENERATION"
if command -v md-to-pdf >/dev/null 2>&1; then
  TMPMD=$(mktemp -t mdpdf.XXXXXX.md 2>/dev/null || mktemp /tmp/mdpdf.XXXXXX.md)
  echo "# Test PDF — $(date)" > "$TMPMD"
  echo "Cross-platform validation." >> "$TMPMD"
  if md-to-pdf "$TMPMD" >/dev/null 2>&1; then
    PDFOUT="${TMPMD%.md}.pdf"
    if [ -f "$PDFOUT" ]; then
      SIZE=$(wc -c < "$PDFOUT" | tr -d ' ')
      ok "md-to-pdf generated PDF (${SIZE} bytes)"
      rm -f "$PDFOUT"
    else
      fail "md-to-pdf" "ran without error but no PDF created"
    fi
  else
    fail "md-to-pdf" "execution failed (Chromium issue na Linuxie? sprawdź puppeteer deps)"
  fi
  rm -f "$TMPMD"
fi

# ─── SUMMARY ─────────────────────────────────────────────────────────────────
section "SUMMARY"
TOTAL=$((PASS+FAIL+SKIP))
echo "Total: $TOTAL  |  ✓ Pass: $PASS  |  ✗ Fail: $FAIL  |  ↩ Skip: $SKIP"
echo
if [ "$FAIL" -eq 0 ]; then
  echo "🎉 Wszystko OK. Setup gotowy do produkcji."
  exit 0
else
  echo "⚠ $FAIL test(ów) nie przeszło. Log: $LOG"
  echo "Napraw failuje, odpal ponownie."
  exit "$FAIL"
fi
