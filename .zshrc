# profiling: odkomentuj poniższe + zprof na końcu pliku
# zmodload zsh/zprof

# nvm lazy loading
zstyle ':omz:plugins:nvm' lazy yes

# Skip global compinit - oh-my-zsh will handle it
skip_global_compinit=1

# Optimize compinit by checking cache only once a day
zstyle ':omz:lib:compinit' cache-path "${ZDOTDIR:-$HOME}/.zcompdump"
zstyle ':omz:lib:compinit' check-frequency 1


# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH
# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=( git zsh-syntax-highlighting zsh-autosuggestions azcli virtualenv zoxide nvm kubectl )

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
# alias brew='env PATH="${PATH//${PYENV_ROOT:-$HOME/.pyenv}\/shims:/}" brew'
  brew() {
    local pyenv_root="${PYENV_ROOT:-$HOME/.pyenv}"
    local clean_path="${PATH//$pyenv_root\/shims:/}"
    env PATH="$clean_path" command brew "$@"
  }
alias c='claude'
alias k='kubectl'
alias tf='terraform'
alias v='nvim'
alias vi='nvim'
alias vim='nvim'
alias lgit='lazygit'
alias maps='telnet mapscii.me'
alias ytd='yt-dlp -f "bestvideo+bestaudio/best" --merge-output-format mp4 -o "%(uploader)s %(upload_date>%Y-%m-%d)s %(title)s [%(id)s].%(ext)s"'
alias glo='git log --oneline --decorate --graph --all -30'  # override oh-my-zsh git plugin
alias mc='ranger'
alias cpwd='pwd | pbcopy && echo "📋 $(pbpaste)"'
alias pwdc='cpwd'
alias aibl='cd ~/Projects/assistants/aibl && claude'
alias aiul='cd ~/Projects/assistants/aiul && claude'
alias gws-sharp='GOOGLE_WORKSPACE_CLI_CONFIG_DIR=~/.config/gws-sharpz33 gws'

# Memory watcher: `mem` live (co 10s), `mem1` snapshot
mem1() {
  echo "=== $(date '+%Y-%m-%d %H:%M:%S') ==="
  echo "--- MEM ---"
  memory_pressure | tail -5
  echo "--- GHOSTTY + CLAUDE (PID / RSS MB / CPU%) ---"
  ps -Axo pid,rss,pcpu,comm | awk 'tolower($0) ~ /ghostty|claude/ && !/awk/ {printf "%-7s %7.1f MB  %5s%%  %s\n",$1,$2/1024,$3,$4}'
}
mem() {
  while true; do clear; mem1; sleep "${1:-10}"; done
}

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# pyenv configuration - lazy loaded for faster shell startup
# export PYENV_VIRTUALENVWRAPPER_PREFER_PYVENV="true"
# export WORKON_HOME=$HOME/.virtualenvs

# Lazy load pyenv
pyenv() {
  unfunction pyenv
  eval "$(command pyenv init -)"
  eval "$(command pyenv init --path)"
# command pyenv virtualenvwrapper_lazy
  pyenv "$@"
}

# Lazy load python (calls pyenv if needed)
python() {
  unfunction python
  eval "$(command pyenv init -)"
  eval "$(command pyenv init --path)"
#  command pyenv virtualenvwrapper_lazy
  python "$@"
}

# Lazy load pip (calls pyenv if needed)
pip() {
  unfunction pip
  eval "$(command pyenv init -)"
  eval "$(command pyenv init --path)"
#  command pyenv virtualenvwrapper_lazy
  pip "$@"
}


## Auto-activation
# python_venv() {
#     MYVENV=./venv
#     [[ -d $MYVENV ]] && source $MYVENV/bin/activate > /dev/null 2>&1
#     [[ ! -d $MYVENV ]] && deactivate > /dev/null 2>&1
# }

# autoload -U add-zsh-hook
# add-zsh-hook chpwd python_venv
# python_venv
#####


# NVM is now loaded via oh-my-zsh plugin with lazy loading (see line 5 and plugins list)
# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
# Lazy load gcloud completions (saves ~50-100ms)
# The next line enables shell command completion for gcloud.
# if [ -f '/opt/homebrew/share/google-cloud-sdk/completion.zsh.inc' ]; then . '/opt/homebrew/share/google-cloud-sdk/completion.zsh.inc'; fi
gcloud() {
  if [ -f '/opt/homebrew/share/google-cloud-sdk/completion.zsh.inc' ]; then
    source '/opt/homebrew/share/google-cloud-sdk/completion.zsh.inc'
  fi
  unfunction gcloud
  gcloud "$@"
}

# zprof

# Added by Antigravity
export PATH="/Users/e-uzoi/.antigravity/antigravity/bin:$PATH"

# secrets
[ -f ~/.secrets ] && source ~/.secrets

# Claude Code version aliases
alias c98="$HOME/.local/share/claude/versions/2.1.98"
alias c114="$HOME/.local/share/claude/versions/2.1.114"
alias c-old="$HOME/.local/share/claude/versions/2.1.98"

# for BAS Pekao project:
export JAVA_HOME=/opt/homebrew/Cellar/openjdk@17/17.0.18/libexec/openjdk.jdk/Contents/Home

# delta as pager for gh CLI (git already uses delta via core.pager)
export GH_PAGER='delta'

# 1Password SSH agent (klucze trzymane w 1P, biometria zamiast passphrase)
if [ -S "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock" ]; then
  export SSH_AUTH_SOCK="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
fi
