# ADR 0018: Use NVM for Node-based editor tools

- **Status:** Accepted
- **Date:** 2026-07-14
- **Plan:** [`nvim-typescript-support-IMPLEMENTATION_PLAN.md`](../archive/nvim-typescript-support-IMPLEMENTATION_PLAN.md)

## Context

Both Macs load NVM from the tracked zsh setup. The MacBook's interactive NVM Node works, while its non-interactive Homebrew Node is broken. Mixing Homebrew and NVM ownership for Node-based editor tools would create different PATH and upgrade behavior on the two machines.

The Node-based tools in scope are TypeScript, `typescript-language-server`, Prettier, and ESLint. Projects should still control their own TypeScript/Prettier/ESLint versions when installed locally.

## Decision

Use:

- Homebrew formulas `neovim` and `tree-sitter-cli` on both Macs.
- Node 24 LTS as the active NVM default on both Macs, with global npm installation of `typescript@5.9.3`, `typescript-language-server`, `prettier`, and `eslint`. TypeScript 5.9.3 is the tested global fallback because npm's current TypeScript 7 package lacks `lib/tsserver.js` and `typescript-language-server` 5.3.0 rejects it.
- Project-local TypeScript, Prettier, and ESLint before global fallbacks.

All headless/remote verification must load the intended NVM default and report resolved executable paths/versions. Do not hard-code an NVM version directory.

## Consequences

- The provisioning policy is consistent across Apple Silicon and Intel Macs.
- Changing the NVM default or installing a new Node version may require reinstalling global npm packages; smoke checks detect missing tools.
- Global Prettier and ESLint remain explicit-only fallbacks under ADRs 0006 and 0007.
- The global TypeScript pin must be revisited when `typescript-language-server` supports TypeScript 7's packaging; project-local TypeScript remains preferred.
- Existing Homebrew `tsserver` installations may remain, but the active NVM `PATH` should resolve the NVM-managed tools first and `ts_ls` still launches only `typescript-language-server`.
