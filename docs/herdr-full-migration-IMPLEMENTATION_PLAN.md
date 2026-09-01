# Herdr Full-Time Migration Implementation Plan

**Work item:** `herdr-full-migration` (standalone request; no tracked issue)
**Mode:** Gap plan — Herdr is already installed, configured, and used as the SSH outer multiplexer, but daily panes still run inside nested tmux.
**Status:** In flight — Mac mini tmux cutover done; brew-services login residency and MacBook remain. Soak before deleting `tmux.conf`.
**Suggested branch:** `feat/herdr-full-migration`
**Plan date:** 2026-08-21

## 1. Product goal and scope boundaries

### Product goal

Make Herdr the only terminal multiplexer on both Tailscale Macs, with no nested `tmux attach` in the daily path:

- One Herdr session per machine, with one workspace per project.
- Prefix and pane/tab muscle memory that replace the current tmux `Ctrl+a` workflow.
- SSH login still lands in the host's live Herdr session.
- Agent panes (pi, Claude Code, Cursor Agent) survive detach natively, and survive Herdr server restart through official integrations rather than `tmux-resurrect`.
- Dotfiles, cheatsheet, and agent skills describe Herdr only. tmux remains an emergency binary at most, not a configured layer.

### In scope

- Hand-merge a tmux2herdr dry-run into tracked `herdr/config.toml` (never overwrite blindly).
- Rebind Herdr from the nested-tmux `ctrl+b` prefix to the tmux muscle-memory prefix `ctrl+a`.
- Rewrite `bin/tat` to focus-or-create a Herdr workspace for `$PWD`.
- Remove the SSH tmux fallback once both Macs have a working Herdr binary.
- Enable login-time Herdr server residency (`brew services start herdr`) as the continuum replacement.
- Verify official Herdr integrations for the agents actually used here.
- Update `README.md`, `CHEATSHEET.md`, `CLAUDE.md`, and `.agents/skills/tailscale-machine-ops/SKILL.md`.
- After a soak period, stop tracking `tmux.conf` / `.tmux/` / `bin/tmux-agent-sessions` as active config.

### Scope boundaries

- Do not convert a live nested tmux session into Herdr panes. Herdr cannot inherit tmux PTYs. Cutover recreates workspaces and relaunches agents.
- Do not uninstall the Homebrew `tmux` formula in the first shipping PR. Keep the binary as an emergency hatch until both Macs have soaked on Herdr-only.
- Do not enable `experimental.pane_history` (saves pane output, including secrets) unless explicitly requested later.
- Do not enable `experimental.allow_nested`.
- Do not change Neovim, zsh vi-mode, aliases, or install.sh's Neovim/plugin path except where they mention tmux/Herdr.
- Do not SSH to or mutate `qianas-macbook-pro` without explicit authorization.
- Do not add Herdr plugins, herdr-spreader layouts, or a second named Herdr session unless a later need appears.
- Do not treat `tmux2herdr` as the source of truth for keys that only exist to keep nested tmux alive.

## 2. Recommended decisions (confirm before coding)

These are the defaults this plan will implement unless the approval reply changes them.

1. **Leave nested tmux. Recreate panes in Herdr.** There is no live-session importer. Snapshot current tmux windows first, then stop using `tmux attach` inside Herdr.
2. **One default Herdr session per machine; projects are workspaces, not named sessions.** Named Herdr sessions stay unused. `tat` becomes "focus or create the workspace for this directory."
3. **Move the Herdr prefix to `ctrl+a` once tmux is no longer nested.** That restores current tmux muscle memory. Keep `prefix+a` / `prefix+prefix` as send-literal-prefix so remote shells and nested TUIs still work.
4. **Prefer Herdr defaults for keys that tmux only customized around plugins.** Map the daily set (splits, hjkl, tabs, zoom, copy mode, detach, reload). Drop mouse toggle keys (`m`/`M`), TPM reload, continuum save/restore chords, and `reattach-to-user-namespace`.
5. **Replace resurrect/continuum with Herdr server residency + native agent restore.** `brew services start herdr` at login. Keep `[session].resume_agents_on_restore = true`. Install/upgrade official integrations for pi, Claude Code, and Cursor Agent. Delete `bin/tmux-agent-sessions` after that path is verified.
6. **Keep the current SSH path:** interactive SSH still `exec herdr` on the remote host. Document `herdr --remote <host>` as an optional thin-client alternative; do not switch the auto-attach script to it.
7. **Drop host-colored tmux status bars.** Herdr already sets the outer window title to `{hostname}: {workspace}`. Add a hostname token on the tab bar if it is not already visible. Per-host accent colors are out of scope unless Herdr grows a hostname-conditional overlay (unknown today; one tracked `config.toml` cannot `if-shell` the way `tmux.conf` does).
8. **Keep `NO_AUTO_TMUX=1` as the documented escape hatch** and also honor `NO_AUTO_HERDR=1` with the same meaning.
9. **Keep `tmux.conf` in the repo until Phase 5.** Existing `~/.tmux.conf` symlinks stay until cutover is verified on both Macs.

## 3. Current baseline

Repository evidence:

- `herdr/config.toml` is nested-tmux phase only: `[ui] mouse_capture = true`, `[keys] prefix = "ctrl+b"`, plus a comment forbidding tmux2herdr until panes live in Herdr.
- `install.sh` skips top-level `herdr/` and symlinks `herdr/config.toml` → `~/.config/herdr/config.toml`.
- `zsh/configs/post/ssh-herdr.zsh` already `exec herdr` on interactive SSH when `TMUX`, `HERDR_ENV`, and `NO_AUTO_TMUX` are unset. tmux `ssh-$HOST` is still the fallback.
- `zsh/completion/_herdr` is tracked.
- `tmux.conf` is still the real multiplexer config: prefix `C-a`, vi pane keys, current-path splits, copy-pipe to pbcopy, host-colored status, TPM plugins (`sensible`, `resurrect`, `battery`, `continuum`), and a post-save hook into `bin/tmux-agent-sessions`.
- `bin/tat` is `tmux attach -t $(basename $PWD)` and does not create a missing session.
- `bin/tmux-agent-sessions` rewrites resurrect snapshots so pi / Claude / Cursor Agent relaunch with `--session` / `--resume`.
- Docs (`README.md`, `CHEATSHEET.md`, `CLAUDE.md`, tailscale skill) still describe the nested stack: Herdr outer, tmux inner.

Live-machine facts that are `unknown` until Phase 1 records them:

- Installed Herdr version on `andrews-mac-mini` and `qianas-macbook-pro`.
- Whether `brew services` already starts Herdr at login.
- `herdr integration status` for pi / claude / cursor-agent.
- The current nested tmux window/pane inventory (must be dumped at cutover; it is not in git).
- Whether the MacBook already has `~/.config/herdr/config.toml` linked from this repo.

## 4. Missing capabilities

| Current tmux behavior | Herdr target | Gap |
|---|---|---|
| Nested `tmux attach` inside Herdr | Panes are Herdr panes | Daily workflow still nested |
| Prefix `Ctrl+a` | `[keys] prefix = "ctrl+a"` | Tracked config still `ctrl+b` |
| `tat` → tmux session named after cwd | `tat` focuses or creates a Herdr workspace for `$PWD` | `bin/tat` still calls tmux |
| Continuum hourly save + restore on tmux start | `brew services start herdr` + snapshot restore | Not documented or configured in dotfiles |
| `tmux-agent-sessions` rewrite of resurrect pane commands | `[session] resume_agents_on_restore` + official integrations | Custom script is tmux-only |
| SSH fallback to `tmux new-session -A -s ssh-$HOST` | Fail closed to a plain shell, or require Herdr | Fallback still present |
| Host-colored status bar | Window title / tab-bar hostname | No Herdr equivalent planned |
| Battery in status-right | None | Deferred |
| Mouse toggle `prefix m/M` | `[ui] mouse_capture = true` always | Toggle keys not needed |
| Copy-pipe via `reattach-to-user-namespace` | Native Herdr copy mode / mouse drag | tmux-only |
| Docs describe two multiplexers | Docs describe Herdr only | README / CHEATSHEET / CLAUDE.md / skill |

Capability map for the daily key set (tmux → Herdr after prefix moves to `ctrl+a`):

| Habit | tmux now | Herdr after cutover |
|---|---|---|
| Prefix | `Ctrl+a` | `Ctrl+a` |
| Detach | `Ctrl+a d` | `Ctrl+a q` |
| Split down | `Ctrl+a "` or `-` | `Ctrl+a -` (bind `"` too if the dry-run does not) |
| Split right | `Ctrl+a %` `\` `\|` | `Ctrl+a v` plus keep `\` / `\|` if wanted |
| Move panes | `Ctrl+a h/j/k/l` | `Ctrl+a h/j/k/l` (Herdr default) |
| New tab | `Ctrl+a c` | `Ctrl+a c` |
| Next/prev tab | `Ctrl+a n/p` | `Ctrl+a n/p` |
| Zoom | `Ctrl+a +` | `Ctrl+a z` (Herdr default; rebind `+` only if muscle memory wins) |
| Copy mode | `Ctrl+a [` then `v`/`y` | `Ctrl+a [` then `v`/`y`/`Enter` (native clipboard) |
| Reload config | `Ctrl+a r` | Keep `Ctrl+a r` as reload if it does not steal Herdr resize mode; otherwise `Ctrl+a Shift+r` and document it |
| Last pane | `Ctrl+a Ctrl+a` | Bind `keys.last_pane` if the action exists in this Herdr version; else document `prefix+;` / picker |
| Send prefix | `Ctrl+a a` | `Ctrl+a a` and/or `Ctrl+a Ctrl+a` |
| Workspace picker | tmux session tree `Ctrl+a Ctrl+j` | `Ctrl+a w` / `Ctrl+a g` |
| Help | none | `Ctrl+a ?` |

## 5. Milestones / phases

### Phase 1 - Inventory the live nested setup and confirm decisions

**Goals:** Record what actually has to survive cutover. Confirm the decision list in section 2. Do not change tracked config yet.

**Deliverables:**

- A cutover note (can live in the progress file) with: `herdr --version`, `herdr status`, `herdr integration status`, `brew services list | grep herdr`, `tmux ls`, and `tmux list-windows -a` from the Mac mini.
- A tmux2herdr dry-run saved for reference, for example `tmux2herdr ~/.tmux.conf --dry-run`, never redirected onto `herdr/config.toml`.
- Explicit yes/no on each recommended decision if the approval reply changed any of them.

**Dependencies:** Herdr binary on PATH (or `~/.local/bin/herdr`). Optional: `cargo install tmux2herdr` or `herdr plugin install sohilladhani/tmux2herdr` for the dry-run.

**Risks:** Treating the dry-run as an apply step would smash the nested-phase config and bind Herdr to `ctrl+a` while tmux is still nested, making both prefixes fight.

**Acceptance criteria:**

- Progress file lists installed Herdr version and whether brew services already manage it.
- Dry-run output is consulted, not applied.
- Section 2 decisions are confirmed or amended in the progress file before Phase 2 edits.

### Phase 2 - Move daily panes into Herdr and take the prefix

**Goals:** Stop launching tmux inside Herdr. Make `herdr/config.toml` a standalone multiplexer config.

**Deliverables:**

- Update `herdr/config.toml`:
  - `onboarding = false`
  - `[keys] prefix = "ctrl+a"`
  - Daily key overrides from the table in section 4, merged by hand from the dry-run
  - `[ui] mouse_capture = true` (already present)
  - `[terminal] new_cwd = "follow"`
  - `[session] resume_agents_on_restore = true`
  - `[ui] window_title = "{hostname}: {workspace}"` if not already the default
  - hostname on `ui.tab_bar_right` if the version supports that token
  - do not set `experimental.allow_nested` or `experimental.pane_history`
- Reload with `herdr server reload-config` (or restart if prefix/startup settings require it).
- Operator cutover on the Mac mini (not a git operation):
  1. Snapshot tmux windows/panes.
  2. In Herdr, create one workspace per project (`herdr workspace create --cwd PATH --label NAME --focus` or the TUI).
  3. Relaunch agents with their native resume flags if needed.
  4. Detach/kill the inner tmux server (`tmux kill-server`) only after those panes are no longer the working set.
- `brew services start herdr` so a reboot restores session shape.

**Dependencies:** Phase 1 inventory. Official integrations installed/updated (`herdr integration install` / `herdr integration status`).

**Risks:** Killing tmux before agents are reattached in Herdr loses in-pane process state. Snapshot restore after `herdr server stop` does not keep arbitrary processes; only native agent restore relaunches supported agent CLIs.

**Acceptance criteria:**

- No pane in the daily Herdr session is running `tmux attach` / `tmux new-session`.
- `Ctrl+a ?` shows Herdr bindings, not a nested tmux prefix.
- Detach with `Ctrl+a q` and `herdr` reattaches to the same workspaces.
- `brew services list` shows herdr started.
- A pi/claude/cursor-agent pane is detected in the Herdr sidebar.

### Phase 3 - Replace tmux-only scripts and close the SSH fallback

**Goals:** Make PATH utilities and SSH login Herdr-native.

**Deliverables:**

- Rewrite `bin/tat`:
  - If not inside Herdr and no server is up, start/attach (`herdr`) after ensuring a workspace for `$PWD`.
  - If a workspace already has cwd/label matching `basename "$PWD"` (or the full path), focus it.
  - Otherwise `herdr workspace create --cwd "$PWD" --label "$(basename "$PWD")" --focus`.
  - Do not call `tmux`.
- Update `zsh/configs/post/ssh-herdr.zsh`:
  - Keep `exec herdr` as the success path.
  - Honor `NO_AUTO_HERDR` and `NO_AUTO_TMUX`.
  - Remove the tmux fallback once Phase 2 is true on both intended Macs; if Herdr is missing, print a one-line error and leave a normal SSH shell.
- Stop invoking `bin/tmux-agent-sessions` from any remaining tmux config. Leave the script in tree until Phase 5 unless it is already unused.
- Document `herdr --remote andrews-mac-mini` / `herdr --remote qianas-macbook-pro` in README as optional; do not change auto-attach to that path.

**Dependencies:** Phase 2 config and Mac mini cutover. MacBook changes wait for explicit authorization.

**Risks:** A naive `tat` that always `workspace create` will duplicate workspaces. Must list-and-focus first. SSH fallback removal will strand a host that does not have Herdr installed.

**Acceptance criteria:**

- From a project directory, `tat` focuses an existing matching workspace or creates exactly one new one.
- Interactive SSH with Herdr installed still `exec`s into that host's session.
- `NO_AUTO_HERDR=1 ssh …` and `NO_AUTO_TMUX=1 ssh …` both yield a plain shell.
- `rg tmux bin/tat zsh/configs/post/ssh-herdr.zsh` is empty.

### Phase 4 - Align user and agent documentation

**Goals:** Anyone (including future agent sessions) follows a Herdr-only mental model.

**Deliverables:**

- `CHEATSHEET.md`: one-layer multiplexer. Replace the tmux section with Herdr keys. `tat` row describes workspaces. Reload table and env toggles updated.
- `README.md`: Herdr as the multiplexer; tmux section becomes a short "removed after soak" note or is deleted in Phase 5. Troubleshooting covers `herdr server reload-config` and missing binary on SSH.
- `CLAUDE.md`: architecture section describes Herdr, not nested tmux. `tat` description matches the new script.
- `.agents/skills/tailscale-machine-ops/SKILL.md`: SSH auto-attach is Herdr-only; drop "install tmux for auto-attach."

**Dependencies:** Phases 2–3 so the docs match shipped behavior.

**Risks:** Docs that still mention `Ctrl+b` as the daily prefix will train the wrong muscle memory.

**Acceptance criteria:**

- Cheatsheet mental model is `terminal → herdr → zsh → nvim`.
- `CHEATSHEET.md` / `README.md` / `CLAUDE.md` no longer instruct the reader to nest tmux inside Herdr.
- Tailscale skill does not tell agents to `brew install tmux` for SSH.

### Phase 5 - Retire tracked tmux config after soak

**Goals:** tmux is no longer part of the installed dotfiles.

**Deliverables:**

- Remove or archive `tmux.conf`, `.tmux/` (if tracked), and `bin/tmux-agent-sessions`.
- Confirm `install.sh` skip list does not need a new exception (deleting `tmux.conf` is enough; it will no longer be symlinked).
- Leave existing `~/.tmux.conf` / `~/.tmux` on disk until the operator deletes those symlinks locally; `install.sh` must not force-delete them.
- Keep the Homebrew tmux formula installed until a later explicit uninstall request.

**Dependencies:** Successful soak on the Mac mini (and MacBook if authorized): several detach/reattach cycles, one reboot or `brew services restart herdr`, and one SSH attach.

**Risks:** Deleting tracked tmux too early leaves no rollback in the repo. Rollback is `git checkout` of this plan's parent plus `tmux source-file ~/.tmux.conf`.

**Acceptance criteria:**

- `git ls-files` no longer contains `tmux.conf` or `bin/tmux-agent-sessions`.
- `./install.sh` still links Herdr config and does not warn about `tmux.conf`.
- Emergency hatch is documented: `brew install tmux` plus checking out the last commit that had `tmux.conf`.

### Phase 6 - Verify, ship, archive

**Goals:** Dual-machine verification where authorized, then a focused PR and archive of these planning files.

**Deliverables:**

- Mac mini verification matrix (below).
- MacBook verification only with explicit authorization: `git pull`, `./install.sh`, `herdr server reload-config`, `brew services start herdr`, SSH from the mini.
- Shipping PR on `feat/herdr-full-migration`.
- After merge: move this plan and progress file to `docs/archive/` via `.claude/skills/arc-implementation-plan-progress/scripts/archive_plan.sh`.

**Verification matrix (user-facing, not implementation-coupled):**

1. `herdr --version` and `herdr status` succeed.
2. `Ctrl+a ?` lists the documented bindings.
3. Split, hjkl, new tab, zoom, copy-mode yank, and detach/reattach work in a scratch workspace.
4. `tat` from a repo directory focuses or creates one workspace labeled with that basename.
5. Interactive SSH from the other Mac attaches the existing Herdr session without starting tmux.
6. `NO_AUTO_HERDR=1 ssh …` is a plain shell.
7. After `brew services restart herdr` (or reboot), workspaces/tabs/cwds return; supported agent panes resume conversations rather than empty shells.
8. `herdr integration status` shows current integrations for the agents actually running.
9. No daily pane is a nested tmux client (`ps` / pane command is zsh, nvim, or an agent).

**Dependencies:** Phases 2–5. GitHub push/PR only when explicitly requested.

**Risks:** Prefix change requires a server restart, not only `reload-config`. Test that explicitly.

**Acceptance criteria:**

- Matrix items 1–9 pass on the Mac mini.
- MacBook items pass if authorization was given; otherwise they are listed as deferred in the PR body.
- Planning files move to `docs/archive/` after the shipping PR merges.

## 6. Out of scope / deferred

- Uninstalling Homebrew `tmux`.
- Host-specific green/blue/yellow accent colors.
- Battery widget in the Herdr tab bar.
- `experimental.pane_history`.
- Switching SSH auto-attach to `herdr --remote`.
- herdr-spreader / saved multi-pane layout files.
- Automatic tab rename via zsh `preexec` hooks.
- Prefix-free `ctrl+alt` chords.
- Migrating other machines beyond the two known Tailscale Macs.
- Changing Neovim tmux-unrelated settings.

## 7. Immediate next steps

1. Confirm or amend the section 2 decisions (especially prefix `ctrl+a`, dropping host colors, and keeping brew tmux installed).
2. On the Mac mini, record the Phase 1 inventory commands into `docs/herdr-full-migration-progress.txt`.
3. After approval, implement Phase 2 config in `herdr/config.toml` on branch `feat/herdr-full-migration` before any tmux kill-server.
4. Recreate workspaces in Herdr, then kill the nested tmux server.
5. Only then rewrite `tat` and drop the SSH tmux fallback.

Do not start file changes until this plan is approved.
