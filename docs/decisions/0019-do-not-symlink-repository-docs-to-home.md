# ADR 0019: Do not symlink repository docs to home

- **Status:** Accepted
- **Date:** 2026-07-15
- **Plan:** [`nvim-typescript-support-IMPLEMENTATION_PLAN.md`](../nvim-typescript-support-IMPLEMENTATION_PLAN.md)

## Context

The installer symlinks top-level repository entries into `$HOME` as dotfiles, with explicit skips for files that are installer metadata rather than user configuration. The TypeScript support work added a top-level `docs/` directory for planning artifacts and decision records.

Creating `~/.docs` from this repository planning directory would expose implementation notes as a user dotfile path and make future planning artifacts part of install behavior even though they are not runtime configuration.

## Decision

`install.sh` must skip the top-level `docs/` directory and must not create `~/.docs`.

All other installer behavior remains unchanged:

- The Neovim 0.12+ preflight still runs before any HOME mutation.
- Existing skips for `install.sh` and `README.md` remain.
- Other ordinary top-level entries still symlink to `$HOME` as dotfiles.
- Vim-plug installation, plugin installation, and bounded Tree-sitter parser installation still run for a supported Neovim.

## Consequences

- Planning documents and ADRs stay repository-local.
- Users do not get a `~/.docs` symlink from this dotfiles installer.
- Adding future repository-only top-level directories requires an explicit installer decision rather than relying on the broad symlink loop.
