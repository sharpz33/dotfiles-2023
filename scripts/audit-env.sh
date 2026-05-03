#!/usr/bin/env bash
# audit-env.sh — cross-platform audit środowiska (Mac + Omarchy)
# Cel: wypluć log z którego widać CO jest, A CZEGO BRAK do działania CC + skilli.
#
# Output: ~/Projects/assistants/aibl/DRAFTS/omarchy-migration/audit-{hostname}-{date}.log
# Bez sekretów. Tylko nazwy env var, nigdy wartości.

set -uo pipefail
. "$HOME/.dotfiles/lib/os-detect.sh"

HOSTNAME_SHORT=$(hostname -s 2>/dev/null || hostname)
DATE=$(date +%Y-%m-%d)
LOG_DIR="$HOME/Projects/assistants/aibl/DRAFTS/omarchy-migration"
LOG="$LOG_DIR/audit-${HOSTNAME_SHORT}-${DATE}.log"
mkdir -p "$LOG_DIR"

# Wszystko do logu i na ekran
exec > >(tee "$LOG") 2>&1

hr() { printf '\n──── %s ────\n\n' "$1"; }

hr "OS"
uname -a
if is_macos; then
  sw_vers 2>/dev/null
  echo "Arch: $(uname -m)"
elif is_linux; then
  cat /etc/os-release 2>/dev/null | head -5
fi

hr "SHELL & TERMINAL"
echo "SHELL=$SHELL"
echo "TERM=$TERM"
echo "TERM_PROGRAM=${TERM_PROGRAM:-?}"
zsh --version 2>/dev/null
bash --version 2>/dev/null | head -1
echo "Oh My Zsh: $([ -d "$HOME/.oh-my-zsh" ] && echo INSTALLED || echo MISSING)"
echo "p10k:      $([ -f "$HOME/.p10k.zsh" ] && echo INSTALLED || echo MISSING)"

hr "CLI TOOLS — versions"
TOOLS=(
  claude op gh glab git lazygit
  brew pacman yay paru
  node npm nvm pyenv python3 pip pip3
  rg fd jq fzf bat eza tree
  nvim zed code ghostty
  aws gcloud az kubectl helm terraform
  docker colima
  ffmpeg yt-dlp
  md-to-pdf gws n8n
  ssh-add curl wget rsync
)
for t in "${TOOLS[@]}"; do
  if command -v "$t" >/dev/null 2>&1; then
    VERSION=$("$t" --version 2>&1 | head -1 | tr -d '\n')
    printf '  %-15s ✓ %s\n' "$t" "$VERSION"
  else
    printf '  %-15s ✗ MISSING\n' "$t"
  fi
done

hr "NPM GLOBALS"
if command -v npm >/dev/null 2>&1; then
  npm list -g --depth=0 2>/dev/null | tail -n +2
else
  echo "npm not installed"
fi

hr "PIP GLOBALS (top 30)"
if command -v pip3 >/dev/null 2>&1; then
  pip3 list 2>/dev/null | head -30
fi

hr "PATH"
echo "$PATH" | tr ':' '\n'

hr "ENV VARS — nazwy (bez wartości) z ~/.secrets"
if [ -f "$HOME/.secrets" ]; then
  grep -E '^export [A-Z_][A-Z0-9_]*=' "$HOME/.secrets" | \
    sed -E 's/^export ([A-Z_][A-Z0-9_]*)=.*/  \1/' | sort -u
else
  echo "  brak ~/.secrets"
fi

hr "ENV VARS — z ~/.zshrc (export bez wartości)"
if [ -f "$HOME/.zshrc" ]; then
  grep -E '^export [A-Z_][A-Z0-9_]*=' "$HOME/.zshrc" | \
    sed -E 's/^export ([A-Z_][A-Z0-9_]*)=.*/  \1/' | sort -u
fi

hr "ENV VARS — runtime (wybrane krytyczne, tylko PRESENT/MISSING)"
CRITICAL=(
  ANTHROPIC_API_KEY OPENAI_KEY OPENAI_API_KEY
  AZURE_API_KEY AZURE_OPENAI_API_KEY
  AIRTABLE_TOKEN TELEGRAM_BOT_TOKEN
  RESEND_API_KEY GMAIL_APP_PASSWORD
  FAKTUROWNIA_API_TOKEN INSTAPAPER_EMAIL
  CLOUDFLARE_API_TOKEN CLOUDFLARE_ACCOUNT_ID
  DISCORD_WEBHOOK_MAIL DISCORD_APP_ID
  GFT_LLM_ROUTER_QA_TOKEN
  DOCINTEL_KEY STORAGE_CONN
)
for v in "${CRITICAL[@]}"; do
  if [ -n "${!v:-}" ]; then printf '  %-30s ✓ set\n' "$v"
  else printf '  %-30s ✗ missing\n' "$v"; fi
done

hr "SSH KEYS (publiczne)"
ls -la "$HOME/.ssh/"*.pub 2>/dev/null
echo "--- pub key contents (safe to share) ---"
for k in "$HOME/.ssh/"*.pub; do
  [ -f "$k" ] && { echo "# $k"; cat "$k"; echo; }
done

hr "1Password CLI"
if command -v op >/dev/null 2>&1; then
  op --version
  if op vault list >/dev/null 2>&1; then
    echo "  signed in ✓"
    op vault list 2>/dev/null | head -10
  else
    echo "  NOT signed in (run: eval \$(op signin))"
  fi
else
  echo "op CLI MISSING"
fi

hr "AWS / GCLOUD identity"
if command -v aws >/dev/null 2>&1; then
  aws sts get-caller-identity 2>&1 | head -10 || echo "  aws not configured"
fi
if command -v gcloud >/dev/null 2>&1; then
  gcloud auth list 2>&1 | head -10 || echo "  gcloud not configured"
  gcloud config list account 2>&1 | head -3
fi

hr "Claude Code config"
echo "Binary: $(command -v claude || echo MISSING)"
[ -d "$HOME/.claude" ] && du -sh "$HOME/.claude" 2>/dev/null
echo "Skills global (~/.claude/skills):"
ls "$HOME/.claude/skills/" 2>/dev/null | head -20 || echo "  brak"
echo "Hooks global (~/.claude/hooks):"
ls "$HOME/.claude/hooks/" 2>/dev/null | head -20 || echo "  brak"
echo "Commands global (~/.claude/commands):"
ls "$HOME/.claude/commands/" 2>/dev/null | head -20 || echo "  brak"
echo "Plugins global (~/.claude/plugins):"
ls "$HOME/.claude/plugins/" 2>/dev/null | head -20 || echo "  brak"

hr "Skille per-projekt (assistants)"
for proj in aibl aiul ai-money-lab ai-marketing-lab ai-mentor ai-asystenci; do
  D="$HOME/Projects/assistants/$proj/.claude"
  if [ -d "$D" ]; then
    echo "[$proj]"
    [ -d "$D/skills" ] && echo "  skills: $(ls "$D/skills" 2>/dev/null | tr '\n' ' ')"
    [ -d "$D/hooks" ]  && echo "  hooks:  $(ls "$D/hooks" 2>/dev/null | tr '\n' ' ')"
    [ -d "$D/rules" ]  && echo "  rules:  $(ls "$D/rules" 2>/dev/null | tr '\n' ' ')"
    [ -f "$D/settings.json" ] && echo "  settings.json: ✓"
    [ -f "$D/settings.local.json" ] && echo "  settings.local.json: ✓ (gitignored)"
  fi
done

hr "Hardcoded /Users/e-uzoi paths w repo"
for proj in aibl aiul ai-money-lab ai-marketing-lab; do
  D="$HOME/Projects/assistants/$proj"
  [ -d "$D" ] || continue
  echo "[$proj]"
  cd "$D" && grep -rn "/Users/e-uzoi" \
    --include="*.md" --include="*.sh" --include="*.py" \
    --include="*.js" --include="*.ts" --include="*.json" \
    --include="*.yml" --include="*.yaml" \
    -l 2>/dev/null | sed 's|^|  |' || echo "  (czysto)"
done

hr "macOS-specific komendy w skryptach assistants"
cd "$HOME/Projects/assistants" || exit 0
grep -rEn "sed -i ''|stat -f|base64 -D|date -j|readlink -f|pbcopy|pbpaste|/opt/homebrew|defaults write|launchctl" \
  --include="*.sh" --include="*.py" \
  aibl aiul ai-money-lab ai-marketing-lab 2>/dev/null | head -30 || echo "(czysto)"

hr "Repos w ~/Projects (z remote)"
find "$HOME/Projects" -maxdepth 4 -name ".git" -type d 2>/dev/null | while read git_dir; do
  REPO=$(dirname "$git_dir")
  REL=${REPO#$HOME/}
  REMOTE=$(cd "$REPO" && git remote get-url origin 2>/dev/null || echo "(no remote)")
  printf '  %-60s %s\n' "$REL" "$REMOTE"
done

hr "Pliki .gitignore w assistants (czy tymczasowe wyjęte)"
for proj in aibl aiul ai-money-lab ai-marketing-lab; do
  GI="$HOME/Projects/assistants/$proj/.gitignore"
  if [ -f "$GI" ]; then
    echo "[$proj/.gitignore]"
    cat "$GI" | sed 's/^/  /'
  fi
done

hr "DONE"
echo "Audit zapisany do: $LOG"
echo "Hostname: $HOSTNAME_SHORT, OS: $(uname -s), Date: $DATE"
