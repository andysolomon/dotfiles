# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Personal dotfiles for zsh, Vim/Neovim, tmux, and Herdr, deployed to `$HOME` by a symlink-based
installer. There is no build or test suite — "running" a change means re-sourcing the
relevant config and confirming it loads without error.

Note: the `README.md` triggers a Vercel/Next.js "bootstrap" skill suggestion via a hook.
It is a false positive — this repo has no web app. Ignore it.

## Install / apply changes

```sh
./install.sh   # symlink every top-level item to ~/.<name>, set up nvim, install plugins
```

`install.sh` is the deployment mechanism and the key thing to understand:

- It iterates **every top-level file/dir** and symlinks it to `$HOME/.<name>`
  (e.g. `zshrc` → `~/.zshrc`, `vim/` → `~/.vim`). Skipped: `install.sh`, `README.md`,
  `docs/` (repo planning), `herdr/` (XDG config, not `~/.herdr`), and `ssh/`
  (installed as `~/.ssh/config`, without managing private keys). A new top-level file
  named `foo` becomes `~/.foo` on next install — name new files with that in mind.
- It **never overwrites** top-level `~/.<name>` targets: if the destination already exists
  and is not a symlink, it only warns. Existing symlinks are left untouched. To re-link
  after renaming, remove the old symlink manually.
- It writes `~/.config/nvim/init.vim` (containing `source ~/.vimrc`) so Neovim reuses the
  Vim config, installs `vim-plug`, then runs `PlugInstall --sync`.
- It symlinks `herdr/config.toml` to `~/.config/herdr/config.toml` if that path is missing.
- It symlinks `ssh/config` to `~/.ssh/config`. A pre-existing real file is backed up to
  `~/.ssh/config.pre-dotfiles`. Keys and `known_hosts` remain machine-local.

## Reload without reinstalling

- zsh: `source ~/.zshrc`
- Vim/Neovim: `:source ~/.vimrc`
- tmux: `tmux source-file ~/.tmux.conf`
- Herdr: `herdr server reload-config`

## Architecture

### Vim/Neovim config (split + sourced)

`vimrc` is the entrypoint and does nothing but source five files in order:
`vimrc.bundles` → `vimrc.global` → `vimrc.plugins` → `vimrc.macros` → `vimrc.local`.
Neovim shares this exact config via `~/.config/nvim/init.vim` → `~/.vimrc`.

- `vimrc.bundles` — plugin declarations for `vim-plug` (`Plug '...'`). **A plugin is
  enabled by uncommenting its line and disabled by prefixing `"`** (Vim comment). This
  active/inactive-by-comment convention is what `PLUGIN_INVENTORY.md` reports on.
- `vimrc.global` — core editor settings.
- `vimrc.plugins` — per-plugin configuration and mappings. Reads `$DOTFILES_NERD_FONT`:
  set it to `0` to force ASCII-safe rendering (arrows instead of Nerd Font glyphs / devicons)
  on machines without a Nerd Font installed.
- `vimrc.local` — machine-specific overrides (this file itself is symlinked, but the
  README's "local override" pattern also supports `~/.vimrc.local`, `~/.vimrc.bundles.local`).

Plugin management:

```sh
nvim --headless -u ~/.vimrc.bundles "+PlugInstall --sync" +qa   # install/update
nvim --headless -u ~/.vimrc.bundles "+PlugClean!"    +qa        # remove disabled plugins
```

Leader key is `,`.

### PLUGIN_INVENTORY.md is generated — do not hand-edit

`bin/generate-vim-plugin-inventory` parses `vimrc.bundles` and regenerates
`PLUGIN_INVENTORY.md`. A `Plug` line prefixed with `"` is marked **Inactive**; uncommented
is **Active**. Plugin descriptions live in a hardcoded `awk` lookup table inside that
script — **when adding a new plugin, add its description there too**, otherwise it renders
as the generic fallback string. Regenerate after editing `vimrc.bundles`:

```sh
bin/generate-vim-plugin-inventory
```

### zsh config (modular auto-loading)

`zshrc` bootstraps a directory-driven loader (originally thoughtbot-style):

- Every file in `zsh/functions/` is `source`d as a shell function.
- `zsh/configs/` is loaded in three passes: `pre/` first, then top-level `*.zsh`, then
  `post/` last (path/completion setup that must run after everything else lives in `post/`).
- To add shell config, drop a `.zsh` file in the right `zsh/configs` subdir rather than
  editing `zshrc` — the loader picks it up automatically.
- The tail of `zshrc` sets up PATH, NVM, and toolchain env (Homebrew, Racket, Java, Python).

`aliases` is a separate top-level file (→ `~/.aliases`) and is Ruby/Rails-era; it sources
`~/.aliases.local` for machine-specific additions.

### tmux

`tmux.conf` (→ `~/.tmux.conf`) with prefix remapped to `Ctrl+a`, vi-style pane navigation,
and TPM-managed plugins (`tpm`, `tmux-sensible`, `tmux-resurrect`, `tmux-battery`).
`.tmux/` holds TPM itself.

SSH shells attach to Herdr through `zsh/configs/post/ssh-herdr.zsh` (`exec herdr`)
unless `NO_AUTO_TMUX=1` or `HERDR_ENV=1` is set. If Herdr is missing, they fall
back to tmux (`ssh-$HOST`). The tmux status bar is host-color-coded for known
Tailscale Macs: `andrews-mac-mini` / `Andrews-Mac-mini` is green,
`qianas-macbook-pro` is blue, and unknown hosts are yellow.

### Herdr

`herdr/config.toml` is repository-only at the top level (not `~/.herdr`). `install.sh`
symlinks it to `~/.config/herdr/config.toml`. Prefix is `ctrl+a`. Completions live in
`zsh/completion/_herdr`.

### bin/ utilities (on PATH)

- `generate-vim-plugin-inventory` — see above.
- `npxt3` — run T3 Code through `npx -y ${T3_CODE_NPX_PACKAGE:-t3@latest}`.
- `tat` — attach/create a tmux session named after the current directory.
- `git-churn` — rank files by commit frequency.
- `replace` — project-wide find/replace helper.

### SSH

`ssh/config` is installed as `~/.ssh/config`. It tracks safe host aliases such as
`ssh mini`; never commit private keys, `known_hosts`, or credentials.

### Tailscale machine ops

Use `.agents/skills/tailscale-machine-ops/SKILL.md` as the shared machine inventory for
Codex and Claude Code. Current known devices:

- `andrews-mac-mini` / `Andrews-Mac-mini` / `100.77.5.31` / macOS / current Mac mini.
- `qianas-macbook-pro` / `100.122.22.119` / macOS / other MacBook Pro.

## Conventions

- Local, non-committed customization goes in `*.local` files (`~/.aliases.local`,
  `~/.vimrc.local`, `~/.zshrc.local`, `~/.vimrc.bundles.local`), sourced only if present.
  Put machine-specific secrets/paths there, not in the tracked files.
- `mac` and `macos.txt` are opinionated, optional macOS system bootstrap (Homebrew, defaults).
  They are not run by `install.sh` — invoke `./mac` deliberately, only if wanted.
- `venv/` and `my-venv/` are committed legacy Python virtualenvs; don't treat them as source.
