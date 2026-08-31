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
ssh_source="$PWD/ssh/config"
if [ -L "$ssh_config" ]; then
  current="$(readlink "$ssh_config")"
  if [ "$current" != "$ssh_source" ]; then
    echo "WARNING: $ssh_config is a symlink to $current, not $ssh_source."
  fi
elif [ -e "$ssh_config" ]; then
  backup="${ssh_config}.pre-dotfiles"
  echo "Backing up $ssh_config to $backup"
  mv "$ssh_config" "$backup"
  echo "Creating $ssh_config"
  ln -s "$ssh_source" "$ssh_config"
else
  echo "Creating $ssh_config"
  ln -s "$ssh_source" "$ssh_config"
fi

install_omarchy_copy() {
  omarchy_source="$1"
  omarchy_destination="$2"

  if [ ! -e "$omarchy_destination" ] && [ ! -L "$omarchy_destination" ]; then
    echo "Creating $omarchy_destination"
    cp "$omarchy_source" "$omarchy_destination"
  elif [ -L "$omarchy_destination" ] || [ ! -f "$omarchy_destination" ] || ! cmp -s "$omarchy_source" "$omarchy_destination"; then
    omarchy_backup="$omarchy_destination.backup.$(date +%Y%m%d-%H%M%S)"
    omarchy_backup_suffix=1
    while [ -e "$omarchy_backup" ] || [ -L "$omarchy_backup" ]; do
      omarchy_backup="$omarchy_destination.backup.$(date +%Y%m%d-%H%M%S).$omarchy_backup_suffix"
      omarchy_backup_suffix=$((omarchy_backup_suffix + 1))
    done
    echo "Backing up $omarchy_destination to $omarchy_backup"
    mv "$omarchy_destination" "$omarchy_backup"
    cp "$omarchy_source" "$omarchy_destination"
  fi
}

install_omarchy_xcompose() {
  omarchy_xcompose_source="$PWD/omarchy/XCompose"
  omarchy_xcompose="$HOME/.XCompose"
  omarchy_xcompose_local="$HOME/.XCompose.local"

  if [ -e "$omarchy_xcompose_local" ] || [ -L "$omarchy_xcompose_local" ]; then
    :
  elif [ ! -e "$omarchy_xcompose" ] && [ ! -L "$omarchy_xcompose" ]; then
    echo "Creating $omarchy_xcompose_local"
    (umask 077 && : > "$omarchy_xcompose_local")
    chmod 600 "$omarchy_xcompose_local"
  elif [ -f "$omarchy_xcompose" ] && cmp -s "$omarchy_xcompose_source" "$omarchy_xcompose"; then
    echo "Creating $omarchy_xcompose_local"
    (umask 077 && : > "$omarchy_xcompose_local")
    chmod 600 "$omarchy_xcompose_local"
  else
    echo "WARNING: $omarchy_xcompose_local is absent while $omarchy_xcompose differs from the tracked wrapper; leaving $omarchy_xcompose untouched." >&2
    return 0
  fi

  install_omarchy_copy "$omarchy_xcompose_source" "$omarchy_xcompose"
}

if [ -f /etc/os-release ] && grep -q '^ID=omarchy$' /etc/os-release; then
  mkdir -p "$HOME/.config/hypr" "$HOME/.config/omarchy"
  install_omarchy_copy "$PWD/omarchy/hypr/input.lua" "$HOME/.config/hypr/input.lua"
  install_omarchy_copy "$PWD/omarchy/shell.json" "$HOME/.config/omarchy/shell.json"
  install_omarchy_xcompose
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

if command -v herdr >/dev/null 2>&1; then
  for pi_agent_dir in "$HOME/.pi/agent" "$HOME/.arc-pi"; do
    if [ ! -d "$pi_agent_dir" ]; then
      continue
    fi
    if PI_CODING_AGENT_DIR="$pi_agent_dir" herdr integration install pi; then
      :
    else
      echo "WARNING: Herdr Pi integration install failed for $pi_agent_dir." >&2
    fi
  done
fi

PLUG_PATH="${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/autoload/plug.vim"

if [ ! -f "$PLUG_PATH" ]; then
  echo "Installing vim-plug to $PLUG_PATH"
  curl -fLo "$PLUG_PATH" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

"$NVIM_BIN" --headless -u ~/.vimrc.bundles "+PlugInstall --sync" +qa
"$NVIM_BIN" --headless -u ~/.vimrc.bundles "+lua require('nvim-treesitter').install({'javascript','jsdoc','typescript','tsx'}):wait(300000)" +qa
