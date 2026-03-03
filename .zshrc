# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Dotfiles path
export DOTFILES=$HOME/.dotfiles

# PATH
export PATH=/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
ZSH_CUSTOM=$DOTFILES

plugins=( git zsh-syntax-highlighting zsh-autosuggestions zsh-completions azcli virtualenv zoxide )

source $ZSH/oh-my-zsh.sh

# Language
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Aliases
alias brew='env PATH="${PATH//$(pyenv root)\/shims:/}" brew'
alias tf='terraform'
alias vi='nvim'
alias vim='nvim'
alias lgit='lazygit'
alias maps='telnet mapscii.me'
alias ytd='yt-dlp -f "bestvideo+bestaudio/best" --merge-output-format mp4 -o "%(uploader)s %(upload_date>%Y-%m-%d)s %(title)s [%(id)s].%(ext)s"'
alias glo='git log --oneline --decorate --graph --all -30'

# Powerlevel10k
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv init --path)"
# virtualenvwrapper (tylko jeśli zainstalowany)
export PYENV_VIRTUALENVWRAPPER_PREFER_PYVENV="true"
export WORKON_HOME=$HOME/.virtualenvs
pyenv virtualenvwrapper_lazy 2>/dev/null || true

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# PostgreSQL libpq
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

# Google Cloud SDK
if [ -f '/opt/homebrew/share/google-cloud-sdk/path.zsh.inc' ]; then
  source '/opt/homebrew/share/google-cloud-sdk/path.zsh.inc'
fi
if [ -f '/opt/homebrew/share/google-cloud-sdk/completion.zsh.inc' ]; then
  source '/opt/homebrew/share/google-cloud-sdk/completion.zsh.inc'
fi
