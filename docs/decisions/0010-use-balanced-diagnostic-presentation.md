# ADR 0010: Use balanced diagnostic presentation

- **Status:** Accepted
- **Date:** 2026-07-14
- **Plan:** [`nvim-typescript-support-IMPLEMENTATION_PLAN.md`](../archive/nvim-typescript-support-IMPLEMENTATION_PLAN.md)

## Context

TypeScript LSP and ESLint can produce many diagnostics. Showing every warning inline is noisy, while hiding all messages makes type errors harder to notice. Neovim diagnostics can independently control signs, underlines, virtual text, severity ordering, floats, and navigation.

## Decision

Use a balanced diagnostic display across LSP and ESLint namespaces:

- Show signs and underlines for warnings and errors.
- Show inline virtual text only for errors.
- Sort by severity.
- Provide a bordered diagnostic float with full details on demand.
- Provide documented previous/next diagnostic mappings.
- Use ASCII-safe sign text so the display does not require a Nerd Font.

## Consequences

- Errors remain prominent without placing every warning message inline.
- Warnings remain visible through signs/underlines and can be inspected in the float.
- The same presentation applies consistently to TypeScript and ESLint diagnostics.
- Verification must cover error virtual text, warning suppression from virtual text, signs/underlines, float content, severity order, and navigation.
