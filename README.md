# Dotfiles

My personal macOS dotfiles for DevOps/Cloud Engineering workflow. Automates the setup of a new Mac with all tools, configurations, and preferences.

## What This Repo Does

This repository provides a **fully automated setup** for a fresh macOS installation tailored for DevOps and Cloud Engineering work. Running a single script (`fresh.sh`) will:

1. **Install essential tools**: Homebrew, Oh My Zsh, Powerlevel10k theme
2. **Configure your shell**: Zsh with custom aliases, PATH settings, and integrations (pyenv, nvm, gcloud)
3. **Install 100+ applications**: Via Brewfile including cloud CLIs (Azure, GCP, AWS), container tools (Docker/Colima, kubectl), development tools (VS Code, Neovim), and productivity apps
4. **Apply macOS tweaks**: System preferences optimized for developers (fast keyboard repeat, disabled auto-corrections, hidden menu bar, etc.)
5. **Set up version managers**: Python (pyenv), Node.js (nvm), with automatic virtual environment handling
6. **Configure Git**: Interactive prompts for your Git credentials

The goal: **Go from fresh macOS to fully productive DevOps environment in ~30 minutes** (plus download time for apps).

## What's Included

### Tools & Stack
- **Cloud & DevOps**: Terraform, Azure CLI, Google Cloud SDK, AWS CLI, kubectl, k9s, minikube, helm
- **Containers**: Docker (via Colima), docker-compose
- **Languages**: Python (pyenv, virtualenvwrapper), Node.js (nvm), Go
- **Editors**: Neovim, VS Code, Zed
- **Terminal**: iTerm2, Ghostty, WezTerm with Powerlevel10k theme
- **Version Control**: Git, LazyGit, gh, glab
- **Security**: Lulu, Caido
- **Productivity**: Raycast, Rectangle, 1Password, Arc, Brave, Karabiner-Elements
- **AI Tools**: Claude, Ollama, Aider, Gemini CLI

### Configuration Files
- `.zshrc` - Zsh configuration with Oh My Zsh
- `.p10k.zsh` - Powerlevel10k theme configuration
- `aliases.zsh` - Custom aliases for DevOps workflows
- `path.zsh` - PATH configuration for various tools
- `.gitconfig` - Git configuration (email/name set during installation)
- `.macos` - macOS system preferences and tweaks
- `Brewfile` - Homebrew packages and applications
- `fresh.sh` - Automated installation script
- `bootstrap-projects.sh` - Clones all ~/Projects repositories on a new machine
- `npm-globals.txt` - Global npm packages to install
- `pip-requirements.txt` - Global pip packages to install
- `vscode-extensions.txt` - VS Code extensions to install
- `config/` - Application configurations:
  - `karabiner/` - Karabiner-Elements key remapping (Caps Lock → Hyper key, device-specific mappings)
  - `nvim/` - Neovim editor configuration
  - `zed/` - Zed editor settings
  - `ghostty/` - Ghostty terminal configuration
  - `wezterm/` - WezTerm terminal configuration
  - `iterm2/` - iTerm2 preferences
  - `gh/` - GitHub CLI configuration
  - `glab-cli/` - GitLab CLI configuration
  - `git/` - Additional Git configuration
  - `btop/` - btop system monitor theme
  - `ranger/` - ranger file manager configuration

## Fresh macOS Setup

Follow these steps to set up a brand new Mac from scratch.

### Step 1: Prepare Your New Mac

**On your fresh macOS installation:**

1. **Complete the initial macOS setup** (language, Apple ID, etc.)
2. **Update macOS** to the latest version:
   - Open System Settings → General → Software Update
   - Install all available updates and restart if needed
3. **Open Terminal** (Applications → Utilities → Terminal)

**Time estimate:** 10-15 minutes (depending on update size)

### Step 2: Set Up SSH Keys for GitHub

You need SSH access to clone this repository.

**Option A: If you already have SSH keys backed up**
```zsh
# Copy your existing keys to ~/.ssh/
# Skip to Step 3
```

**Option B: Generate new SSH key**
```zsh
# Generate ED25519 key (recommended)
curl https://raw.githubusercontent.com/sharpz33/dotfiles-2023/HEAD/ssh.sh | sh -s "your-email@example.com"
```

**Then add the key to GitHub:**
```zsh
# Copy public key to clipboard
pbcopy < ~/.ssh/id_ed25519.pub

# Now add it to GitHub:
# 1. Open https://github.com/settings/keys
# 2. Click "New SSH key"
# 3. Paste the key (Cmd+V) and save
```

**Verify SSH works:**
```zsh
ssh -T git@github.com
# Expected output: "Hi USERNAME! You've successfully authenticated..."
```

**Time estimate:** 3-5 minutes

### Step 3: Clone This Repository

```zsh
# Clone to ~/.dotfiles
git clone git@github.com:sharpz33/dotfiles-2023.git ~/.dotfiles

# Navigate to the directory
cd ~/.dotfiles
```

**Time estimate:** 30 seconds

### Step 4: Run the Automated Setup

```zsh
./fresh.sh
```

**What will happen:**

1. **You'll be prompted for information:**
   ```
   Enter computer name (default: mba): [type your Mac name or press Enter]
   Enter your Git name (default: e-uzoi): [type your name or press Enter]
   Enter your Git email (default: e-uzoi@gft.com): [type your email or press Enter]
   ```

2. **Oh My Zsh installation** (if not present):
   - May ask to change your default shell to Zsh → Answer **yes**

3. **Homebrew installation** (if not present):
   - Auto-detects Intel vs Apple Silicon
   - May prompt for your Mac password → Enter it

4. **Package installation via Brewfile:**
   - Installs 100+ applications and tools
   - This is the longest step — **expect 15-30 minutes**

5. **Oh My Zsh plugins** (git clone):
   - `zsh-syntax-highlighting`, `zsh-autosuggestions`, `zsh-completions`
   - Cloned to `~/.dotfiles/plugins/`

6. **Node.js via nvm** — latest LTS, set as default

7. **npm global packages** — from `npm-globals.txt`

8. **Python via pyenv** — latest 3.x, set as global

9. **pip global packages** — from `pip-requirements.txt`

10. **VS Code extensions** — from `vscode-extensions.txt` (~60 extensions)

11. **Git configuration** — sets your git user name and email globally

12. **macOS preferences** — applies system tweaks from `.macos` (Finder, Dock, keyboard, etc.)

13. **SSH key setup** — generates ED25519 key if missing, shows public key, **pauses** so you can add it to GitHub and GFT GitLab

14. **~/Projects clone** (optional) — asks if you want to clone all repos via `bootstrap-projects.sh`

**Important notes:**
- ☕ **Grab coffee** — Brewfile + VS Code extensions take the most time
- 🔒 You may be asked for your **Mac password** multiple times
- 🚫 Don't close Terminal during installation

**Time estimate:** 30-60 minutes (depends on internet speed)

### Step 5: Restart Your Mac

```zsh
# Restart to apply all system changes
sudo shutdown -r now
```

After restart, open Terminal and you should see the **Powerlevel10k prompt** with your new configuration!

### Step 5: Restart Your Mac

```zsh
sudo shutdown -r now
```

### Step 6: Post-Installation Checklist

Po restarcie przejdź przez poniższą listę. Część kroków jest wymagana, część opcjonalna.

---

#### Terminal i prompt

**Ustaw Nerd Font w terminalu** (wymagane dla ikon Powerlevel10k):
- **iTerm2**: Preferences → Profiles → Text → Font → wybierz `GoMono Nerd Font` lub `MesloLGS NF`
- **Ghostty**: już skonfigurowany przez symlink `~/.config/ghostty/`
- **WezTerm**: już skonfigurowany przez symlink `~/.config/wezterm/`

**Powerlevel10k** — powinien załadować się automatycznie z `~/.p10k.zsh`. Jeśli prompt wygląda niepoprawnie:
```zsh
p10k configure
```

---

#### Karabiner-Elements (Caps Lock → Hyper key)

Konfiguracja jest już zasymlinkowna (`~/.config/karabiner/`), ale macOS wymaga ręcznego zatwierdzenia uprawnień:

1. **System Settings → Privacy & Security → Accessibility** → włącz `Karabiner-Elements`
2. **System Settings → Privacy & Security → Input Monitoring** → włącz `karabiner_grabber` i `karabiner_observer`
3. Jeśli Karabiner nie działa po zatwierdzeniu — uruchom ponownie usługę:
   ```zsh
   sudo launchctl kickstart -k system/org.pqrs.karabiner.karabiner_grabber
   ```
4. Zweryfikuj: Caps Lock powinien działać jako Hyper (cmd+ctrl+opt+shift)

---

#### Zed

Ustawienia są zasymlinkowne przez `~/.config/zed/`. Przy pierwszym uruchomieniu:

1. Otwórz Zed → zaloguj się na konto (opcjonalne, dla sync ustawień)
2. Sprawdź czy extensions są zainstalowane: `Cmd+Shift+X`
3. Jeśli brakuje rozszerzeń — doinstaluj ręcznie z marketplace Zed

---

#### 1Password

1. Zaloguj się do 1Password
2. Włącz SSH agent: **Settings → Developer → Use SSH Agent**
3. Dodaj do `~/.ssh/config`:
   ```
   Host *
     IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
   ```

---

#### Docker / Colima

Colima (Docker bez Docker Desktop) wymaga ręcznego uruchomienia przy pierwszym użyciu:
```zsh
colima start
docker ps  # weryfikacja
```

Aby Colima startował automatycznie przy logowaniu:
```zsh
brew services start colima
```

---

#### Weryfikacja instalacji

```zsh
terraform --version
kubectl version --client
python3 --version
node --version
docker --version
gh auth status
az --version
```

---

## What Gets Installed

The `fresh.sh` script performs these actions automatically:

1. ✅ **Installs Oh My Zsh** with Powerlevel10k theme
2. ✅ **Installs Homebrew** (Intel or Apple Silicon)
3. ✅ **Symlinks `.zshrc`** to your home directory
4. ✅ **Symlinks all application configs** from `config/` directory
5. ✅ **Installs 100+ packages** from Brewfile (CLIs, apps, fonts)
6. ✅ **Installs Oh My Zsh plugins** via git clone → `~/.dotfiles/plugins/`
7. ✅ **Installs Node.js** (latest LTS via nvm) + npm global packages
8. ✅ **Installs Python** (latest 3.x via pyenv) + pip global packages
9. ✅ **Installs VS Code extensions** (~60 extensions)
10. ✅ **Configures Git** with your credentials
11. ✅ **Applies macOS tweaks** (keyboard speed, Finder, Dock, etc.)
12. ✅ **Sets up SSH key** + pauses to let you add it to GitHub/GitLab
13. ✅ **Clones ~/Projects** repositories (optional, via `bootstrap-projects.sh`)

**Result:** Fully configured DevOps/Cloud engineering environment ready to use!

## Customization

### Adding Aliases

Edit `aliases.zsh` to add your own aliases:
```zsh
alias myalias="command"
```

Aliases are automatically loaded via `ZSH_CUSTOM=$DOTFILES`.

### Modifying PATH

Edit `path.zsh` to add directories to your PATH:
```zsh
export PATH="/my/custom/path:$PATH"
```

### Installing Apps

Add packages to `Brewfile`:
```ruby
brew 'package-name'        # CLI tools
cask 'application-name'     # GUI applications
mas 'App Name', id: 123456  # Mac App Store apps
```

Then run:
```zsh
brew bundle --file ~/.dotfiles/Brewfile
```

### macOS Preferences

Edit `.macos` to customize system settings. Current configuration includes:
- Blazingly fast keyboard repeat rate
- Disabled auto-corrections (better for coding)
- Hidden menu bar and desktop icons
- Auto-hiding Dock
- Enhanced Finder settings
- Security preferences

To check your current settings vs `.macos`:
```zsh
cd ~/.dotfiles && ./check-settings.sh
```

## Maintenance

### Updating Brewfile

To capture currently installed packages:
```zsh
cd ~/.dotfiles
brew bundle dump --force
```

### Syncing Changes

After modifying dotfiles:
```zsh
cd ~/.dotfiles
git add .
git commit -m "Update dotfiles"
git push
```

## Architecture Support

The installation script automatically detects your Mac's architecture:
- **Apple Silicon (M1/M2/M3)**: Uses `/opt/homebrew`
- **Intel**: Uses `/usr/local`

## Troubleshooting

### Homebrew Issues

If Homebrew commands aren't found after installation:
```zsh
eval "$(/opt/homebrew/bin/brew shellenv)"  # Apple Silicon
# or
eval "$(/usr/local/bin/brew shellenv)"      # Intel
```

### Symlink Issues

If `.zshrc` isn't loading properly:
```zsh
ls -la ~/.zshrc  # Check symlink
cd ~/.dotfiles && ln -sf $(pwd)/.zshrc ~/.zshrc  # Recreate
```

### Plugin Errors

If Oh My Zsh plugins fail to load:
```zsh
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
```

## Thanks

Inspired by:
- [Dries Vints' dotfiles](https://github.com/driesvints/dotfiles) - Original template
- [Mathias Bynens' dotfiles](https://github.com/mathiasbynens/dotfiles) - macOS defaults
- [GitHub does dotfiles](https://dotfiles.github.io/) - Community inspiration

## License

This is free and unencumbered software released into the public domain. See LICENSE.md for details.
