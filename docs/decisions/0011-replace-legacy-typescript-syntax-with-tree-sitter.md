# ADR 0011: Replace legacy TypeScript syntax with Tree-sitter

- **Status:** Accepted
- **Date:** 2026-07-14
- **Plan:** [`nvim-typescript-support-IMPLEMENTATION_PLAN.md`](../archive/nvim-typescript-support-IMPLEMENTATION_PLAN.md)

## Context

`leafgarland/typescript-vim` currently provides TypeScript syntax/filetype support, while the TSX plugin declaration is inactive. Neovim 0.12 has native TypeScript/TSX filetype detection, and the selected current `nvim-treesitter` stack supplies parser-based highlighting for TypeScript and TSX.

Keeping legacy syntax as a fallback would leave two highlighting systems and make parser failures less obvious. A conditional fallback would add configuration paths that need separate testing.

## Decision

After verifying native filetype detection and installed Tree-sitter parsers/highlighters for TS and TSX, remove `leafgarland/typescript-vim` and the inactive `peitalin/vim-jsx-typescript` declaration. Tree-sitter becomes the sole TS/TSX parser/highlighter.

Do not run `PlugClean!` until the replacement behavior passes.

## Consequences

- TypeScript and TSX highlighting use one current parser system.
- Parser installation and health checks become required rather than silently falling back.
- `install.sh` and the smoke checker must verify all selected parsers.
- Rollback is straightforward: restore the plugin declaration if Tree-sitter cannot be made reliable, but do not ship both paths by default.
