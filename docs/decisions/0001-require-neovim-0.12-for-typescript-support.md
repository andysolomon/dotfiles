# ADR 0001: Require Neovim 0.12 for TypeScript support

- **Status:** Accepted
- **Date:** 2026-07-14
- **Plan:** [`nvim-typescript-support-IMPLEMENTATION_PLAN.md`](../archive/nvim-typescript-support-IMPLEMENTATION_PLAN.md)

## Context

The current machine has Neovim 0.11.1. The installed `nvim-lspconfig` documentation requires Neovim 0.11.3 or newer, while the current `nvim-treesitter` `main` branch requires Neovim 0.12 or newer and Tree-sitter CLI 0.26.1 or newer. Homebrew currently offers Neovim 0.12.4.

Supporting current LSP and Tree-sitter APIs on one baseline is simpler and safer than pinning a legacy Tree-sitter branch or deferring TSX parsing.

## Decision

Require Neovim 0.12 or newer for this TypeScript-support effort. Use the current `nvim-treesitter` `main` API and require Tree-sitter CLI 0.26.1 or newer.

## Consequences

- The local Neovim and Tree-sitter CLI must be upgraded before implementation validation.
- The implementation may use `vim.lsp.enable`, native LSP completion, and the current Tree-sitter installation/highlighting APIs.
- Neovim 0.11 and the legacy `nvim-treesitter` `master` API are out of scope.
- README setup and smoke checks must enforce and explain the minimum versions.
