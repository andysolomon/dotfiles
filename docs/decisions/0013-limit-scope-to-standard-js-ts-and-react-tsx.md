# ADR 0013: Limit scope to standard JS/TS and React-style TSX

- **Status:** Accepted
- **Date:** 2026-07-14
- **Plan:** [`nvim-typescript-support-IMPLEMENTATION_PLAN.md`](../nvim-typescript-support-IMPLEMENTATION_PLAN.md)

## Context

The selected `ts_ls` configuration supports standard JavaScript, TypeScript, JSX, and TSX projects. Deno requires mutually exclusive routing with `denols`; Vue, Svelte, Astro, and Angular require additional language servers and framework-specific integration.

Adding those ecosystems would broaden installation, root detection, plugin configuration, and testing without evidence that they are needed for the current projects.

## Decision

Support standard Node/browser projects using JavaScript, TypeScript, JSX, and React-style TSX. Keep Deno and framework-specific single-file/language-server integration for Vue, Svelte, Astro, and Angular out of scope.

## Consequences

- The implementation retains the standard `ts_ls` Deno-exclusion behavior.
- React-style TSX is fully in scope through the `typescriptreact` filetype.
- No `denols`, Vue, Svelte, Astro, or Angular server/tool dependencies are added.
- If one of these ecosystems becomes an actual requirement, it should start a separate decision/plan with its own root-routing and verification criteria.
