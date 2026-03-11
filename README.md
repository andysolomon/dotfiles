# Dotfiles

Personal shell/editor/tmux dotfiles with a bootstrap script and small utility commands.

## Requirements

- macOS or Linux with `zsh`
- `git`
- `vim` or `nvim`

Set your login shell to zsh if needed:

```sh
chsh -s /bin/zsh
```

## Install

Clone the repo and run the installer:

```sh
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles
./install.sh
```

`install.sh` symlinks repo files into `$HOME` as dotfiles (for example `zshrc` -> `~/.zshrc`), and warns if a target exists but is not a symlink.

## What This Config Includes

- `zshrc` and `zsh/`: shell options, prompt, completions, custom functions.
- `aliases`: shell aliases for git, rails, test helpers, and common commands.
- `vimrc*` and `vim/`: Vim/Neovim settings and plugins.
- `tmux.conf` and `.tmux/`: tmux keybindings and TPM plugin config.
- `bin/`: small helper scripts (`git-churn`, `replace`, `tat`).

## Local Overrides

Machine-specific overrides are supported:

- `~/.aliases.local` for personal aliases.
- `~/.vimrc.bundles.local` for machine-specific Vim plugins.
- `~/.zshrc.local` is used by the `mac` bootstrap script for PATH/appends when writable.

## Vim Plugin Setup

The current `vimrc.bundles` uses `vim-plug` (`plug#begin`/`Plug` entries). If plugins are not installed yet, run:

```sh
vim +PlugInstall +qa
```

## Optional macOS Bootstrap

The `mac` script is a larger machine bootstrap for Homebrew + common dev tools:

```sh
./mac
```

Use it only if you want those opinionated system-level changes.
