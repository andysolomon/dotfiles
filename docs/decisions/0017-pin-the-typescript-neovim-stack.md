# ADR 0017: Pin the TypeScript Neovim stack

- **Status:** Accepted
- **Date:** 2026-07-14
- **Plan:** [`nvim-typescript-support-IMPLEMENTATION_PLAN.md`](../archive/nvim-typescript-support-IMPLEMENTATION_PLAN.md)

## Context

The repository currently allows vim-plug dependencies to track their latest upstream commits. The MacBook already demonstrates the failure mode: an updated `nvim-lspconfig` checkout no longer runs on its older Neovim. Installing the same dotfiles on two machines at different times can therefore produce different editor behavior.

The new TypeScript stack combines several APIs that must remain compatible: Neovim core LSP, `nvim-lspconfig`, current-main `nvim-treesitter`, Conform, `nvim-lint`, and Tree-sitter parser revisions.

## Decision

Pin these four plugins to exact commits selected and verified during implementation:

- `neovim/nvim-lspconfig`
- `nvim-treesitter/nvim-treesitter`
- `stevearc/conform.nvim`
- `mfussenegger/nvim-lint`

Keep the Tree-sitter `main` branch declaration together with its tested commit. Parser installation/update must use the parser revisions described by that pinned plugin checkout.

Update pins only as an explicit maintenance change that runs the complete headless/smoke and two-Mac validation suite. Copilot and unrelated existing plugins retain their current update policy but remain covered by coexistence checks.

## Consequences

- Both Macs install the same TypeScript-support plugin code.
- Upstream fixes and features do not arrive until pins are deliberately advanced.
- The plan cannot name final commit hashes until implementation verifies the selected checkouts; those hashes must be recorded in the final diff/docs.
- Plugin inventory/docs and smoke output should report the tested commits to make drift diagnosable.
