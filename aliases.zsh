# Shortcuts
alias copyssh="pbcopy < $HOME/.ssh/id_ed25519.pub"
alias reloadshell="source $HOME/.zshrc"
alias reloaddns="dscacheutil -flushcache && sudo killall -HUP mDNSResponder"
alias shrug="echo '¯\_(ツ)_/¯' | pbcopy"
alias c="clear"

# ls with coreutils (works on both Intel and Apple Silicon)
if command -v brew &> /dev/null; then
  alias ll="$(brew --prefix coreutils)/libexec/gnubin/ls -AhlFo --color --group-directories-first"
else
  alias ll="ls -AhlFG"
fi

# Directories
alias dotfiles="cd $DOTFILES"
alias library="cd $HOME/Library"

# DevOps & Cloud
alias tf="terraform"
alias tfa="terraform apply"
alias tfp="terraform plan"
alias tfi="terraform init"
alias k="kubectl"
alias kx="kubectx"
alias kns="kubens"
alias docker-start="colima start"
alias docker-stop="colima stop"

# Tools
alias brew='env PATH="${PATH//$(pyenv root)\/shims:/}" brew'
alias vi='nvim'
alias vim='nvim'
alias lgit='lazygit'
alias maps='telnet mapscii.me'
alias ytd='yt-dlp -f "bestvideo+bestaudio/best" --merge-output-format mp4 -o "%(uploader)s %(upload_date>%Y-%m-%d)s %(title)s [%(id)s].%(ext)s"'

# Git
alias gst="git status"
alias gb="git branch"
alias gc="git checkout"
alias gl="git log --oneline --decorate --color"
alias amend="git add . && git commit --amend --no-edit"
alias commit="git add . && git commit -m"
alias diff="git diff"
alias force="git push --force"
alias nuke="git clean -df && git reset --hard"
alias pop="git stash pop"
alias pull="git pull"
alias push="git push"
alias resolve="git add . && git commit --no-edit"
alias stash="git stash -u"
alias unstage="git restore --staged ."
alias wip="commit wip"
