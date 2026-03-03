#!/usr/bin/env bash
# ssh.sh — generuje SSH key i konfiguruje ssh-agent
# Użycie: ./ssh.sh your-email@example.com
# Uruchamiaj PRZED fresh.sh (potrzebujesz SSH żeby sklonować dotfiles)

echo "Generating a new SSH key..."

# Generate ED25519 key
# https://docs.github.com/en/authentication/connecting-to-github-with-ssh
ssh-keygen -t ed25519 -C "$1" -f ~/.ssh/id_ed25519

# Start ssh-agent and add key
eval "$(ssh-agent -s)"

# Configure ssh-agent (UseKeychain for macOS Keychain)
mkdir -p ~/.ssh
cat >> ~/.ssh/config <<EOF

Host *
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
EOF

# Add key to agent (--apple-use-keychain replaces deprecated -K on macOS 12+)
ssh-add --apple-use-keychain ~/.ssh/id_ed25519

echo ""
echo "Klucz publiczny (skopiuj i dodaj do GitHub/GitLab):"
echo ""
cat ~/.ssh/id_ed25519.pub
echo ""
echo "Lub uruchom: pbcopy < ~/.ssh/id_ed25519.pub"
echo ""
echo "GitHub:      https://github.com/settings/keys"
echo "GFT GitLab:  https://git.gft.com/-/profile/keys"
