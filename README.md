# Dotfiles

Personal shell, editor, and tmux configuration with a bootstrap installer.

## Contents

- [What this repo manages](#what-this-repo-manages)
- [Requirements](#requirements)
- [Install](#install)
- [How install works](#how-install-works)
- [Neovim and Vim](#neovim-and-vim)
- [Plugin management](#plugin-management)
- [Key mappings and usage](#key-mappings-and-usage)
- [tmux](#tmux)
- [Local machine overrides](#local-machine-overrides)
- [Troubleshooting](#troubleshooting)
- [Optional macOS bootstrap](#optional-macos-bootstrap)

## What this repo manages

- `zshrc` and `zsh/`: shell options, prompt, completions, and shell helpers.
- `aliases`: command aliases for git/workflow shortcuts.
- `vimrc*` and `vim/`: Vim + Neovim settings and plugin config.
- `tmux.conf` and `.tmux/`: tmux behavior and TPM plugin setup.
- `bin/`: utility scripts (`git-churn`, `replace`, `tat`, etc).

## Requirements

- macOS or Linux
- `zsh`
- `git`
- `curl`
- `vim` or `nvim`

Set login shell to zsh if needed:

```sh
chsh -s /bin/zsh
```

## Install

```sh
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles
./install.sh
```

## How install works

`install.sh` performs these steps:

1. Symlinks each top-level repo item to `$HOME` as a dotfile.
1. Skips only `install.sh` and `README.md`.
1. Warns (does not overwrite) if a destination exists and is not a symlink.
1. Creates `~/.config/nvim/init.vim` (if missing) with `source ~/.vimrc`.
1. Installs `vim-plug` for Neovim into:
   - `${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/autoload/plug.vim`
1. Runs plugin install:
   - `nvim --headless -u ~/.vimrc.bundles "+PlugInstall --sync" +qa`
   - falls back to `vim` if `nvim` is unavailable.

## Neovim and Vim

This repo uses a classic Vim-style config layout:

- `vimrc` is the main entrypoint and sources:
  - `~/.vimrc.bundles`
  - `~/.vimrc.global`
  - `~/.vimrc.plugins`
  - `~/.vimrc.macros`
  - `~/.vimrc.local`

Neovim compatibility is handled via `~/.config/nvim/init.vim` sourcing `~/.vimrc`.

### Leader key

Leader is comma:

```vim
let mapleader = ","
```

## Plugin management

Plugins are managed with `vim-plug` in [`vimrc.bundles`](vimrc.bundles) via `Plug` entries.

Install/update plugins:

```sh
nvim --headless -u ~/.vimrc.bundles "+PlugInstall --sync" +qa
```

Clean removed plugins:

```sh
nvim --headless -u ~/.vimrc.bundles "+PlugClean!" +qa
```

### Notable enabled plugins

- `scrooloose/nerdtree` (file explorer)
- `ryanoasis/vim-devicons` (icons)
- `scrooloose/nerdcommenter` (comment toggling)
- `junegunn/limelight.vim` (focus mode)
- `airblade/vim-gitgutter`
- `itchyny/lightline.vim`
- `github/copilot.vim`
- `neovim/nvim-lspconfig`

## Key mappings and usage

### NERDTree

- `Ctrl+t`: toggle NERDTree
- `,n`: reveal current file in tree
- Opens automatically on startup (`autocmd vimenter * NERDTree`)

Bookmarks:

- `NERDTreeShowBookmarks = 1` means bookmarks section is visible.
- Bookmarks are quick named shortcuts to frequently used paths.

### Comment toggle

- `,/` in normal mode: toggle comment on current line
- `,/` in visual mode: toggle comments on selection

Configured using:

```vim
call nerdcommenter#Comment('n', 'toggle')
call nerdcommenter#Comment('x', 'toggle')
```

### Limelight

- `Ctrl+l`: Limelight focus mode mapping
- `Ctrl+l l`: toggle `:Limelight!!`

### General navigation

- `,,`: switch to last file
- `Ctrl+h/j/k/l`: window navigation
- `<leader>w`: save
- `<leader>x`: save and quit
- `<leader>q`: quit

## tmux

### Prefix

Prefix is `Ctrl+a` (default `Ctrl+b` is unbound).

### Useful behavior

- Vim-like pane navigation with `h/j/k/l`
- Split windows in current pane path
- Mouse toggle:
  - `prefix + m` enables mouse
  - `prefix + M` disables mouse
- Copy mode uses vi keys and copies to macOS clipboard via `reattach-to-user-namespace` when available.

### Plugins

Configured with TPM:

- `tmux-plugins/tpm`
- `tmux-plugins/tmux-sensible`
- `tmux-plugins/tmux-resurrect`
- `tmux-plugins/tmux-battery`

## Local machine overrides

Use local files for machine-specific customization:

- `~/.aliases.local`
- `~/.vimrc.bundles.local`
- `~/.vimrc.local`
- `~/.zshrc.local`

These are sourced conditionally if present.

## Troubleshooting

### Neovim opens but your config/plugins are missing

Check these files exist and are linked:

```sh
ls -la ~/.vimrc ~/.vimrc.bundles ~/.config/nvim/init.vim
```

`~/.config/nvim/init.vim` should contain:

```vim
source ~/.vimrc
```

Then resync plugins:

```sh
nvim --headless -u ~/.vimrc.bundles "+PlugInstall --sync" +qa
```

### NERDTree icons show squares/garbled glyphs

Install a Nerd Font and set it in your terminal profile.

Example on macOS (Homebrew):

```sh
brew install --cask font-jetbrains-mono-nerd-font
```

This repo also has a fallback in [`vimrc.plugins`](vimrc.plugins):

- default: Nerd Font icons enabled
- set `DOTFILES_NERD_FONT=0` to force ASCII-safe arrows and disable devicons

### `:NERDTree` command not found

- Ensure `nerdtree` is enabled in [`vimrc.bundles`](vimrc.bundles).
- Run plugin sync (`PlugInstall`).
- Restart Neovim or run:

```vim
:source ~/.vimrc
```

### tmux keybindings not applying

Ensure config is linked:

```sh
ln -s ~/dotfiles/tmux.conf ~/.tmux.conf
```

Reload tmux config:

```sh
tmux source-file ~/.tmux.conf
```

## Optional macOS bootstrap

`./mac` is a larger machine bootstrap for Homebrew and related tools.

Use it only if you want those opinionated system-level changes.
