#!/usr/bin/env bash
# os-detect.sh — cross-platform helpers (Mac BSD vs Linux GNU)
# Source from scripts: . "$HOME/.dotfiles/lib/os-detect.sh"

is_macos()  { [ "$(uname -s)" = "Darwin" ]; }
is_linux()  { [ "$(uname -s)" = "Linux" ]; }
is_arch()   { [ -f /etc/arch-release ]; }
is_omarchy(){ [ -f /etc/os-release ] && grep -qi "omarchy\|arch" /etc/os-release; }

# sed -i: BSD wymaga '', GNU nie
sed_i() {
  if is_macos; then sed -i '' "$@"; else sed -i "$@"; fi
}

# stat rozmiaru pliku w bajtach
stat_size() {
  if is_macos; then stat -f %z "$1"; else stat -c %s "$1"; fi
}

# stat mtime pliku jako epoch
stat_mtime() {
  if is_macos; then stat -f %m "$1"; else stat -c %Y "$1"; fi
}

# date ISO8601 z epoch
date_from_epoch() {
  if is_macos; then date -r "$1" -u +"%Y-%m-%dT%H:%M:%SZ"
  else date -d "@$1" -u +"%Y-%m-%dT%H:%M:%SZ"; fi
}

# realpath (macOS bez coreutils nie ma)
realpath_x() {
  if command -v realpath >/dev/null 2>&1; then realpath "$1"
  elif command -v greadlink >/dev/null 2>&1; then greadlink -f "$1"
  else python3 -c "import os,sys; print(os.path.realpath(sys.argv[1]))" "$1"
  fi
}

# pakiet manager
pkg_install_cmd() {
  if is_macos; then echo "brew install"
  elif is_arch; then echo "sudo pacman -S --needed --noconfirm"
  else echo "echo 'unknown OS, install manually:'"; fi
}

# liczba CPU
cpu_count() {
  if is_macos; then sysctl -n hw.ncpu
  else nproc; fi
}
