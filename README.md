# Dotfiles

Personal shell, editor, tmux, and Herdr configuration with a bootstrap installer.

## Contents

- [What this repo manages](#what-this-repo-manages)
- [Requirements](#requirements)
- [Install](#install)
- [How install works](#how-install-works)
- [Pi updates](#pi-updates)
- [Neovim and Vim](#neovim-and-vim)
- [Plugin management](#plugin-management)
- [Key mappings and usage](#key-mappings-and-usage)
- [tmux](#tmux)
- [Herdr](#herdr)
- [Omarchy configuration](#omarchy-configuration)
- [Tailscale machine workflow](#tailscale-machine-workflow)
- [Local machine overrides](#local-machine-overrides)
- [Releases](#releases)
- [Troubleshooting](#troubleshooting)
- [Optional macOS bootstrap](#optional-macos-bootstrap)

## What this repo manages

- `zshrc` and `zsh/`: shell options, prompt, completions, and shell helpers.
- `aliases`: command aliases for git/workflow shortcuts.
- `vimrc*` and `vim/`: Vim + Neovim settings and plugin config.
- `tmux.conf` and `.tmux/`: tmux behavior and TPM plugin setup.
- `bin/`: utility scripts (`git-churn`, `replace`, `tat`, etc).
- `ssh/config`: tracked host aliases; installed as `~/.ssh/config` without managing private keys.
- `docs/`: repository planning and decision records; it is intentionally not linked into `$HOME`.
- `herdr/`: Herdr config; `install.sh` links `herdr/config.toml` to `~/.config/herdr/config.toml` instead of `~/.herdr`.
- `omarchy/`: an explicit allowlist of Omarchy user overrides copied on Omarchy systems:
  - `hypr/input.lua` → `~/.config/hypr/input.lua`
  - `shell.json` → `~/.config/omarchy/shell.json`
  - `XCompose` → `~/.XCompose`, with private rules included from `~/.XCompose.local`

## Requirements

- macOS or Linux
- `zsh`
- `git`
- `curl`
- Neovim 0.12+
- Tree-sitter CLI 0.26.1+ (`tree-sitter --version`), `tar`, and a C compiler
- NVM with an active default Node for global editor tools
- `typescript@5.9.3`, `typescript-language-server`, `prettier`, and `eslint` installed with npm under the active NVM default

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

1. Fails before any home, plugin, or parser mutation unless `nvim` is available and reports 0.12+.
1. Symlinks each top-level repo item to `$HOME` as a dotfile.
1. Skips `install.sh`, `README.md`, the repository-only `docs/` planning directory, `herdr/`, `omarchy/`, and `ssh/` from generic top-level symlinking.
1. Warns (does not overwrite) if a destination exists and is not a symlink.
1. Symlinks `ssh/config` to `~/.ssh/config`. If a real file is already there, it is moved to `~/.ssh/config.pre-dotfiles` first. Private keys remain unmanaged.
1. On Omarchy, copies only the explicit allowlist: `omarchy/hypr/input.lua` to `~/.config/hypr/input.lua`, `omarchy/shell.json` to `~/.config/omarchy/shell.json`, and `omarchy/XCompose` to `~/.XCompose`. Parent directories are created as needed. Identical regular files are skipped; differing files and symlinks are moved to timestamped backups before replacement.
1. For XCompose, preserves any existing `~/.XCompose.local`. If it is absent, an empty mode-600 file is created only when `~/.XCompose` is absent or already equals the tracked wrapper. If an existing `~/.XCompose` differs while the local file is absent, the installer warns and leaves it untouched.
1. Creates `~/.config/nvim/init.vim` (if missing) with `source ~/.vimrc`.
1. Symlinks `herdr/config.toml` to `~/.config/herdr/config.toml` if that path is missing.
1. If `herdr` is available, installs the official Pi integration separately for each existing `~/.pi/agent` and `~/.arc-pi` directory; missing directories are skipped and failures warn without stopping the installer.
1. Installs `vim-plug` for Neovim into:
   - `${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/autoload/plug.vim`
1. Runs plugin install:
   - `nvim --headless -u ~/.vimrc.bundles "+PlugInstall --sync" +qa`
1. Installs the bounded Tree-sitter parser set:
   - `javascript`, `jsdoc`, `typescript`, and `tsx`

`install.sh` does not install or upgrade Homebrew or npm packages.

## Pi updates

Pi is installed and versioned by mise, so its bundled executable cannot update
itself directly. The tracked [`bin/pi`](bin/pi) launcher translates self-update
requests to mise while preserving Pi's normal package and model commands:

```sh
pi update          # update mise-managed Pi
arc-pi update      # same update through the ARC Pi launcher
pi update --models # refresh Pi's model catalogs
```

Both `pi` and `arc-pi` resolve this launcher through `~/.bin` in login zsh shells.

## Neovim and Vim

This repo uses a classic Vim-style config layout:

- `vimrc` is the main entrypoint and sources:
  - `~/.vimrc.bundles`
  - `~/.vimrc.global`
  - `~/.vimrc.plugins`
  - `~/.vimrc.macros`
  - `~/.vimrc.local`

Neovim compatibility is handled via `~/.config/nvim/init.vim` sourcing `~/.vimrc`.

### Neovim-first

This config targets **Neovim 0.12+**. It declares Neovim-only plugins such as
`nvim-lspconfig`, `nvim-treesitter`, `conform.nvim`, and `nvim-lint`, and
`install.sh` bootstraps `vim-plug` only into Neovim's autoload path. Plain `vim`
is not a supported plugin-install fallback.

To avoid that, `vim` and `vi` are aliased to `nvim` (see [`aliases`](aliases)).
If you deliberately want plain Vim behavior, use it without this Neovim plugin stack.

### TypeScript, TSX, JavaScript, and JSX

The TypeScript editor path is external-tool first:

See the [Neovim TypeScript cheatsheet](docs/NVIM_TYPESCRIPT_CHEATSHEET.md) for
the exact mappings, save policy, health checks, and troubleshooting reference.

```sh
brew install neovim tree-sitter-cli
nvm install 24
nvm alias default 24
npm install -g typescript@5.9.3 typescript-language-server prettier eslint
```

Homebrew's CLI formula is `tree-sitter-cli`; the command it installs is
`tree-sitter`. The required command contract is `tree-sitter --version` reporting
0.26.1 or newer.

Run these checks in a login zsh so NVM's default Node is on `PATH`:

```sh
zsh -lic 'nvim --version | head -n1'
zsh -lic 'tree-sitter --version'
zsh -lic 'nvm --version && node --version'
zsh -lic 'command -v typescript-language-server && typescript-language-server --version'
zsh -lic 'tsc --version && prettier --version && eslint --version'
zsh -lic 'nvim --headless -u ~/.vimrc +qa'
zsh -lic 'bin/check-nvim-typescript-support'
```

`ts_ls` launches `typescript-language-server --stdio`. A raw `tsserver` binary is
not an LSP server and is not enough for Neovim semantic support. The global
fallback is pinned to TypeScript 5.9.3 because npm's TypeScript 7 package does not
ship `lib/tsserver.js` and is rejected by `typescript-language-server` 5.3.0.
Project-local TypeScript, Prettier, and ESLint are preferred when present. Global
Prettier and ESLint are explicit fallbacks only; save-time formatting and linting
require project-local tools.

On the supported Macs, use the same login-shell flow:

```sh
ssh mini 'export NO_AUTO_TMUX=1; cd ~/dotfiles && zsh -lic "bin/check-nvim-typescript-support"'
ssh macbook 'export NO_AUTO_TMUX=1; cd ~/dotfiles && zsh -lic "bin/check-nvim-typescript-support"'
```

Do not run the remote command until you intend to verify that machine; these checks
read editor state and may install parsers only through `./install.sh`.

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
- `nvim-treesitter/nvim-treesitter`
- `stevearc/conform.nvim`
- `mfussenegger/nvim-lint`

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
- `tmux-plugins/tmux-resurrect` (save hook records pi/claude/agent session IDs for resume)
- `tmux-plugins/tmux-battery`

### Host colors and SSH auto-attach

Known Tailscale Macs get host-specific tmux status colors:

- `andrews-mac-mini` / `Andrews-Mac-mini`: green
- `qianas-macbook-pro`: blue
- Unknown hosts: yellow

Interactive SSH shells attach to the host's Herdr session via
[`zsh/configs/post/ssh-herdr.zsh`](zsh/configs/post/ssh-herdr.zsh) (`exec herdr`).
If Herdr is not installed, they fall back to a tmux session named `ssh-$HOST`.
Skipped when `NO_AUTO_TMUX=1` or when the shell is already inside Herdr
(`HERDR_ENV=1`). Bypass for one session by setting the variable on the remote shell:

```sh
ssh -t mini 'NO_AUTO_TMUX=1 exec zsh -l'
```

## Herdr

Herdr config is tracked as [`herdr/config.toml`](herdr/config.toml) and installed to
`~/.config/herdr/config.toml`. The top-level `herdr/` directory is not symlinked to
`~/.herdr`.

Prefix is `ctrl+a`. Detach with `Ctrl+a q`. Reload a running server with
`herdr server reload-config`.

Herdr automatically snapshots workspace, tab, and pane topology. Native
agent-session resume requires current official integrations. This config enables
it with `resume_agents_on_restore = true`. Normal Pi uses `~/.pi/agent`; ARC Pi
uses `~/.arc-pi`. After the first installation, already-running Pi panes need
`/reload` before they can use the integration. Diagnose an installation with
`herdr integration status`.

zsh completion is generated into [`zsh/completion/_herdr`](zsh/completion/_herdr)
(`herdr completion zsh`). Re-source `~/.zshrc` (or open a new shell) after install.

## Tailscale machine workflow

Use this inventory when operating across the Tailscale-connected Macs. Confirm
`hostname` and `whoami` before making changes on a remote machine.

Current devices:

- `andrews-mac-mini` / `100.77.5.31`
- `qianas-macbook-pro` / `100.122.22.119`

Common SSH targets:

```sh
ssh mini
ssh macbook
```

Both aliases are defined in [`ssh/config`](ssh/config) and use the local
`~/.ssh/id_ed25519` key. `mini` connects to `andrews-mac-mini`; `macbook`
connects to `qianas-macbook-pro`.

To apply these dotfiles on another Mac:

```sh
cd ~/dotfiles
git pull --ff-only
./install.sh
tmux source-file ~/.tmux.conf
herdr server reload-config
```

Run T3 Code through:

```sh
npxt3
```

This wraps the T3 Code no-install command:

```sh
npx -y t3@latest
```

Override the npm package if needed:

```sh
T3_CODE_NPX_PACKAGE='actual-package@latest' npxt3
```

## Omarchy configuration

The installer manages only this Omarchy allowlist:

- `omarchy/hypr/input.lua` → `~/.config/hypr/input.lua`
- `omarchy/shell.json` → `~/.config/omarchy/shell.json`
- `omarchy/XCompose` → `~/.XCompose`

These are regular copies, not symlinks. Identical regular destinations are left
alone. A differing file or any symlink is moved to a timestamped backup before the
tracked copy replaces it. The tracked input override maps Caps Lock to an additional
Ctrl key with `kb_options = "ctrl:nocaps"`.

`XCompose` includes Omarchy's default compose sequences and the private local file
with `include "%H/.XCompose.local"`. Existing local content is never overwritten.
When that file is absent, the installer creates an empty mode-600 local file only if
the destination is absent or already the tracked wrapper. If an existing destination
differs while the local file is absent, it warns and leaves the destination untouched.

Stock-identical Omarchy files, monitor configuration, generated/themed files, and
Omarchy-installed first-run hooks remain unmanaged so Omarchy continues to own them.

Apply repository updates with `./install.sh`. Hyprland applies input changes
automatically; force a reload and validate it with:

```sh
hyprctl reload
hyprctl configerrors
```

The Omarchy shell hot-reloads `shell.json`; use `omarchy restart shell` to force a
reload. Apply XCompose changes with `omarchy restart xcompose`.

## Local machine overrides

Use local files for machine-specific customization:

- `~/.aliases.local`
- `~/.vimrc.bundles.local`
- `~/.vimrc.local`
- `~/.zshrc.local` — sourced last by `zshrc`, so it can override anything above; put
  secrets and per-host tool setup here.
- `~/.XCompose.local` — private XCompose rules included by the tracked Omarchy
  wrapper; it is never tracked or overwritten by this repository.

These are sourced conditionally if present.

Shell config under `zsh/configs/` (prompt, keybindings, history, aliases, …) is loaded
automatically by `zshrc` via `_load_settings`; drop a new `*.zsh` file in the right
subdirectory rather than editing `zshrc`. The top-level `aliases` file is loaded through
`zsh/configs/aliases.zsh`.

## Releases

This repo uses Conventional Commits + `semantic-release` for automated semantic versioning.

### Commit format

Use Conventional Commit types in commit subjects:

- `feat:` -> minor release
- `fix:` -> patch release
- `BREAKING CHANGE:` in body/footer (or `!`) -> major release
- `chore:`, `docs:`, `refactor:`, etc. -> usually no release unless configured otherwise

### Release flow

- Releases run automatically on pushes to `main` via GitHub Actions.
- `semantic-release` calculates the next version from commit history.
- It creates/updates `CHANGELOG.md`, creates a Git tag, and publishes a GitHub Release.

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

### TypeScript LSP does not attach

- Confirm Neovim is 0.12+ and `typescript-language-server` is on Neovim's `PATH`:
  `zsh -lic 'nvim --version | head -n1; command -v typescript-language-server'`.
- Open a file under a pinned `ts_ls` root: the nearest package-manager
  lockfile or `.git` directory, with Neovim's process cwd as the fallback. Then
  run `:LspInfo`.
- `:checkhealth vim.lsp` reports Neovim LSP health. `:LspTypescriptSourceAction`
  and `:LspTypescriptGoToSourceDefinition` are only useful after `ts_ls` attaches.

### Tree-sitter parsers are missing

Run:

```sh
zsh -lic 'tree-sitter --version'
zsh -lic 'nvim --headless -u ~/.vimrc.bundles "+lua require(\"nvim-treesitter\").install({\"javascript\",\"jsdoc\",\"typescript\",\"tsx\"}):wait(300000)" +qa'
```

### Prettier or ESLint does not run automatically

- Save-time Prettier requires a project-local executable at
  `node_modules/.bin/prettier`.
- Save-time ESLint requires both `node_modules/.bin/eslint` and a discoverable
  `eslint.config.*`, `.eslintrc*`, or `package.json` `eslintConfig`.
- `,fm` may fall back to global `prettier`; `,ll` may fall back to global `eslint`
  or report that local ESLint has no config.
- In untrusted checkouts, run `:DotfilesTypeScriptLintDisable` before saving.

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
