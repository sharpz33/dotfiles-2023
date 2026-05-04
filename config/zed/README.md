# Zed — cheatsheet i setup

Konfiguracja: `settings.json` + `keymap.json` + `tasks.json` w tym katalogu.
Symlink: `~/.config/zed/` → `~/.dotfiles/config/zed/` (sync Mac ↔ Omarchy).
Zasada: **kickstart.nvim parity** — leader = `space`, te same skróty co w `~/.config/nvim/`.

---

## Keybindy (kickstart parity)

### Search / nawigacja

| Akcja | Skrót |
|---|---|
| Find files | `space s f` |
| Live grep (project-wide) | `space s g` |
| Recent files | `space s .` |
| Switch buffer | `space space` |
| Search w current buffer | `space /` |
| Diagnostics list | `space s d` lub `space q` |
| Command palette | `space s h` / `space s k` / `space s s` |

### LSP / kod

| Akcja | Skrót |
|---|---|
| Goto definition | `g d` |
| Goto declaration | `g D` |
| References | `g r` |
| Implementations | `g I` |
| Type definition | `space D` |
| Document symbols | `space d s` |
| Workspace symbols | `space w s` |
| Rename | `space r n` |
| Code action | `space c a` |
| Format buffer | `space f` |

### Panele

| Akcja | Skrót |
|---|---|
| File explorer toggle | `space e` |
| Outline panel | `space o` |
| Terminal toggle | `space t` |
| Agent panel toggle | `space a` |

### Vim ergonomy

| Akcja | Skrót |
|---|---|
| Insert → normal | `j k` lub `k j` |
| Window navigation | `Ctrl-h/j/k/l` |
| Clear search highlight | `Esc` |

### AI

| Akcja | Skrót |
|---|---|
| New Claude Agent thread | `space a n` lub `Cmd-Alt-C` |
| New Codex thread | `space a c` |
| Inline completion | tab (Copilot) |

### VSCode-style (z `base_keymap`)

| Akcja | Skrót |
|---|---|
| Quick open file | `Cmd-p` |
| Command palette | `Cmd-Shift-p` |
| Find in files | `Cmd-Shift-f` |
| Toggle sidebar | `Cmd-b` |
| Toggle terminal | `Cmd-\`` |

### Markdown preview

Z edytora `.md`:

| Akcja | Skrót |
|---|---|
| Preview w nowym tabie | `Cmd-Shift-V` lub `space m v` |
| Preview side-by-side (split right) | `Cmd-Shift-M` lub `space m p` |

W preview (read-only view, własny kontekst):

| Akcja | Skrót |
|---|---|
| Zamknij preview | `q` lub `Cmd-W` lub `Cmd-Shift-V` |
| Search w preview | `/` lub `Cmd-F` |
| Next / prev match | `n` / `Shift-N` |
| Scroll line down/up | `j` / `k` |
| Top / bottom | `g g` / `Shift-G` |
| Half-page down/up | `Ctrl-D` / `Ctrl-U` |
| Full-page down/up | `PgDn`/`PgUp` lub `Shift-J`/`Shift-K` |
| Pane navigation | `Ctrl-h/j/k/l` |

> `Ctrl-F`/`Ctrl-B` celowo nieużyte — Cocoa łapie je systemowo i nadpisuje binding.

---

## Tasks (`Cmd-Shift-p` → "task: spawn")

Zdefiniowane w `tasks.json` — uruchom z palety lub `task::Spawn`.

| Tag | Tasks |
|---|---|
| flutter | run (debug/profile), test, pub get, clean, doctor, build apk |
| android | list AVDs, start AVD (Pixel) |
| go | test ./..., build |
| python | ruff check, ruff format |
| terraform | init, plan, validate |
| (default) | dart devtools, lazygit |

---

## Manualne TODO przed pierwszym użyciem

1. **Otwórz Zed nową sesją** — auto-install extensions zaskoczy sam (themes + languages: Terraform, Ruby, Dart, Just, Dockerfile, Mermaid, Git Firefly).

2. **Sign-in GitHub Copilot**: status bar → ikona Copilot → "Sign in" → flow OAuth w przeglądarce.

3. **Agent panel — Claude Agent**: `space a` (lub `Cmd-Alt-C`) → "New Claude Agent thread" → `/login` w panelu → flow OAuth do Claude.ai. Subskrypcja Claude Code = wykorzysta się automatycznie.

4. **Agent panel — Codex (ChatGPT Enterprise)**: `space a c` → flow auth.

5. **Flutter doctor**:
   ```bash
   flutter doctor
   flutter doctor --android-licenses
   ```

6. **Android Studio**: pierwszy launch → konfigurator (SDK download, AVD setup). Potem z Zed używasz tylko emulatora (`task: android: start AVD`).

7. **Berkeley Mono Trial test**: sprawdź dokładną nazwę OTF
   ```bash
   fc-list | grep -i berkeley
   ```
   Następnie w `settings.json` zmień `buffer_font_family` na nazwę z fc-list.

8. **Backup migracji**: `~/.config/zed.bak/` zostawić ~tydzień (gdyby coś rozjebane), potem `rm -rf ~/.config/zed.bak`.

---

## Fonty zainstalowane (do testów)

| Font | `buffer_font_family` |
|---|---|
| Maple Mono NF (default) | `Maple Mono NF` |
| Monaspace Neon | `Monaspace Neon` (lub Argon/Krypton/Radon/Xenon) |
| JetBrains Mono | `JetBrainsMono Nerd Font` |
| Geist Mono | `GeistMono Nerd Font` |
| Commit Mono | `CommitMono Nerd Font` |
| Iosevka | `Iosevka Nerd Font` |
| Berkeley Mono Trial | `BerkeleyMonoTrial-Regular` (sprawdź `fc-list`) |

Po wyborze 1-2 — pozostałe usuń z Brewfile + `brew bundle cleanup --force`.

---

## Themes zainstalowane (auto-switch z macOS Appearance)

| Pair | Light | Dark |
|---|---|---|
| **Gruvbox Material** (default) | `Gruvbox Material Light` | `Gruvbox Material Dark` |
| Catppuccin | `Catppuccin Latte` | `Catppuccin Mocha` |
| Rose Pine | `Rosé Pine Dawn` | `Rosé Pine` (lub Moon) |
| Tokyo Night | `Tokyo Night Day` | `Tokyo Night` |
| Ayu | `Ayu Light` | `Ayu Dark` (lub Mirage) |
| Solarized | `Solarized Light` | `Solarized Dark` |
| Monokai | (no light) | `Monokai Pro` |

Zmiana w `settings.json` → `theme.light` / `theme.dark`. Po wyborze — pozostałe ext usuń.

---

## AI strategy

| Slot | Provider | Konfig |
|---|---|---|
| Inline completion | GitHub Copilot | `edit_predictions.provider: "copilot"` |
| Agent panel #1 (default) | Claude Agent (subskrypcja CC) | `agent_servers.claude-acp` (registry) |
| Agent panel #2 | Codex (ChatGPT Enterprise) | `agent_servers.codex-acp` (registry) |
| Terminal | `claude` CLI / `codex` CLI | w terminal panel Zed |
| GH Copilot CLI (klient) | `gh copilot suggest/explain` | osobny `gh` plugin, używasz w Ghostty |

---

## Format-on-save (globalnie ON)

| Język | Formatter |
|---|---|
| Python | `ruff` (LSP, organize imports on format) |
| TS / JS / JSON / YAML | `prettier` (auto-pickup z projektu) |
| Go | `gofmt` (via gopls) |
| Ruby | `ruby-lsp` |
| Terraform | `terraform fmt` (via terraform-ls) |
| Bash | `shfmt -i 2 -ci -bn` |
| Dart | `dart format` (via Dart LSP) |
| Markdown | OFF (whitespace bywa składniowy) |
| HTML / CSS | wbudowany Zed LSP |

---

## Sync (Mac ↔ Omarchy)

`~/.dotfiles` na obu maszynach. Zed config = symlink z dotfiles. Zmiana w settings.json = commit+push w dotfiles repo, na drugim laptopie `git pull` → już jest.

Data dirs (`embeddings/`, `conversations/`, `prompts/`) **NIE** są syncowane (są w `.gitignore` dotfiles).
