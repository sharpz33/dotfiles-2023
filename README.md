# Dotfiles

My personal macOS dotfiles for DevOps/Cloud Engineering workflow. Automates the setup of a new Mac with all tools, configurations, and preferences.

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

### Prerequisites

Before starting, ensure you have:
1. Updated macOS to the latest version
2. Backed up your existing data

### Backup Checklist

- [ ] Commit and push all git repositories
- [ ] Save documents from non-iCloud directories
- [ ] Export important data from databases
- [ ] Backup browser bookmarks and extensions
- [ ] Note down any custom system preferences

### Installation

1. **Generate SSH key** (if needed):

   ```zsh
   curl https://raw.githubusercontent.com/YOUR_USERNAME/dotfiles/HEAD/ssh.sh | sh -s "your-email@example.com"
   ```

   Then add the SSH key to GitHub/GitLab:
   ```zsh
   pbcopy < ~/.ssh/id_ed25519.pub
   ```

2. **Clone this repository**:

   ```zsh
   git clone --recursive git@github.com:YOUR_USERNAME/dotfiles.git ~/.dotfiles
   ```

3. **Run the installation**:

   ```zsh
   cd ~/.dotfiles && ./fresh.sh
   ```

   The script will prompt you for:
   - Computer name (default: mba)
   - Git user name (default: e-uzoi)
   - Git user email (default: e-uzoi@gft.com)

4. **Restart your Mac** to apply all changes

Your Mac is now configured!

> **Note:** The script assumes you're installing to `~/.dotfiles`. If you use a different location, update the `DOTFILES` variable in `.zshrc`.

### What `fresh.sh` Does

1. Installs Oh My Zsh (if not present)
2. Installs Homebrew (if not present) - auto-detects Intel vs Apple Silicon
3. Symlinks `.zshrc` from dotfiles to home directory
4. Installs all packages from `Brewfile` via Homebrew Bundle
5. Configures Git with your name and email
6. Applies macOS system preferences from `.macos`

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
