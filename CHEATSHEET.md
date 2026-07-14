# Keyboard & Command Cheat Sheet

Personal reference for this dotfiles setup: **zsh (vi mode) → tmux (`Ctrl+a`) → Neovim (leader `,`)**.

Print-friendly one-pager. Regenerate or extend as your config changes.

---

## Mental model

```
Terminal app (Ghostty / iTerm / etc.)
  └─ zsh          history, completion, aliases, shell functions
       └─ tmux     sessions, windows, panes, copy mode
            └─ nvim   edit files, grep, LSP, Copilot, NERDTree
```

| Layer | Prefix / mode | Escape hatch |
|-------|---------------|--------------|
| zsh | `Esc` → vi command mode | `Ctrl+C` cancel, `Ctrl+D` logout |
| tmux | `Ctrl+a` then key | `Ctrl+a` `d` detach |
| nvim | `,` leader, `jk` = Esc | `:q!` force quit |

---

## Top 20 keys to memorize

| Key | What it does |
|-----|--------------|
| `Ctrl+R` | Search shell history |
| `Ctrl+A` / `Ctrl+E` | Line start / end (shell) |
| `Ctrl+Q` | Stash current line, run something else, pop it back |
| `Ctrl+a` | tmux prefix |
| `Ctrl+a` `"` / `%` | Split pane horizontal / vertical |
| `Ctrl+a` `h/j/k/l` | Move between tmux panes |
| `Ctrl+a` `d` | Detach from tmux |
| `Ctrl+a` `[` | tmux copy mode |
| `,` | Neovim leader |
| `jk` | Leave insert mode (Neovim) |
| `,,` | Toggle previous buffer |
| `Ctrl+t` | Toggle file tree (NERDTree) |
| `,w` / `,q` | Save / quit (Neovim) |
| `,/` | Toggle comment |
| `K` | Grep word under cursor |
| `Ctrl+h/j/k/l` | Move between nvim splits |
| `g` | `git status` (no args) or `git …` |
| `tat` | Attach tmux session for current directory |
| `mcd dirname` | `mkdir -p` and `cd` into it |

---

## Zsh (shell)

Vi mode is on (`bindkey -v`). You start in **insert mode**. Press `Esc` (or `Ctrl+F`) for **command mode**.

### Navigation & editing (works in most contexts)

| Key | Action |
|-----|--------|
| `Ctrl+A` | Beginning of line |
| `Ctrl+E` | End of line |
| `Ctrl+K` | Kill from cursor to end of line |
| `Ctrl+U` | Kill whole line |
| `Ctrl+W` | Kill word backward |
| `Ctrl+Y` | Paste (yank) last killed text |
| `Ctrl+L` | Clear screen |
| `Ctrl+C` | Cancel current command |
| `Ctrl+D` | EOF / logout (empty line) |
| `Ctrl+Z` | Suspend process (`fg` to resume) |

### History

| Key | Action |
|-----|--------|
| `Ctrl+R` | Incremental history search backward |
| `Ctrl+S` | History search forward (if terminal allows; flow control disabled via `stty -ixon`) |
| `Ctrl+P` | Previous history entry (prefix match) |
| `Ctrl+N` | Next history entry |
| `Ctrl+O` | Run command, then pull next history line |
| `↑` / `↓` | Previous / next history (if not in vi cmd mode) |

### Line tricks

| Key | Action |
|-----|--------|
| `Ctrl+Y` | Accept line and hold (re-edit on next prompt) |
| `Ctrl+Q` | Push line to stack (`push-line-or-edit`) |
| `Ctrl+N` | Insert last word of previous command |
| `Ctrl+T` | Prefix line with `sudo` |
| `Alt+.` | Insert last argument of previous command (default zsh) |
| `!!` | Repeat last command |
| `!$` | Last argument of previous command |
| `!^` | First argument of previous command |
| `!grep` | Last command starting with `grep` |

### Vi command mode (`Esc` first)

| Key | Action |
|-----|--------|
| `i` / `a` / `A` | Insert before cursor / after / end of line |
| `I` / `O` | Insert at line start / new line above |
| `0` / `$` / `^` | Start / end / first non-blank |
| `w` / `W` / `b` / `B` | Word forward/back (big/small word) |
| `e` / `E` | End of word |
| `f{char}` / `F{char}` | Jump to char forward / backward |
| `;` / `,` | Repeat / reverse `f`/`F` |
| `x` / `X` | Delete char under / before cursor |
| `dw` / `cw` | Delete word / change word |
| `dd` | Delete whole line |
| `D` | Delete to end of line |
| `cc` | Change whole line |
| `u` / `Ctrl+_` | Undo edit |
| `k` / `j` | Older / newer history entry |
| `/` / `?` | Search history forward / backward |
| `n` / `N` | Next / prev history search match |
| `v` | Open current line in `$EDITOR` |
| `.` | Repeat last change |

### Completion

| Key | Action |
|-----|--------|
| `Tab` | Complete |
| `Tab Tab` | Show completion menu |
| `Ctrl+N` / `Ctrl+P` | Next / prev completion candidate |
| `→` | Accept completion (with menu open) |

### Directory & path shortcuts

| Command / option | Action |
|------------------|--------|
| `autocd` | Type a directory path alone to `cd` there |
| `autopushd` | `cd` pushes directory stack |
| `pushd` / `popd` / `dirs` | Stack navigation |
| `...` | `cd ../..` (alias) |
| `cd -` | Previous directory |
| `cd ~` | Home |

---

## Shell functions (`~/.zsh/functions/`)

| Command | Action |
|---------|--------|
| `g` | `git status` with no args; otherwise `git "$@"` |
| `g status` / `g diff` / … | Pass-through to git |
| `mcd path` | `mkdir -p path && cd path` |
| `envup` | Export vars from `.env` in current directory |
| `change-extension from to` | Rename `**/*.{from}` → `.{to}` recursively |

---

## Aliases (`~/.aliases`)

### Editor

| Alias | Action |
|-------|--------|
| `vim` / `vi` | Both run `nvim` |
| `e` | `$EDITOR` |
| `v` | `$VISUAL` |

### Files & listing

| Alias | Action |
|-------|--------|
| `l` | `ls` |
| `ll` | `ls -al` |
| `lh` | `ls -Alh` |
| `ln` | `ln -v` |
| `mkdir` | `mkdir -p` |
| `tlf` | `tail -f` |

### Global suffix aliases

| Suffix | Expands to |
|--------|------------|
| `G` | `\| grep` |
| `M` | `\| less` |
| `L` | `\| wc -l` |
| `ONE` | `\| awk '{ print $1 }'` |

### Git / Ruby / Rails (legacy but still defined)

| Alias | Action |
|-------|--------|
| `gci` | `git pull --rebase && rake && git push` |
| `b` | `bundle` |
| `t` | `ruby -I test` |
| `cuc` | `bundle exec cucumber` |
| `gi` / `giv` | `gem install` / `gem install -v` |
| `migrate` / `m` | Rails migrate dance |
| `rk` | `rake` |
| `s` | `rspec` |
| `z` | `zeus` |

Machine-specific aliases: `~/.aliases.local`

---

## `bin/` utilities (on PATH)

| Command | Action |
|---------|--------|
| `tat` | `tmux attach -t $(basename $PWD)` — session per directory |
| `replace old new files…` | Find/replace across files via `ag` + `sed` |
| `git-churn` | Rank changed files by commit frequency vs `origin/master` |
| `npxt3` | Run T3 Code via `npx -y ${T3_CODE_NPX_PACKAGE:-t3@latest}` |
| `generate-vim-plugin-inventory` | Regenerate `PLUGIN_INVENTORY.md` |

Examples:

```sh
tat
replace foo bar **/*.ts
git-churn
T3_CODE_NPX_PACKAGE='actual-package@latest' npxt3
```

---

## Tmux

**Prefix: `Ctrl+a`** (GNU Screen style, not default `Ctrl+b`).

Press prefix, release, then the second key — unless noted as a chord (`Ctrl+a` held).

### Sessions

| Keys | Action |
|------|--------|
| `tmux` | New session |
| `tmux new -s name` | Named session |
| `tmux ls` | List sessions |
| `tmux attach -t name` | Attach |
| `tat` | Attach to session named after `basename $PWD` |
| `Ctrl+a` `d` | Detach |
| `Ctrl+a` `$` | Rename session |
| `Ctrl+a` `s` | Session picker |
| `Ctrl+a` `(` / `)` | Previous / next session |

SSH auto-attaches to `ssh-$HOST` unless `NO_AUTO_TMUX=1`.

### Windows

| Keys | Action |
|------|--------|
| `Ctrl+a` `c` | New window |
| `Ctrl+a` `n` / `p` | Next / previous window |
| `Ctrl+a` `0`–`9` | Jump to window number |
| `Ctrl+a` `,` | Rename window |
| `Ctrl+a` `&` | Kill window |
| `Ctrl+a` `w` | Window list |
| `Ctrl+a` `Ctrl+h` / `Ctrl+l` | Previous / next window |
| `Ctrl+a` `Ctrl+j` | `choose-tree` (session/window tree) |

Windows are 1-indexed and renumber after closes.

### Panes

| Keys | Action |
|------|--------|
| `Ctrl+a` `"` or `-` | Split horizontal (current path) |
| `Ctrl+a` `%` or `\` or `\|` | Split vertical (current path) |
| `Ctrl+a` `h` `j` `k` `l` | Move to pane (vi-style) |
| `Ctrl+a` `Ctrl+a` | Toggle last pane |
| `Ctrl+a` `o` | Cycle panes |
| `Ctrl+a` `;` | Toggle last pane (default) |
| `Ctrl+a` `x` | Kill pane |
| `Ctrl+a` `!` | Move pane to new window |
| `Ctrl+a` `b` | Break pane into new window |
| `Ctrl+a` `+` | Zoom / unzoom pane |
| `Ctrl+a` `=` | Tile all panes |
| `Ctrl+a` `↑↓←→` | Resize pane (your config: 4–8 cells) |
| `Ctrl+a` `q` | Show pane numbers, then jump |
| `Ctrl+a` `{` / `}` | Swap pane with previous / next |

### Copy mode (vi keys)

| Keys | Action |
|------|--------|
| `Ctrl+a` `[` | Enter copy mode |
| `h` `j` `k` `l` | Move |
| `w` / `b` / `e` | Word motion |
| `g` / `G` | Top / bottom |
| `/` / `?` | Search forward / backward |
| `v` | Begin selection |
| `y` or `Enter` | Copy to macOS clipboard |
| `q` | Quit copy mode |
| `Esc` | Quit copy mode |

### Your custom tmux keys

| Keys | Action |
|------|--------|
| `Ctrl+a` `r` | Reload `~/.tmux.conf` |
| `Ctrl+a` `m` | Mouse on |
| `Ctrl+a` `M` | Mouse off |
| `Ctrl+a` `a` | Send literal `Ctrl+a` to app |

### tmux-resurrect + continuum (installed)

| Keys | Action |
|------|--------|
| `Ctrl+a` `Ctrl+s` | Save session |
| `Ctrl+a` `Ctrl+r` | Restore session |

Continuum autosaves about every **60 minutes** and restores the last save when the
tmux server starts. Save also records pi / Claude / Cursor agent session IDs so
restore relaunches with `--session` or `--resume`. Debug mapping:
`tmux-agent-sessions status` (writes `~/.tmux/resurrect/agent-sessions.tsv` on save).

### Host status bar colors (Tailscale SSH)

| Host | Bar color |
|------|-----------|
| `andrews-mac-mini-1` | Green |
| `qianas-macbook-pro-1` | Blue |
| Other hosts | Yellow |

---

## Neovim

**Leader: `,`** (comma). **`jk` = Esc** in insert/visual. Arrow keys are disabled in normal mode.

Colorscheme: **Kanagawa** (`wave` dark). `vim`/`vi` both launch nvim.

### Modes

| Key | Mode |
|-----|------|
| `Esc` / `jk` | Normal |
| `i` `a` `o` `O` `I` `A` | Insert |
| `v` `V` `Ctrl+v` | Visual char / line / block |
| `:` | Command line |
| `Ctrl+\` `Ctrl+n` | Term mode (in `:term`) |

### Movement (normal)

| Key | Action |
|-----|--------|
| `h` `j` `k` `l` | Left / down / up / right |
| `w` `b` `e` | Word forward / back / end |
| `W` `B` `E` | WORD (whitespace-separated) |
| `0` `^` `$` | Line start / first char / end |
| `H` `L` | Line start / end (your remap) |
| `gg` / `G` | File top / bottom |
| `{` / `}` | Previous / next paragraph |
| `%` | Matching bracket |
| `*` / `#` | Search word under cursor forward / back |
| `n` / `N` | Next / prev search match |
| `Ctrl+d` / `Ctrl+u` | Half page down / up |
| `Ctrl+f` / `Ctrl+b` | Page down / up |
| `zz` / `zt` / `zb` | Center / top / bottom cursor line |

### Buffers & files

| Key / cmd | Action |
|-----------|--------|
| `,,` | Toggle previous buffer (`Ctrl+^`) |
| `,e` | Edit file in current directory |
| `,w` | Save |
| `,x` | Save and quit |
| `,q` | Quit |
| `:e path` | Open file |
| `:w` | Save |
| `:q` / `:wq` / `:x` | Quit / write+quit |
| `:bn` / `:bp` | Next / previous buffer |
| `:bd` | Delete buffer |
| `:ls` | List buffers |

### Splits & tabs

| Key | Action |
|-----|--------|
| `,s` / `,v` | Horizontal / vertical split |
| `,S` / `,V` | Split in current file’s directory |
| `Ctrl+h/j/k/l` | Move between splits |
| `Ctrl+w` `q` | Close split |
| `Ctrl+w` `o` | Only this window |
| `Ctrl+w` `=` | Equalize split sizes |
| `Ctrl+w` `H/J/K/L` | Move split to edge |
| `:sp` / `:vsp` | Split commands |
| `:tabnew` / `gt` / `gT` | Tabs |

### Editing

| Key | Action |
|-----|--------|
| `i` `a` `o` `O` | Insert before / after / below / above |
| `dd` / `yy` / `p` `P` | Delete / yank / paste line |
| `dw` `cw` `d$` | Delete word / change word / to EOL |
| `u` / `Ctrl+r` | Undo / redo |
| `.` | Repeat last change |
| `>>` / `<<` | Indent / dedent line |
| `=` | Auto-indent motion |
| `J` | Join lines |
| `~` | Toggle case |
| `Ctrl+a` / `Ctrl+x` | Increment / decrement number |
| `-` / `_` | Move line down / up (your remap) |
| `,y` | Yank paragraph (`V`]`) |
| `,"` `,'` `,\`` | Wrap word in quotes |
| `(` `[` `{` `"` `'` | Auto-close pairs (insert) |
| `Ctrl+d` (insert) | Delete line |
| `Ctrl+u` (insert) | Upcase word |

### Search & replace

| Key / cmd | Action |
|-----------|--------|
| `/` / `?` | Search forward / backward |
| `n` / `N` | Next / prev match |
| `*` / `#` | Search word under cursor |
| `K` | Grep word under cursor (`ag`) |
| `\` | Start `:Ag` |
| `,f` | `:%s/` (project replace prompt) |
| `:noh` | Clear search highlight |
| `:%s/old/new/g` | Replace all in file |

### Config & dotfiles

| Key | Action |
|-----|--------|
| `,ev` | Edit `~/dotfiles/vimrc.global` |
| `,sv` | Reload vimrc and re-detect indent (`:Sleuth`) |

### Plugins — install (headless)

After uncommenting or adding a `Plug` line in `vimrc.bundles`:

```sh
nvim --headless -u ~/.vimrc.bundles "+PlugInstall --sync" +qa   # install/update
nvim --headless -u ~/.vimrc.bundles "+PlugClean!" +qa          # remove disabled plugins
bin/generate-vim-plugin-inventory                              # refresh PLUGIN_INVENTORY.md
```

`./install.sh` runs the install step too. Re-open files or run `,sv` / `:Sleuth` so new plugins apply to already-open buffers.

### Plugins — your mappings

| Key | Action |
|-----|--------|
| `Ctrl+t` | Toggle NERDTree |
| `,n` | NERDTree: reveal current file |
| `,/` | Toggle comment (nerdcommenter) |
| `Ctrl+l` | Limelight (focus paragraph) |
| `Ctrl+l` `l` | Toggle Limelight on/off |

### Plugins — default keys worth knowing

#### NERDTree (in tree buffer)

| Key | Action |
|-----|--------|
| `o` / `Enter` | Open file / toggle dir |
| `t` | Open in new tab |
| `i` | Open in horizontal split |
| `s` | Open in vertical split |
| `p` | Go to parent |
| `C` | Change tree root to selected dir |
| `m` | File menu (add/delete/rename) |
| `r` | Refresh tree |
| `q` | Close tree |

#### vim-gitgutter (leader is `,`)

| Key | Action |
|-----|--------|
| `]c` | Next hunk |
| `[c` | Previous hunk |
| `,hp` | Preview hunk |
| `,hs` | Stage hunk |
| `,hu` | Undo hunk |
| `,hS` | Stage entire buffer |
| `,hU` | Undo entire buffer |

#### Copilot (insert mode)

| Key | Action |
|-----|--------|
| `Tab` | Accept suggestion (if no other Tab map) |
| `Alt+\` or `Ctrl+Space` | Open suggestion (terminal-dependent) |
| `Alt+]` / `Alt+[` | Next / previous suggestion |
| `Alt+→` | Accept word |
| `Ctrl+]` | Dismiss + default `Ctrl+]` behavior |

#### LSP (built-in Neovim + lspconfig)

| Command | Action |
|---------|--------|
| `:LspInfo` / `:checkhealth vim.lsp` | Server status |
| `gd` | Go to definition |
| `gr` | References |
| `K` | Hover (overridden in your config for grep) |
| `gi` | Go to implementation |
| `Ctrl+o` / `Ctrl+i` | Jump back / forward |

### Terminal inside nvim

| Command / key | Action |
|---------------|--------|
| `:term` | Open terminal split |
| `Ctrl+\` `Ctrl+n` | Leave term mode → normal |
| `i` `a` | Re-enter term mode |

### Marks & registers

| Key | Action |
|-----|--------|
| `ma` / `'a` | Set / jump to mark |
| `"ayy` | Yank line to register `a` |
| `"ap` | Paste register `a` |
| `:reg` | Show registers |

### Visual mode

| Key | Action |
|-----|--------|
| `>` / `<` | Indent selection |
| `y` / `d` / `c` | Yank / delete / change |
| `jk` | Back to normal |

### Useful ex commands

| Command | Action |
|---------|--------|
| `:PlugInstall` | Install vim-plug plugins (interactive) |
| `:PlugUpdate` | Update plugins |
| `:PlugClean` | Remove unlisted plugins |
| `:source ~/.vimrc` | Reload config |
| `:colorscheme kanagawa-dragon` | Switch Kanagawa variant |
| `:set nu` / `:set nonu` | Toggle line numbers |
| `:set wrap` / `:set nowrap` | Toggle wrap |

---

## Git (quick CLI reference)

Your `g` function defaults to status.

| Command | Action |
|---------|--------|
| `g` | Status |
| `g diff` | Diff |
| `g add -p` | Stage hunks interactively |
| `g commit -m "msg"` | Commit |
| `g push` / `g pull` | Push / pull |
| `g log --oneline -10` | Recent history |
| `g checkout -b branch` | New branch |
| `g switch branch` | Switch branch |
| `git-churn` | Hot files on current branch |

Conventional commit types (for `semantic-release`): `feat:`, `fix:`, `chore:`, `docs:`, `refactor:`, `BREAKING CHANGE:`.

---

## Reload config without reinstalling

| What | Command |
|------|---------|
| zsh | `source ~/.zshrc` |
| tmux | `tmux source-file ~/.tmux.conf` or `Ctrl+a` `r` |
| nvim | `:source ~/.vimrc` or `,sv` (also runs `:Sleuth`) |
| Full dotfiles symlink | `./install.sh` from repo root |

---

## Environment toggles

| Variable | Effect |
|----------|--------|
| `NO_AUTO_TMUX=1` | Skip SSH auto-attach to tmux |
| `DOTFILES_NERD_FONT=0` | ASCII-safe NERDTree arrows (no icon font) |
| `T3_CODE_NPX_PACKAGE` | Override package for `npxt3` |
| `PS1=…` | Override zsh prompt (exported) |

Local overrides (not in repo): `~/.zshrc.local`, `~/.aliases.local`, `~/.vimrc.local`

---

## macOS terminal tips

| Key | Action |
|-----|--------|
| `Cmd+K` | Clear scrollback (many terminals) |
| `Cmd+T` / `Cmd+N` | New tab / window |
| `Cmd+W` | Close tab |
| `Cmd+±` | Zoom font |

Use a **Nerd Font** (e.g. Hack Nerd Font) for devicons in nvim unless `DOTFILES_NERD_FONT=0`.

---

## SSH workflow (this setup)

```sh
ssh andrewsolomon@andrews-mac-mini-1      # auto-attaches tmux (green bar)
ssh andrewsolomon@qianas-macbook-pro-1    # blue bar
NO_AUTO_TMUX=1 ssh user@host              # plain shell, no tmux
```

After dotfiles install on a remote Mac: `./install.sh`, then `source ~/.zshrc`.

---

## Kanagawa theme variants

In nvim:

```
:colorscheme kanagawa        " default (wave)
:colorscheme kanagawa-wave
:colorscheme kanagawa-dragon " darker
:colorscheme kanagawa-lotus  " light
```

Persistent config lives in `vimrc.global`.
