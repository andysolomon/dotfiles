# ADR 0002: Provision TypeScript tools outside Neovim

- **Status:** Accepted
- **Date:** 2026-07-14
- **Plan:** [`nvim-typescript-support-IMPLEMENTATION_PLAN.md`](../nvim-typescript-support-IMPLEMENTATION_PLAN.md)

## Context

The dotfiles are used on two Tailscale-connected Macs:

- `andrews-mac-mini-1` — current Mac mini.
- `qianas-macbook-pro-1` — remote MacBook Pro.

The existing Neovim configuration declares several obsolete LSP installer plugins. A modern installer such as Mason could replace them, but it would add another package-management layer inside Neovim. Both machines already use Homebrew and share these dotfiles through Git.

## Decision

Remove the obsolete Neovim LSP installers without replacing them with Mason. Provision Neovim and Tree-sitter CLI through Homebrew formulas `neovim` and `tree-sitter-cli` on each machine. Per [ADR 0018](0018-use-nvm-for-node-based-editor-tools.md), install global TypeScript 5.9.3, `typescript-language-server`, Prettier, and ESLint through npm under the active NVM default on both machines. Continue to prefer project-local TypeScript, Prettier, and ESLint versions when present.

Document equivalent, architecture-neutral setup and verification commands for both Macs. The Mac mini uses Apple Silicon Homebrew under `/opt/homebrew`; the MacBook Pro is Intel and uses Homebrew under `/usr/local`, so scripts must resolve native tools through `command -v`/`brew --prefix` rather than hard-code either prefix. All Node-based checks must load and report the active NVM default; remote headless checks especially require the MacBook's interactive zsh/NVM environment because its non-interactive `/usr/local/bin/node` is currently broken. Do not SSH to or mutate the other machine unless the user explicitly authorizes that operation.

## Consequences

- Neovim configuration remains smaller and does not own system executables.
- Each Mac requires a one-time external tool installation and independent verification.
- Version and architecture drift between machines is real, so the smoke checker must validate minimum versions, active-shell PATH, Node health, and required executables without assuming a Homebrew prefix.
- `install.sh` may install/update Vim plugins and Tree-sitter parsers, but it must not install global Homebrew/npm packages.
- Missing optional Prettier or ESLint tools must degrade gracefully; missing `typescript-language-server` must be reported clearly because semantic TypeScript support depends on it.
