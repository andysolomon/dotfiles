# ADR 0014: Validate with fixtures and real projects on both Macs

- **Status:** Accepted
- **Date:** 2026-07-14
- **Plan:** [`nvim-typescript-support-IMPLEMENTATION_PLAN.md`](../archive/nvim-typescript-support-IMPLEMENTATION_PLAN.md)

## Context

The dotfiles repository does not contain a representative TypeScript application. A disposable fixture can prove filetype detection, parser activation, LSP attachment, diagnostics, completion capabilities, mappings, Copilot health, and controlled lint/format edge cases, but it cannot fully prove behavior with real project-local TypeScript, Prettier, ESLint, imports, TSX, or monorepo configuration.

The dotfiles must work on both `andrews-mac-mini-1` and `qianas-macbook-pro-1`.

## Decision

Require two validation layers on both supported Macs:

1. Run the repeatable automated disposable-fixture/headless checks.
2. Run interactive QA in at least one real TypeScript/TSX project with project-local tooling.

Representative projects:

- Mac mini: `~/Documents/Github/sprtsmng`, with `apps/web` as the primary TSX/Next.js package and `apps/tui` as an additional TypeScript package.
- MacBook Pro: `~/draft/draftMachine`, using `src/app/_components/sidenav.tsx` as an initial TSX file and `tailwind.config.ts` as an initial TS file.

The Mac-mini repository is a pnpm monorepo with TS/TSX source, package-level `tsconfig.json` and ESLint flat configs, package-local TypeScript/ESLint, and a root `node_modules/.bin/prettier`. It does not currently expose a main-worktree Prettier style config or direct root Prettier dependency, but ADR 0006 explicitly treats the discovered local binary alone as the format-on-save opt-in.

Read-only inspection found the MacBook currently has Neovim 0.9.5, Tree-sitter CLI 0.20.8, no global `typescript-language-server`, and an `nvim-lspconfig` startup error caused by the unsupported Neovim version. Copilot still reports ready headlessly. The project has local TypeScript 5.3.3, Prettier 3.3.3, and ESLint 8.57.1, but ESLint has no discoverable configuration and fails its stdin probe. Under ADR 0007, real-project saves must therefore skip lint quietly; publish/clear behavior must be validated in a disposable configured ESLint fixture rather than by modifying `draftMachine`. The interactive zsh/NVM Node 24.15.0 works; the non-interactive `/usr/local/bin/node` is broken because it links a missing ICU library.

Remote MacBook access or mutation still requires explicit authorization at execution time.

## Consequences

- A passing Mac-mini check alone is insufficient for shipping.
- Machine-specific PATH, Homebrew, Node/NVM, Copilot, parser, and project-local tool differences are exercised.
- The progress tracker must keep MacBook verification open until it is actually completed.
- If one machine cannot be accessed, it is reported as a shipping blocker rather than silently treated as covered.
