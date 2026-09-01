# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Personal dotfiles for zsh, Vim/Neovim, and Herdr, deployed to `$HOME` by a symlink-based
installer. There is no build or test suite — "running" a change means re-sourcing the
relevant config and confirming it loads without error.

Note: the `README.md` triggers a Vercel/Next.js "bootstrap" skill suggestion via a hook.
It is a false positive — this repo has no web app. Ignore it.

## Install / apply changes

```sh
./install.sh   # symlink top-level items, apply the explicit Omarchy allowlist, set up nvim, install plugins
```

`install.sh` is the deployment mechanism and the key thing to understand:

- It iterates **every top-level file/dir** and symlinks it to `$HOME/.<name>`
  (e.g. `zshrc` → `~/.zshrc`, `vim/` → `~/.vim`). Skipped: `install.sh`, `README.md`,
  `docs/` (repo planning), `herdr/` (XDG config, not `~/.herdr`), `omarchy/`
  (Omarchy-specific XDG config), and `ssh/` (installed as `~/.ssh/config`, without
  managing private keys). A new top-level file
  named `foo` becomes `~/.foo` on next install — name new files with that in mind.
- It **never overwrites** top-level `~/.<name>` targets: if the destination already exists
  and is not a symlink, it only warns. Existing symlinks are left untouched. To re-link
  after renaming, remove the old symlink manually.
- If `~/.bin` already exists as a directory, it still links each executable from `bin/`
  into `~/.bin/` (PATH comes from `zsh/configs/post/path.zsh`).
- It writes `~/.config/nvim/init.vim` (containing `source ~/.vimrc`) so Neovim reuses the
  Vim config, installs `vim-plug`, then runs `PlugInstall --sync`.
- It symlinks `herdr/config.toml` to `~/.config/herdr/config.toml` if that path is missing.
- It symlinks `ssh/config` to `~/.ssh/config`. A pre-existing real file is backed up to
  `~/.ssh/config.pre-dotfiles`. Keys and `known_hosts` remain machine-local.
- On Omarchy, it copies only the explicit allowlist: `omarchy/hypr/input.lua` to
  `~/.config/hypr/input.lua`, `omarchy/shell.json` to `~/.config/omarchy/shell.json`,
  and `omarchy/XCompose` to `~/.XCompose`. Parent directories are created as needed.
  Copies are regular files, not symlinks; identical regular destinations are skipped,
  while differing files and symlinks are moved to timestamped backups before replacement.
- XCompose includes Omarchy's default sequences and `include "%H/.XCompose.local"`.
  An existing `~/.XCompose.local` is preserved. If it is absent, an empty mode-600 file
  is created only when `~/.XCompose` is absent or already equals the tracked wrapper; a
  differing destination with no local file is warned about and left untouched.
- Stock-identical Omarchy files, monitor configuration, generated/themed files, and
  Omarchy-installed first-run hooks remain unmanaged.

## Reload without reinstalling

- zsh: `source ~/.zshrc`
- Vim/Neovim: `:source ~/.vimrc`
- Herdr: `herdr server reload-config`
- Hyprland input: `hyprctl reload`, then `hyprctl configerrors`
- Omarchy shell: hot-reloads `~/.config/omarchy/shell.json`; force with `omarchy restart shell`
- XCompose: `omarchy restart xcompose`

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

### Herdr

`herdr/config.toml` is repository-only at the top level (not `~/.herdr`). `install.sh`
symlinks it to `~/.config/herdr/config.toml`. Prefix is `ctrl+a`. Completions live in
`zsh/completion/_herdr`.

Herdr in-app toasts are enabled for ARC Pi operator prompts. ARC Pi publishes a
blocked agent state while a question or approval is open and clears it when the
prompt settles; the notification label is generic and does not expose question
text.

SSH shells attach to Herdr through `zsh/configs/post/ssh-herdr.zsh` (`exec herdr`)
unless `NO_AUTO_HERDR=1`, `NO_AUTO_TMUX=1`, or `HERDR_ENV=1` is set. If Herdr is
missing, SSH stays a plain shell.

`tmux.conf` is still tracked as a soak-period emergency hatch. Do not nest tmux
inside Herdr.

### bin/ utilities (on PATH)

- `generate-vim-plugin-inventory` — see above.
- `pi` — forward normal commands to mise-managed Pi; translate Pi self-updates to
  `mise upgrade pi`, including updates requested through ARC Pi.
- `npxt3` — run T3 Code through `npx -y ${T3_CODE_NPX_PACKAGE:-t3@latest}`.
- `tat` — focus or create a Herdr workspace for the current directory.
- `git-churn` — rank files by commit frequency.
- `replace` — project-wide find/replace helper.

### Omarchy

The installer manages this explicit allowlist only on Omarchy systems:

- `omarchy/hypr/input.lua` → `~/.config/hypr/input.lua`
- `omarchy/shell.json` → `~/.config/omarchy/shell.json`
- `omarchy/XCompose` → `~/.XCompose`

These files are copied beneath their live destinations because Hyprland's Lua module
loader requires `input.lua` beneath its config root and the other overrides are also
intended to be regular files. Identical regular files are no-ops; differing files and
symlinks are moved to timestamped backups before replacement. The input override maps
Caps Lock to Ctrl with `ctrl:nocaps`.

The tracked XCompose wrapper includes Omarchy's default sequences and the private
`include "%H/.XCompose.local"`. Existing local content is never overwritten. A local
file is created empty with mode 600 only when absent and safe to initialize; if a local
file is absent while an existing `~/.XCompose` differs from the wrapper, the installer
warns and leaves that destination untouched. Stock-identical Omarchy files, monitor
configuration, generated/themed files, and first-run hooks remain unmanaged.

### SSH

`ssh/config` is installed as `~/.ssh/config`. It tracks safe host aliases `ssh mini`
and `ssh macbook`; never commit private keys, `known_hosts`, or credentials.

### Tailscale machine ops

Use this shared machine inventory for remote operations. Confirm `hostname` and
`whoami` before changing another machine. Current known devices:

- `andrews-mac-mini` / `Andrews-Mac-mini` / `100.77.5.31` / macOS / current Mac mini.
- `qianas-macbook-pro` / `100.122.22.119` / macOS / other MacBook Pro.

## Conventions

- Local, non-committed customization goes in `*.local` files (`~/.aliases.local`,
  `~/.vimrc.local`, `~/.zshrc.local`, `~/.vimrc.bundles.local`, `~/.XCompose.local`),
  sourced or included only if present.
  Put machine-specific secrets/paths there, not in the tracked files.
- `mac` and `macos.txt` are opinionated, optional macOS system bootstrap (Homebrew, defaults).
  They are not run by `install.sh` — invoke `./mac` deliberately, only if wanted.
- `venv/` and `my-venv/` are committed legacy Python virtualenvs; don't treat them as source.
