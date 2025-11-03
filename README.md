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
- **Productivity**: Raycast, Rectangle, 1Password, Arc, Brave
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
   - Will create `~/.oh-my-zsh` directory

3. **Homebrew installation** (if not present):
   - Downloads and installs Homebrew (auto-detects Intel vs Apple Silicon)
   - May prompt for your Mac password → Enter it
   - Takes 2-5 minutes

4. **Package installation via Brewfile:**
   - Installs 100+ applications and tools
   - This is the longest step - **expect 15-30 minutes**
   - You'll see progress as each package installs
   - Some apps (like Docker, VS Code) are large downloads

5. **Git configuration:**
   - Sets your git user name and email globally

6. **macOS preferences:**
   - Applies system tweaks from `.macos`
   - May prompt for password to change system settings
   - Finder and Dock will restart automatically

**Important notes:**
- ☕ **Grab coffee** - the Brewfile installation takes time
- 🔒 You may be asked for your **Mac password** multiple times
- 🚫 Don't close Terminal during installation
- 📱 Some apps may ask for permissions (camera, microphone, etc.) - you can configure these later

**Time estimate:** 20-45 minutes (depends on internet speed)

### Step 5: Restart Your Mac

```zsh
# Restart to apply all system changes
sudo shutdown -r now
```

After restart, open Terminal and you should see the **Powerlevel10k prompt** with your new configuration!

### Step 6: Post-Installation (Optional)

**Configure app-specific settings:**
- Log into 1Password, browsers, cloud services
- Configure Raycast keyboard shortcuts
- Set up IDE preferences (VS Code, Neovim)
- Configure terminal themes if needed (`p10k configure`)

**Verify installation:**
```zsh
# Check key tools are installed
terraform --version
kubectl version --client
python --version
node --version
docker --version
```

---

## What Gets Installed

The `fresh.sh` script performs these actions automatically:

1. ✅ **Installs Oh My Zsh** with Powerlevel10k theme
2. ✅ **Installs Homebrew** (Intel or Apple Silicon)
3. ✅ **Symlinks `.zshrc`** to your home directory
4. ✅ **Installs 100+ packages** from Brewfile (CLIs, apps, fonts)
5. ✅ **Configures Git** with your credentials
6. ✅ **Applies macOS tweaks** (keyboard speed, Finder, Dock, etc.)

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
