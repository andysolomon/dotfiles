# ADR 0012: Use native-first LSP keybindings

- **Status:** Accepted
- **Date:** 2026-07-14
- **Plan:** [`nvim-typescript-support-IMPLEMENTATION_PLAN.md`](../archive/nvim-typescript-support-IMPLEMENTATION_PLAN.md)

## Context

Neovim 0.12 provides a `gr*` family of built-in LSP mappings. The current cheatsheet inaccurately presents `gr` as references and `K` as hover even though the configuration globally maps `K` to grep and no server attaches.

Adding a second leader-based mapping vocabulary would increase documentation and maintenance. Mapping bare `gr` would conflict with Neovim's native `grn`, `gra`, `grr`, and `gri` family.

## Decision

Use the native-first mapping model:

- `gd` — definition (buffer-local when LSP attaches).
- `K` — hover in an attached buffer; retain global grep behavior elsewhere.
- `grn` — rename.
- `gra` — code action.
- `grr` — references.
- `gri` — implementation.
- `[d` / `]d` — previous/next diagnostic.
- `<leader>fm` — explicit format.
- `<leader>ll` — explicit lint.
- `<leader>ih` — buffer-local inlay-hint toggle.
- TypeScript source actions and source-definition navigation remain documented commands unless a later demonstrated workflow justifies another mapping.

## Consequences

- The configuration aligns with current Neovim conventions.
- No bare `gr` mapping or redundant rename/code-action leader aliases are added.
- README and CHEATSHEET must replace the inaccurate current mapping descriptions.
- Headless checks must inspect buffer/global mappings, and interactive QA must exercise each mapping in the appropriate context.
