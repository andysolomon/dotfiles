#!/bin/sh

for name in *; do
  target="$HOME/.$name"
  if [ -e "$target" ]; then
    if [ ! -L "$target" ]; then
      echo "WARNING: $target exists but is not a symlink."
    fi
  else
    if [ "$name" != 'install.sh' ] && [ "$name" != 'README.md' ]; then
      echo "Creating $target"
      ln -s "$PWD/$name" "$target"
    fi
  fi
done

mkdir -p "$HOME/.config/nvim"
if [ ! -f "$HOME/.config/nvim/init.vim" ]; then
  printf 'source ~/.vimrc\n' > "$HOME/.config/nvim/init.vim"
fi

PLUG_PATH="${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/autoload/plug.vim"

if [ ! -f "$PLUG_PATH" ]; then
  echo "Installing vim-plug to $PLUG_PATH"
  curl -fLo "$PLUG_PATH" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

if command -v nvim >/dev/null 2>&1; then
  nvim --headless -u ~/.vimrc.bundles "+PlugInstall --sync" +qa
else
  vim -u ~/.vimrc.bundles "+PlugInstall --sync" +qa
fi
