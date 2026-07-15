# ADR 0008: Configure inlay hints with an off-by-default toggle

- **Status:** Accepted
- **Date:** 2026-07-14
- **Plan:** [`nvim-typescript-support-IMPLEMENTATION_PLAN.md`](../archive/nvim-typescript-support-IMPLEMENTATION_PLAN.md)

## Context

TypeScript inlay hints can expose inferred parameter names, variable/property types, function parameter/return types, and enum values. They are useful for unfamiliar code but can add substantial visual noise.

Neovim provides a built-in inlay-hint API (available before, and supported by, the selected 0.12+ baseline), and `typescript-language-server` can request TypeScript/JavaScript hints through server settings.

## Decision

Configure `ts_ls` inlay-hint preferences for all four supported JS/TS filetypes, but leave hint display disabled by default. Add a documented buffer-local toggle using Neovim's current `vim.lsp.inlay_hint` API.

The toggle must enable hints only for the current buffer and accurately reflect/toggle the current state. Re-sourcing the configuration must not duplicate mappings or force hints on.

## Consequences

- Inlay hints are available on demand without making every buffer visually noisy.
- The `ts_ls` settings need explicit TypeScript and JavaScript inlay-hint preferences.
- The cheatsheet must document the toggle and its buffer-local scope.
- Verification must confirm hints start disabled, become visible after toggling, and disappear after toggling again in both TypeScript and TSX fixtures.
