# Load dotfiles binaries
export PATH="$DOTFILES/bin:$PATH"

# pyenv configuration
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"

# PostgreSQL libpq
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

# Use project specific binaries before global ones (if needed)
# export PATH="node_modules/.bin:$PATH"
