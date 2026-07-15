# ADR 0016: Fail fast on unsupported Neovim

- **Status:** Accepted
- **Date:** 2026-07-14
- **Plan:** [`nvim-typescript-support-IMPLEMENTATION_PLAN.md`](../nvim-typescript-support-IMPLEMENTATION_PLAN.md)

## Context

The selected current `nvim-treesitter` API requires Neovim 0.12+, and the current LSP stack also requires a newer Neovim than either machine presently has. Read-only MacBook inspection demonstrated the failure mode: `install.sh` can install/update a current `nvim-lspconfig` checkout while Neovim 0.9.5 then errors during startup.

The existing installer falls back to plain Vim when Neovim is unavailable, even though the repository is explicitly Neovim-first and the selected plugins cannot provide the planned behavior in plain Vim.

## Decision

Before any plugin or parser installation, `install.sh` must:

1. Require `nvim` to exist.
2. Parse and require Neovim 0.12 or newer.
3. Fail non-zero with architecture-neutral Homebrew/manual upgrade guidance when the requirement is not met.
4. Avoid installing/updating plugins or parsers after a failed preflight.

Remove the misleading plain-Vim plugin-install fallback from this path. Do not run Homebrew/npm upgrades automatically.

## Consequences

- Unsupported machines fail clearly instead of receiving a partially broken plugin set.
- Users must provision Neovim externally before running `install.sh`.
- Plain Vim installation through this bootstrap is no longer implied.
- Tests must cover missing Neovim, Neovim below 0.12, supported Neovim, and the guarantee that plugin/parser commands do not run after preflight failure.
