# ADR 0005: Use native LSP completion and preserve Copilot

- **Status:** Accepted
- **Date:** 2026-07-14
- **Plan:** [`nvim-typescript-support-IMPLEMENTATION_PLAN.md`](../nvim-typescript-support-IMPLEMENTATION_PLAN.md)

## Context

Neovim 0.12 provides native LSP completion through `vim.lsp.completion`. The alternatives were adding an `nvim-cmp` stack or retaining manual omnifunc completion.

`github/copilot.vim` is already active and uses insert-mode `Tab` to accept inline suggestions. Its documentation states that `:Copilot status` checks operational status and that existing completion-menu visibility can temporarily hide inline suggestions.

A read-only baseline check on 2026-07-14 found:

- The `:Copilot` command exists.
- Insert-mode `Tab` maps to `copilot#Accept()`.
- `copilot#Accept` exists.
- Headless `:Copilot status` reports `Copilot: Ready` in a TypeScript buffer.

## Decision

Use Neovim native LSP completion with auto-triggering. Navigate LSP candidates with `Ctrl-N`/`Ctrl-P` and accept with `Ctrl-Y`. Do not map `Tab`; preserve Copilot's `Tab` acceptance behavior.

Treat Copilot health and coexistence as explicit acceptance criteria. Headless tests must verify plugin loading, status, and mappings; an interactive test must verify an inline suggestion can actually render and be accepted because headless mode cannot prove UI behavior.

## Consequences

- No `nvim-cmp` or completion-source plugins are added.
- The stale TypeScript omnifunc is removed after LSP completion works.
- The smoke checker must assert the Copilot command/function and `Tab` mapping, and run non-mutating `:Copilot status`.
- Automation must never run `:Copilot setup`, sign out, or expose authentication data.
- Native completion and Copilot need separate acceptance paths so one cannot mask a regression in the other.
