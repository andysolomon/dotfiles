# ADR 0015: Use the MacBook NVM environment for verification

- **Status:** Accepted
- **Date:** 2026-07-14
- **Plan:** [`nvim-typescript-support-IMPLEMENTATION_PLAN.md`](../archive/nvim-typescript-support-IMPLEMENTATION_PLAN.md)

## Context

Read-only MacBook inspection found two Node environments:

- Interactive zsh loads NVM Node 24.15.0 successfully.
- Non-interactive `/usr/local/bin/node` is broken because it links a missing ICU dylib.

Copilot reports ready when Neovim runs with the interactive NVM environment. Repairing Homebrew Node/ICU would mutate machine-level tooling outside the TypeScript editor configuration, while hard-coding an NVM version path would be fragile and machine-specific.

## Decision

Keep Homebrew Node/ICU repair outside this effort. Run remote/headless MacBook verification through its intended login-shell environment (for example, `NO_AUTO_TMUX=1 zsh -lic '<command>'`) and report the resolved `node`, `nvim`, and related executable paths in test output.

Do not hard-code an NVM version path in tracked Neovim configuration.

## Consequences

- Verification reflects how the user normally launches Neovim from interactive zsh.
- Remote scripts must suppress/handle the known non-TTY `stty` warning without hiding real command failures.
- A separate machine-maintenance task may repair `/usr/local/bin/node`, but it is not a blocker while the intended NVM environment works.
- Tests must fail clearly if the login shell stops loading a working Node version.
