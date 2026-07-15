# ADR 0006: Format on save only with project-local Prettier

- **Status:** Accepted; local-binary criterion explicitly confirmed
- **Date:** 2026-07-14
- **Plan:** [`nvim-typescript-support-IMPLEMENTATION_PLAN.md`](../nvim-typescript-support-IMPLEMENTATION_PLAN.md)

## Context

Formatting should feel automatic in projects that have deliberately installed Prettier, without imposing a global formatter or default style on every JavaScript/TypeScript file.

The choices were explicit-only formatting, project-aware format-on-save, or format-on-save using any local/global Prettier. Conform's command resolver can search upward from the current buffer for `node_modules/.bin/prettier` and can expose an explicit format action separately. Its built-in Prettier `cwd`, however, is config-driven and does not treat an ordinary package root/local binary as sufficient, so the confirmed binary-only policy requires a custom `cwd` resolver.

## Decision

For JavaScript, JSX, TypeScript, and TSX buffers:

- Format on save whenever an executable `node_modules/.bin/prettier` is found by searching upward from that buffer's directory.
- The binary alone is the opt-in signal. A direct Prettier dependency, `.prettierrc`, `prettier.config.*`, or `package.json` Prettier key is not additionally required.
- Never fall back to global Prettier or `ts_ls` during format-on-save.
- Keep `<leader>fm` as an explicit format action. The explicit action may use project-local Prettier first and global `prettier` as fallback.
- Override Conform's Prettier `cwd`: derive the owning project root from the nearest local binary path; when explicit formatting uses only global Prettier, use the buffer directory. Prettier's `--stdin-filepath` continues to resolve any applicable config from the file path.

## Consequences

- Projects with a discoverable local Prettier binary receive automatic formatting, including binaries made available through a workspace or transitive installation.
- Projects without local Prettier are never changed automatically.
- A global Prettier remains useful for deliberate one-off formatting but cannot silently rewrite files on save.
- The implementation needs separate formatter-availability logic for automatic and explicit formatting plus a custom `cwd` resolver aligned with the nearest executable.
- A transitive/workspace-provided Prettier version can change without a direct dependency update; `:ConformInfo` and QA must report the executable/version actually selected.
- Tests must cover local-Prettier save, nearest executable/owning-root resolution in a nested monorepo, global-only save, no-Prettier save, and explicit global fallback.
