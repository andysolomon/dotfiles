# ADR 0007: Lint on save only with project-local ESLint

- **Status:** Accepted; config-presence criterion explicitly confirmed
- **Date:** 2026-07-14
- **Plan:** [`nvim-typescript-support-IMPLEMENTATION_PLAN.md`](../archive/nvim-typescript-support-IMPLEMENTATION_PLAN.md)

## Context

ESLint versions and configuration formats vary by project. Automatically running a global ESLint can produce version/configuration mismatches or execute against projects that did not opt into ESLint. Automatically running project-local binaries also requires trusting the repository.

The choices were local-only linting after save, automatic global fallback, or more frequent linting during editing.

## Decision

For JavaScript, JSX, TypeScript, and TSX buffers:

- Run ESLint automatically after save only when both conditions are true:
  1. An executable `node_modules/.bin/eslint` is found upward from the buffer directory.
  2. A discoverable flat/legacy ESLint config exists upward from the buffer, including `eslint.config.*`, `.eslintrc*`, or a `package.json` `eslintConfig` key.
- Do not use global ESLint automatically, and do not attempt automatic linting when configuration is absent.
- Provide a documented explicit lint command/mapping that prefers project-local ESLint and may fall back to global `eslint`.
- Run automatic project-local linting only in trusted repositories and document a per-buffer/project disable path.
- Do not lint on `InsertLeave` in the initial implementation.

## Consequences

- Projects with local, configured ESLint receive save-time diagnostics using their own version.
- Projects without local ESLint or without a discoverable config remain quiet on save.
- Global ESLint is available only through deliberate invocation.
- The implementation needs separate automatic and explicit linter-selection paths, analogous to formatting.
- Tests must cover configured local-ESLint save linting, local-without-config quiet behavior, global-only no-auto behavior, explicit failure/fallback messaging, diagnostic clearing, and missing-tool behavior.
