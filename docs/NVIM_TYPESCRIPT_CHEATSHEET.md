# Neovim TypeScript, TSX, JavaScript, and JSX Cheatsheet

Practical reference for the configuration in this repository. The leader key is
`,`; semantic actions require an attached `ts_ls` client. This file stays in the
repository-only `docs/` directory and is not linked into `$HOME`
([ADR 0019](decisions/0019-do-not-symlink-repository-docs-to-home.md)).

## Prerequisites and health

- Neovim 0.12+ and Tree-sitter CLI 0.26.1+.
- The `javascript`, `jsdoc`, `typescript`, and `tsx` Tree-sitter parsers.
- NVM default Node 24 with global `typescript@5.9.3`,
  `typescript-language-server`, `prettier`, and `eslint` on `PATH`.
- The pinned `nvim-lspconfig`, `nvim-treesitter`, `conform.nvim`, and
  `nvim-lint` plugins, plus `github/copilot.vim` when using Copilot.

Run checks from the repository root in a login zsh so the NVM default is active:

```sh
zsh -lic 'nvim --version | head -n1'
zsh -lic 'tree-sitter --version'
zsh -lic 'command -v typescript-language-server && typescript-language-server --version'
zsh -lic 'tsc --version && prettier --version && eslint --version'
zsh -lic 'nvim --headless -u ~/.vimrc +qa'
zsh -lic 'bin/check-nvim-typescript-support'
```

Inside Neovim, use `:LspInfo` for attachment and `:checkhealth vim.lsp` for LSP
health. `ts_ls` must show one client launched as
`typescript-language-server --stdio`; raw `tsserver` is not an LSP server.

## Supported files

| Extension | Neovim filetype | Tree-sitter language |
|-----------|-----------------|----------------------|
| `.ts` | `typescript` | `typescript` |
| `.tsx` | `typescriptreact` | `tsx` |
| `.js` | `javascript` | `javascript` |
| `.jsx` | `javascriptreact` | `javascript` |

The stack targets standard Node/browser JavaScript and TypeScript plus
React-style JSX/TSX. Deno and framework-specific Vue, Svelte, Astro, and Angular
language-server integration are outside this configuration.

## LSP navigation and refactoring

`gd`, `gh`, diagnostic navigation, formatting, linting, and inlay hints are set
buffer-locally on LSP attachment. The `gr*`, `gO`, and insert-mode `Ctrl+S`
mappings below are Neovim 0.12 native LSP defaults. Global `K` remains
project-wide `ag` search (not LSP hover).

| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gh` | Show hover (types/docs) |
| `grr` | List references |
| `gri` | Go to implementation |
| `grt` | Go to type definition |
| `grn` | Rename symbol |
| `gra` | Show code actions in normal or visual mode |
| `gO` | List document symbols |
| `Ctrl+S` (insert) | Show signature help |
| `Ctrl+O` / `Ctrl+I` | Move backward / forward through the jump list |

## Completion and Copilot

Native LSP completion is enabled with auto-triggering when the attached client
supports completion. The menu uses `menu`, `menuone`, `noselect`, and `popup`.

| Key / command | Action |
|---------------|--------|
| `Ctrl+N` / `Ctrl+P` | Select the next / previous completion candidate |
| `Ctrl+Y` | Accept the selected native completion candidate |
| `Tab` | Accept the current Copilot inline suggestion |
| `:Copilot status` | Check Copilot readiness without changing authentication |

LSP completion does not remap `Tab`. A visible completion menu can temporarily
hide a Copilot inline suggestion, so choose native candidates with
`Ctrl+N`/`Ctrl+P`/`Ctrl+Y` and use `Tab` separately for Copilot.

## Diagnostics and inlay hints

TypeScript LSP and ESLint diagnostics use separate namespaces but share the
same presentation: severity-sorted ASCII `E`/`W`/`I`/`H` signs, underlines for
errors and warnings, inline virtual text for errors only, and rounded detail
floats that show a source when multiple sources contribute.

| Key | Action |
|-----|--------|
| `[d` | Previous diagnostic and open its float |
| `]d` | Next diagnostic and open its float |
| `,ih` | Toggle configured inlay hints for the current buffer |

Inlay hints start disabled. The toggle affects only the current buffer and
covers parameter names, inferred types, return types, properties, and enum
values supplied by `ts_ls`.

## Explicit TypeScript actions

| Key / command | Action |
|---------------|--------|
| `gra` | Contextual code actions and refactors at the cursor or visual selection |
| `:LspTypescriptSourceAction` | Whole-file `source.*` actions such as organize imports or remove unused code |
| `:LspTypescriptGoToSourceDefinition` | Jump to original source instead of a type definition |

The two commands are buffer-local and exist only after `ts_ls` attaches. Saving
never runs organize-imports, fix-all, or another TypeScript source action.

## Prettier and ESLint policy

| Action | Project-local behavior | Global fallback |
|--------|------------------------|-----------------|
| Save (format) | Format only if an executable `node_modules/.bin/prettier` is found upward | Never |
| `,fm` | Format with the nearest local Prettier; `:ConformInfo` shows resolution | Allowed when no local Prettier exists |
| Save (lint) | Lint after save only if local ESLint and a discoverable config are both found upward | Never |
| `,ll` | Lint with configured local ESLint | Allowed only when no local ESLint exists |

Prettier save opt-in is the local executable itself; no Prettier config is
required. Both automatic and explicit formatting set `lsp_format = 'never'`.

ESLint config discovery recognizes `eslint.config.{js,mjs,cjs,ts,mts,cts}`,
`.eslintrc`, `.eslintrc.{js,cjs,yaml,yml,json}`, and a `package.json`
`eslintConfig` key. If a local ESLint exists without a config, saves stay quiet
and `,ll` reports the missing config; it does not bypass that local binary with
global ESLint. Use
`:DotfilesTypeScriptLintDisable` to disable automatic ESLint for the current
buffer (useful before saving an untrusted checkout). Explicit `,ll` remains
available.

## Troubleshooting

- Wrong language mode: run `:set filetype?` and compare it with the table above.
- No semantics or TypeScript commands: run `:LspInfo` and
  `:checkhealth vim.lsp`. Open the file below the nearest package-manager
  lockfile or `.git`; otherwise `ts_ls` uses Neovim's working directory. A nearer
  Deno root intentionally prevents attachment.
- Server not executable: launch Neovim from a login zsh and check
  `command -v typescript-language-server`; installing only `tsserver` is
  insufficient.
- Missing or stale parsing: run the repository checker; it verifies all four
  required Tree-sitter parsers and active highlighting for all four filetypes.
- Formatting surprises: run `:ConformInfo`. Save requires a local executable;
  `,fm` may deliberately use global Prettier.
- Missing ESLint diagnostics: save-time lint needs both a local executable and
  config. Run `,ll` for explicit feedback. Disabling automatic lint also clears
  the current buffer's ESLint diagnostics, not its `ts_ls` diagnostics.
- `gh` does nothing / no hover: no LSP buffer-local mapping has attached;
  confirm with `:LspInfo`. `K` is always project-wide `ag` search.
- Copilot is absent: run `:Copilot status`; do not use setup or sign-out as a
  health check.

## Verification checklist for both Macs

Repeat this checklist locally on `andrews-mac-mini` and
`qianas-macbook-pro`:

1. From `~/dotfiles`, run
   `zsh -lic 'bin/check-nvim-typescript-support'` and require the final `PASS`.
2. Open representative `.ts` and `.tsx` project files; confirm their filetypes,
   Tree-sitter highlighting, and exactly one `ts_ls` in `:LspInfo`. Spot-check
   `.js` and `.jsx` attachment too.
3. Exercise `gd`, `gh`, `grr`, `gri`, `grt`, `grn`, `gra`, `[d`/`]d`, both
   TypeScript commands, and the `,ih` off/on/off cycle.
4. Confirm LSP completion with `Ctrl+N`/`Ctrl+P`/`Ctrl+Y`, then separately check
   `:Copilot status` and accept an inline suggestion with `Tab`.
5. Confirm local Prettier formats via save and `,fm`; confirm configured local
   ESLint publishes and clears diagnostics after saves. Verify global-only tools
   run only through the explicit mappings and an ordinary save performs no
   source actions.
