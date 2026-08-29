#!/bin/sh

set -eu

NVIM_BIN="${NVIM_BIN:-nvim}"
REQUIRED_NVIM_VERSION="0.12.0"

version_ge() {
  awk -v have="$1" -v need="$2" '
    BEGIN {
      split(have, h, ".")
      split(need, n, ".")
      for (i = 1; i <= 3; i++) {
        hv = h[i] + 0
        nv = n[i] + 0
        if (hv > nv) exit 0
        if (hv < nv) exit 1
      }
      exit 0
    }
  '
}

require_supported_nvim() {
  if ! command -v "$NVIM_BIN" >/dev/null 2>&1; then
    cat >&2 <<'EOF'
ERROR: Neovim 0.12+ is required before installing these dotfiles plugins.

Install or upgrade Neovim first, then rerun ./install.sh.
On macOS with Homebrew:
  brew install neovim tree-sitter-cli

The Tree-sitter CLI command must be available as `tree-sitter` and report 0.26.1+.
EOF
    exit 1
  fi

  nvim_version="$("$NVIM_BIN" --version | awk 'NR == 1 { sub(/^NVIM v/, "", $2); sub(/-.*/, "", $2); print $2 }')"
  if [ -z "$nvim_version" ] || ! version_ge "$nvim_version" "$REQUIRED_NVIM_VERSION"; then
    cat >&2 <<EOF
ERROR: Neovim $REQUIRED_NVIM_VERSION or newer is required; found ${nvim_version:-unknown}.

Upgrade Neovim first, then rerun ./install.sh.
On macOS with Homebrew:
  brew update
  brew upgrade neovim
  brew install tree-sitter-cli

The Tree-sitter CLI command must be available as \`tree-sitter\` and report 0.26.1+.
EOF
    exit 1
  fi
}

require_supported_nvim

skip_top_level() {
  case "$1" in
    install.sh|README.md|docs|herdr|omarchy|ssh) return 0 ;;
    *) return 1 ;;
  esac
}

for name in *; do
  target="$HOME/.$name"
  if skip_top_level "$name"; then
    continue
  fi
  if [ -e "$target" ]; then
    if [ ! -L "$target" ]; then
      echo "WARNING: $target exists but is not a symlink."
    fi
  else
    echo "Creating $target"
    ln -s "$PWD/$name" "$target"
  fi
done

mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
ssh_config="$HOME/.ssh/config"
if [ -e "$ssh_config" ] || [ -L "$ssh_config" ]; then
  if [ ! -L "$ssh_config" ]; then
    echo "WARNING: $ssh_config exists but is not a symlink."
  fi
else
  echo "Creating $ssh_config"
  ln -s "$PWD/ssh/config" "$ssh_config"
fi

if [ -f /etc/os-release ] && grep -q '^ID=omarchy$' /etc/os-release; then
  mkdir -p "$HOME/.config/hypr"
  hypr_input="$HOME/.config/hypr/input.lua"
  if [ -e "$hypr_input" ] || [ -L "$hypr_input" ]; then
    if [ ! -L "$hypr_input" ]; then
      echo "WARNING: $hypr_input exists but is not a symlink."
    fi
  else
    echo "Creating $hypr_input"
    ln -s "$PWD/omarchy/hypr/input.lua" "$hypr_input"
  fi
fi

mkdir -p "$HOME/.config/nvim"
if [ ! -f "$HOME/.config/nvim/init.vim" ]; then
  printf 'source ~/.vimrc\n' > "$HOME/.config/nvim/init.vim"
fi

mkdir -p "$HOME/.config/herdr"
herdr_config="$HOME/.config/herdr/config.toml"
if [ -e "$herdr_config" ] || [ -L "$herdr_config" ]; then
  if [ ! -L "$herdr_config" ]; then
    echo "WARNING: $herdr_config exists but is not a symlink."
  fi
else
  echo "Creating $herdr_config"
  ln -s "$PWD/herdr/config.toml" "$herdr_config"
fi

PLUG_PATH="${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/autoload/plug.vim"

if [ ! -f "$PLUG_PATH" ]; then
  echo "Installing vim-plug to $PLUG_PATH"
  curl -fLo "$PLUG_PATH" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

"$NVIM_BIN" --headless -u ~/.vimrc.bundles "+PlugInstall --sync" +qa
"$NVIM_BIN" --headless -u ~/.vimrc.bundles "+lua require('nvim-treesitter').install({'javascript','jsdoc','typescript','tsx'}):wait(300000)" +qa
