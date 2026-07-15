# ADR 0003: Support JavaScript alongside TypeScript

- **Status:** Accepted
- **Date:** 2026-07-14
- **Plan:** [`nvim-typescript-support-IMPLEMENTATION_PLAN.md`](../archive/nvim-typescript-support-IMPLEMENTATION_PLAN.md)

## Context

The primary goal is modern TypeScript and TSX editing. The standard `nvim-lspconfig` `ts_ls` configuration also supports JavaScript and JSX through the `javascript` and `javascriptreact` filetypes. Mixed JavaScript/TypeScript projects are common, and restricting the language server would require overriding upstream defaults.

Tree-sitter, Prettier, and ESLint also naturally cover all four JS/TS filetypes.

## Decision

Treat TypeScript and TSX as the primary acceptance target, while enabling the same LSP, parser, formatting, and linting stack for JavaScript and JSX.

The supported filetypes are:

- `typescript`
- `typescriptreact`
- `javascript`
- `javascriptreact`

## Consequences

- Mixed JS/TS repositories receive one coherent editing experience.
- The implementation can retain the standard `ts_ls` filetype list instead of maintaining a custom restriction.
- Smoke coverage must verify attachment/filetype behavior across all four filetypes, while deeper semantic/refactor acceptance remains focused on TS and TSX.
- Documentation must say that JavaScript/JSX support is intentional, not accidental scope creep.
- Existing JavaScript behavior may change, so regression QA must cover representative `.js` and `.jsx` buffers.
