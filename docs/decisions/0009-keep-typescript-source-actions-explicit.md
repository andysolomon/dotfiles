# ADR 0009: Keep TypeScript source actions explicit

- **Status:** Accepted
- **Date:** 2026-07-14
- **Plan:** [`nvim-typescript-support-IMPLEMENTATION_PLAN.md`](../archive/nvim-typescript-support-IMPLEMENTATION_PLAN.md)

## Context

`ts_ls` can expose whole-file source actions such as organizing imports, adding missing imports, removing unused code, and applying TypeScript fixes. These actions may edit more code than formatting and can interact with save-time Prettier behavior.

The choices were explicit actions, automatic organize-imports, or automatic organize-imports plus fix-all.

## Decision

Keep all TypeScript code/source actions explicit. Do not organize imports or apply TypeScript fix-all automatically on save.

Expose the standard buffer-local `gra` code-action path and document `:LspTypescriptSourceAction` for whole-file TypeScript source actions. If a stable leader alias is added, it must invoke the same explicit action and must not run from a save autocmd.

## Consequences

- Saving can format with project-local Prettier and lint with project-local ESLint, but it never performs semantic refactors.
- Import organization and fix-all remain deliberate, reviewable user actions.
- Tests must verify source actions work when invoked and that ordinary saves do not add/remove/reorder imports or apply fix-all.
- Automatic source actions may be reconsidered only as a separate decision after real-project usage.
