# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Personal dotfiles for zsh, Vim/Neovim, and tmux, deployed to `$HOME` by a symlink-based
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
  (e.g. `zshrc` → `~/.zshrc`, `vim/` → `~/.vim`). Only `install.sh` and `README.md`
  are skipped. So a new top-level file named `foo` becomes `~/.foo` on next install —
  name new files with that in mind.
- It **never overwrites**: if `~/.<name>` already exists and is not a symlink, it only
  warns. Existing symlinks are left untouched. To re-link after renaming, remove the old
  symlink manually.
- It writes `~/.config/nvim/init.vim` (containing `source ~/.vimrc`) so Neovim reuses the
  Vim config, installs `vim-plug`, then runs `PlugInstall --sync`.

## Reload without reinstalling

- zsh: `source ~/.zshrc`
- Vim/Neovim: `:source ~/.vimrc`
- tmux: `tmux source-file ~/.tmux.conf`

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

### bin/ utilities (on PATH)

- `generate-vim-plugin-inventory` — see above.
- `tat` — attach/create a tmux session named after the current directory.
- `git-churn` — rank files by commit frequency.
- `replace` — project-wide find/replace helper.

## Conventions

- Local, non-committed customization goes in `*.local` files (`~/.aliases.local`,
  `~/.vimrc.local`, `~/.zshrc.local`, `~/.vimrc.bundles.local`), sourced only if present.
  Put machine-specific secrets/paths there, not in the tracked files.
- `mac` and `macos.txt` are opinionated, optional macOS system bootstrap (Homebrew, defaults).
  They are not run by `install.sh` — invoke `./mac` deliberately, only if wanted.
- `venv/` and `my-venv/` are committed legacy Python virtualenvs; don't treat them as source.
