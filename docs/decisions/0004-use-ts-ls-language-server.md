# ADR 0004: Use `ts_ls` as the TypeScript language server

- **Status:** Accepted
- **Date:** 2026-07-14
- **Plan:** [`nvim-typescript-support-IMPLEMENTATION_PLAN.md`](../nvim-typescript-support-IMPLEMENTATION_PLAN.md)

## Context

The editor needs one semantic engine for TypeScript, TSX, JavaScript, and JSX. The main candidates were:

- `ts_ls` through `typescript-language-server`.
- `vtsls`, which builds on VS Code's TypeScript extension behavior.
- `typescript-tools.nvim`, a TypeScript-specific Neovim plugin that communicates with `tsserver`.

The requested capabilities are diagnostics, completion, navigation, rename/refactoring, import/source actions, and project-aware TypeScript behavior. The current `nvim-lspconfig` `ts_ls` configuration provides these capabilities, monorepo/root handling, Deno exclusion, TypeScript source-action commands, and project-local TypeScript discovery without another Neovim plugin.

## Decision

Use only `ts_ls`, launched as `typescript-language-server --stdio`. Do not enable `vtsls`, `typescript-tools.nvim`, or raw `tsserver` as another client.

## Consequences

- The configuration follows the standard current `nvim-lspconfig` path.
- `typescript-language-server` is a required external executable on both supported Macs.
- Project-local TypeScript remains preferred by the server.
- Verification must prove exactly one `ts_ls` client attaches per supported buffer.
- Richer server-specific features unique to `vtsls` or `typescript-tools.nvim` are deferred and may be reconsidered only if a concrete missing workflow appears.
