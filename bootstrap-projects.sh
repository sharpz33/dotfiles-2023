#!/usr/bin/env zsh
# bootstrap-projects.sh
# Klonuje wszystkie repozytoria do ~/Projects na nowej maszynie.
#
# WYMAGANIA:
#   - SSH key dodany do github.com (ssh -T git@github.com)
#   - SSH key dodany do gitlab.com  (dla repos w learning/gitlab-ci)
#   - VPN GFT + SSH key git.gft.com (dla repos 033.gft – użyj flagi --gft)
#
# UŻYCIE:
#   ./bootstrap-projects.sh          # pominęte repos GFT (bez VPN)
#   ./bootstrap-projects.sh --gft    # próbuje też GFT repos (wymaga VPN)
#   ./bootstrap-projects.sh --dry    # dry-run (pokazuje co by zostało sklonowane)

set -uo pipefail

# ─── FLAGS ───────────────────────────────────────────────────────────────────
GFT_MODE=false
DRY_RUN=false
for arg in "$@"; do
  case "$arg" in
    --gft) GFT_MODE=true ;;
    --dry) DRY_RUN=true ;;
    *) echo "Unknown flag: $arg" && exit 1 ;;
  esac
done

# ─── COLORS ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

ERRORS=()
SKIPPED_GFT=()

log_info()    { echo "${BLUE}→${NC} $1"; }
log_success() { echo "${GREEN}✓${NC} $1"; }
log_warn()    { echo "${YELLOW}⚠${NC} $1"; }
log_error()   { echo "${RED}✗${NC} $1"; }
log_skip()    { echo "${CYAN}↩${NC} $1"; }
log_section() { echo "\n${BOLD}── $1 ──${NC}"; }

PROJECTS_DIR="$HOME/Projects"

# ─── CORE FUNCTION ───────────────────────────────────────────────────────────
# clone_repo <relative-path> <url> [note]
clone_repo() {
  local dir="$1"
  local url="$2"
  local note="${3:-}"
  local full_path="$PROJECTS_DIR/$dir"

  # Already a git repo? Skip.
  if [ -d "$full_path/.git" ]; then
    log_skip "already cloned: $dir"
    return 0
  fi

  [ -n "$note" ] && log_warn "$note"

  if $DRY_RUN; then
    log_info "[dry] would clone: $dir"
    log_info "      from: $url"
    return 0
  fi

  log_info "Cloning $dir ..."
  mkdir -p "$(dirname "$full_path")"

  if git clone "$url" "$full_path" 2>&1; then
    log_success "Done: $dir"
  else
    log_error "Failed: $dir"
    ERRORS+=("$dir → $url")
  fi
}

# clone_gft <relative-path> <url>
# Klonuje repo z git.gft.com. Wymaga VPN + SSH key. Użyj flagi --gft.
clone_gft() {
  local dir="$1"
  local url="$2"
  local full_path="$PROJECTS_DIR/$dir"

  if [ -d "$full_path/.git" ]; then
    log_skip "already cloned: $dir"
    return 0
  fi

  if ! $GFT_MODE; then
    SKIPPED_GFT+=("$dir")
    return 0
  fi

  clone_repo "$dir" "$url" "GFT repo – wymaga VPN + SSH key do git.gft.com"
}

# ─── START ───────────────────────────────────────────────────────────────────
echo ""
echo "${BOLD}🚀 bootstrap-projects.sh${NC}"
$DRY_RUN && echo "${YELLOW}[DRY RUN – nic nie zostanie sklonowane]${NC}"
$GFT_MODE && echo "${CYAN}[GFT MODE – próbuję też repos GFT, potrzebujesz VPN]${NC}"
echo ""

mkdir -p "$PROJECTS_DIR"
log_success "~/Projects istnieje"

# ─── ASSISTANTS ──────────────────────────────────────────────────────────────
log_section "ASSISTANTS"

# Root repo – zawiera foldery projektów (ai-biznes-lab-*, etc.)
clone_repo "assistants" \
  "git@github.com:sharpz33/projects-assistants.git"

# Zagnieżdżone repos wewnątrz assistants/ (gitignored w root repo)
clone_repo "assistants/ai-asystenci" \
  "git@github.com:sharpz33/Asystenci_AI.git"

clone_repo "assistants/ai-mentor" \
  "git@github.com:200bar/ai-mentor.git"

# ai-upgrade-lab → brak remote (tylko lokalnie), pomijamy
log_skip "pominięto: assistants/ai-upgrade-lab (brak remote)"

# ─── CLIENTS – GŁÓWNY REPO ───────────────────────────────────────────────────
log_section "CLIENTS – główny repo"

# Root repo – zawiera całą strukturę klientów 001-036+
clone_repo "clients" \
  "git@github.com:sharpz33/projects-clients.git"

# ─── CLIENTS – ZAGNIEŻDŻONE (200bar / publiczne) ─────────────────────────────
log_section "CLIENTS – zagnieżdżone repos (publiczne)"

clone_repo "clients/036.nowemozliwosci/036.001.terra-recycling-greenwashing-ai/repo/terra.200bar.studio" \
  "https://github.com/200bar/terra-greenwashing-prompty.git"

clone_repo "clients/036.nowemozliwosci/036.002.pgkim-krotoszyn-ai/repo/pgkim.200bar.studio" \
  "https://github.com/200bar/pgkim-ai-prompty.git"

clone_repo "clients/035.natasha-malek/035.001.mvp-zyje/repo/zyje" \
  "git@github.com:200bar/zyje.git"

clone_repo "clients/005.200bar-studio/005.019.200bar-studio-contact-form" \
  "https://github.com/200bar/200bar-studio-contact-form.git"

clone_repo "clients/005.200bar-studio/005.020.claude-polymarket-bot/repo/polymarket-trading-bot" \
  "https://github.com/discountry/polymarket-trading-bot.git"

clone_gft "clients/033.gft/033.021.ai-cost-calculator" \
  "git@github.com:200bar/gft-ai-cost-calculator.git"

clone_gft "clients/033.gft/033.016.pekao-legacy-transformation/repo/microsoft-camf" \
  "https://github.com/Azure-Samples/Legacy-Modernization-Agents.git"

# ─── CLIENTS – ZAGNIEŻDŻONE (GFT / wewnętrzne – wymaga VPN) ─────────────────
log_section "CLIENTS – zagnieżdżone repos GFT (wymaga VPN + git.gft.com SSH)"

clone_gft "clients/033.gft/033.018.ai-code-migration-poc/repo/ai-code-transformer" \
  "git@git.gft.com:devops-pl/ai-code-transformer.git"

clone_gft "clients/033.gft/033.018.ai-code-migration-poc/repo/ai-code-transformer-tests" \
  "git@git.gft.com:devops-pl/ai-code-transformer-tests.git"

clone_gft "clients/033.gft/033.011.cobol-wynxx/wynxx-plus-poc" \
  "git@git.gft.com:tzkk/wynxx-plus-poc.git"

clone_gft "clients/033.gft/033.007.chat-app" \
  "git@git.gft.com:devops-pl/litellm-chat-app.git"

clone_gft "clients/033.gft/033.006.prompt-engineering/prompt-engineering-devops" \
  "git@git.gft.com:devops-pl/prompt-engineering-devops.git"

clone_gft "clients/033.gft/033.006.prompt-engineering/_archive/prompt-engineering-course" \
  "git@git.gft.com:devops-pl/prompt-engineering-course.git"

clone_gft "clients/033.gft/033.016.pekao-legacy-transformation/repo/pekao-bas-poc" \
  "https://git.gft.com/client-pl-pekao-sa/pekao-bas-poc.git"

# UWAGA: Repos poniżej (033.005.wynxx/*) mają ten sam remote co główny clients repo.
# Oznacza to, że są lokalnymi repozytoriami lub worktrees – nie mają osobnego remote.
# Po sklonowaniu clients/ zawartość powinna być dostępna w tych folderach.
# Jeśli foldery są puste, ustaw je ręcznie (git init + git remote add).
# Dotyczy:
#   clients/033.gft/033.005.wynxx/ai-impact
#   clients/033.gft/033.005.wynxx/ai-impact-aws
#   clients/033.gft/033.005.wynxx/ai-impact-gcp
#   clients/033.gft/033.005.wynxx/ai-impact-main
#   clients/033.gft/033.005.wynxx/ai-impact-source-code
#   clients/033.gft/033.005.wynxx/_aws_demo
#   clients/033.gft/033.005.wynxx/learn-terraform-provision-eks-cluster
#   clients/033.gft/033.004.gft-assist/openai-loadbalancer
#   clients/033.gft/033.004.gft-assist/genai-platform-terraform
#   clients/033.gft/033.004.gft-assist/chat-frontend

# ─── PRIV ────────────────────────────────────────────────────────────────────
log_section "PRIV"

clone_repo "priv/plane-app" \
  "git@github.com:sharpz33/plane-app.git"

clone_repo "priv/coinwatch" \
  "git@github.com:sharpz33/coinwatch.git"

clone_repo "priv/vps-bootstrap" \
  "git@github.com:sharpz33/vps-bootstrap.git"

# ─── LEARNING ────────────────────────────────────────────────────────────────
log_section "LEARNING"

clone_repo "learning/learn-terraform-azure-ad" \
  "https://github.com/hashicorp-education/learn-terraform-azure-ad"

clone_repo "learning/copilot-terraform" \
  "https://github.com/copilot-workshops/copilot-terraform.git"

# GitLab repos (gitlab.com SSH)
clone_repo "learning/gitlab-ci/demo_repos/backend" \
  "git@gitlab.com:demo-gft/backend.git"

clone_repo "learning/gitlab-ci/demo_repos/ci-admin" \
  "git@gitlab.com:demo-gft/ci-admin.git"

# kurs-gitlab-ci → pominięty, URL zawierał osobisty token (ustaw ręcznie)
log_skip "pominięto: learning/gitlab-ci/kurs-gitlab-ci (URL z tokenem – sklonuj ręcznie)"

# ─── SYMLINKS ─────────────────────────────────────────────────────────────────
log_section "SYMLINKS"

# gft → clients/033.gft (skrót do katalogów GFT – tylko z --gft)
if $GFT_MODE; then
  if [ -L "$PROJECTS_DIR/gft" ]; then
    log_skip "already exists: gft → $(readlink "$PROJECTS_DIR/gft")"
  elif [ -d "$PROJECTS_DIR/gft" ]; then
    log_warn "gft/ istnieje jako katalog (nie symlink) – sprawdź ręcznie"
  else
    if $DRY_RUN; then
      log_info "[dry] would symlink: gft → clients/033.gft"
    else
      ln -s "clients/033.gft" "$PROJECTS_DIR/gft"
      log_success "Symlink: gft → clients/033.gft"
    fi
  fi
else
  log_skip "symlink gft → clients/033.gft (wymaga --gft)"
fi

# ─── PODSUMOWANIE ────────────────────────────────────────────────────────────
log_section "PODSUMOWANIE"

if [ ${#ERRORS[@]} -eq 0 ]; then
  log_success "Wszystko ok!"
else
  log_warn "Błędy przy klonowaniu (${#ERRORS[@]}):"
  for e in "${ERRORS[@]}"; do
    echo "  ${RED}•${NC} $e"
  done
fi

if [ ${#SKIPPED_GFT[@]} -gt 0 ]; then
  echo ""
  log_warn "Pominięto ${#SKIPPED_GFT[@]} repos GFT (brak flagi --gft lub VPN):"
  for r in "${SKIPPED_GFT[@]}"; do
    echo "  ${CYAN}•${NC} $r"
  done
  echo ""
  echo "  Uruchom z VPN GFT włączonym:"
  echo "  ${CYAN}~/.dotfiles/bootstrap-projects.sh --gft${NC}"
fi

echo ""
log_warn "Repos wymagające ręcznej konfiguracji:"
echo "  ${YELLOW}•${NC} assistants/ai-upgrade-lab          (brak remote – lokalny)"
echo "  ${YELLOW}•${NC} learning/gitlab-ci/kurs-gitlab-ci  (sklonuj ręcznie z własnym tokenem)"
echo "  ${YELLOW}•${NC} clients/033.gft/033.005.wynxx/*    (worktrees/lokalne – sprawdź po clone clients)"
echo ""
