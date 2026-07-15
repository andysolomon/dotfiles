# Neovim TypeScript Support Implementation Plan

**Work item:** `nvim-typescript-support` (standalone request; no tracked issue)
**Mode:** Gap plan — the repository already provides TypeScript filetype/syntax support, but the semantic editing path is not configured.
**Status:** Complete — implementation merged in PR #11, released as v1.4.0, and this plan plus its progress tracker were archived together.
**Suggested branch:** `feat/v1.4.0-neovim-typescript-support`
**Plan date:** 2026-07-14
**Decision records:** [`ADR 0001`](../decisions/0001-require-neovim-0.12-for-typescript-support.md), [`ADR 0002`](../decisions/0002-provision-typescript-tools-outside-neovim.md), [`ADR 0003`](../decisions/0003-support-javascript-alongside-typescript.md), [`ADR 0004`](../decisions/0004-use-ts-ls-language-server.md), [`ADR 0005`](../decisions/0005-use-native-lsp-completion-and-preserve-copilot.md), [`ADR 0006`](../decisions/0006-format-on-save-with-project-local-prettier.md), [`ADR 0007`](../decisions/0007-lint-on-save-with-project-local-eslint.md), [`ADR 0008`](../decisions/0008-configure-inlay-hints-with-an-off-by-default-toggle.md), [`ADR 0009`](../decisions/0009-keep-typescript-source-actions-explicit.md), [`ADR 0010`](../decisions/0010-use-balanced-diagnostic-presentation.md), [`ADR 0011`](../decisions/0011-replace-legacy-typescript-syntax-with-tree-sitter.md), [`ADR 0012`](../decisions/0012-use-native-first-keybindings.md), [`ADR 0013`](../decisions/0013-limit-scope-to-standard-js-ts-and-react-tsx.md), [`ADR 0014`](../decisions/0014-validate-with-fixtures-and-real-projects-on-both-macs.md), [`ADR 0015`](../decisions/0015-use-the-macbook-nvm-environment-for-verification.md), [`ADR 0016`](../decisions/0016-fail-fast-on-unsupported-neovim.md), [`ADR 0017`](../decisions/0017-pin-the-typescript-neovim-stack.md), [`ADR 0018`](../decisions/0018-use-nvm-for-node-based-editor-tools.md), [`ADR 0019`](../decisions/0019-do-not-symlink-repository-docs-to-home.md)
**Glossary:** [`nvim-typescript-support-GLOSSARY.md`](../nvim-typescript-support-GLOSSARY.md)
**Wayfinder outcome:** Decision-complete in this planning session; no issue-tracker decision map is required.

## 1. Product goal and scope boundaries

### Product goal

Make `.ts` and `.tsx` buffers provide a dependable, project-aware Neovim experience, with the same tooling intentionally available to `.js` and `.jsx` buffers in mixed projects:

- Tree-sitter highlighting for TypeScript, TSX, JavaScript, and JSX.
- TypeScript language-server attachment with type diagnostics, definition/reference navigation, hover, rename, code actions, import organization, and source-definition navigation.
- Real LSP completion without replacing Copilot's existing `Tab` behavior, plus explicit Copilot health/coexistence verification.
- Prettier formatting and ESLint diagnostics that prefer each project's local tools and configuration.
- Accurate setup, keybinding, health-check, and troubleshooting documentation.

### In scope

- Keep the current Vimscript split, `vim-plug`, and Neovim-first architecture.
- Require a supported Neovim/toolchain baseline and document how to install it.
- Consolidate the LSP declarations around one `neovim/nvim-lspconfig` entry.
- Use Neovim's current `vim.lsp.config`/`vim.lsp.enable` API and native LSP completion.
- Add `nvim-treesitter`, `conform.nvim`, and `nvim-lint` for parsing, formatting, and linting.
- Add focused automated smoke coverage plus manual QA in a representative TypeScript project.
- Update the generated plugin inventory through its generator, never by hand.

### Scope boundaries

- Do not replace `vim-plug`, migrate the whole configuration to Lua, or restructure unrelated editor settings.
- Do not add `nvim-cmp`: native Neovim completion is sufficient for this scope and avoids a new completion stack/Copilot `Tab` conflict.
- Do not add Mason or another tool installer. Remove the legacy installers and document external prerequisites instead.
- Do not install or modify dependencies in users' TypeScript projects. Prefer project-local TypeScript, Prettier, and ESLint when they already exist; use documented global fallbacks only when needed.
- Enable format-on-save only when the current buffer can resolve an executable project-local `node_modules/.bin/prettier`. Never use global Prettier or `ts_ls` as an automatic-save fallback.
- Run ESLint automatically after save only when the buffer resolves project-local `node_modules/.bin/eslint` and a flat/legacy ESLint config; global ESLint is explicit-only and unconfigured projects remain quiet.
- Support standard Node/browser JS/TS, JSX, and React-style TSX only. Defer Deno, Vue, Svelte, Astro, Angular, framework-specific TypeScript plugins, snippets, Telescope integration, and plain Vim compatibility.
- Preserve all unrelated behavior and the pre-existing uncommitted `zshrc` change; implementation must not touch `zshrc`.
- Treat the Mac mini and MacBook Pro as supported targets, but do not SSH to or mutate the other machine without explicit authorization.
- Keep the top-level `docs/` planning directory repository-local; `install.sh` must not create `~/.docs`, while all other top-level symlink behavior and skip rules remain unchanged.

## 2. Architectural decisions

1. **Target Neovim 0.12 or newer (confirmed).** The machine currently has Neovim 0.11.1. The installed `nvim-lspconfig` checkout requires Neovim 0.11.3+, while the current `nvim-treesitter` main branch requires Neovim 0.12+, `tree-sitter` CLI 0.26.1+, `curl`, `tar`, and a C compiler. One Neovim 0.12 baseline satisfies both plugin families. See [ADR 0001](../decisions/0001-require-neovim-0.12-for-typescript-support.md).
2. **Use only `ts_ls`, not raw `tsserver` or an alternative server (confirmed).** `ts_ls` launches `typescript-language-server --stdio`, which wraps `tsserver`. The currently available `/opt/homebrew/bin/tsserver` is not itself an LSP server, and `typescript-language-server` is currently absent. Do not also enable `vtsls` or `typescript-tools.nvim`. See [ADR 0004](../decisions/0004-use-ts-ls-language-server.md).
3. **Let the workspace select TypeScript.** Keep the pinned `nvim-lspconfig` `ts_ls` root/monorepo behavior: the nearest package-manager lockfile or `.git` root starts the server, and Neovim's process cwd is the fallback. This lets the adapter use a project's local TypeScript version when available; do not hard-code the Homebrew `tsserver` path.
4. **Use native LSP completion and preserve Copilot (confirmed).** Enable `vim.lsp.completion` on `LspAttach`, set completion-menu options, and retain `Ctrl-N`/`Ctrl-P` plus `Ctrl-Y` acceptance. Do not map `Tab`, so Copilot continues to own its existing acceptance path. Verify Copilot independently in headless and interactive modes. See [ADR 0005](../decisions/0005-use-native-lsp-completion-and-preserve-copilot.md).
5. **Use native-first, buffer-local LSP mappings (confirmed).** Explicitly map `gd` and `K` in attached buffers, retain Neovim's `grn`, `gra`, `grr`, and `gri`, and use `[d`/`]d`, `<leader>fm`, `<leader>ll`, and `<leader>ih` for diagnostics and explicit tool actions. `K` remains grep outside attached buffers; do not map bare `gr` or add redundant leader aliases. See [ADR 0012](../decisions/0012-use-native-first-keybindings.md).
6. **Use only the current Tree-sitter main API for TS/TSX (confirmed).** Pin the plugin declaration to `branch: main`, which targets Neovim 0.12+, install the `javascript`, `jsdoc`, `typescript`, and `tsx` parsers with `require('nvim-treesitter').install(...):wait(...)`, and start Tree-sitter for `javascript`, `javascriptreact`, `typescript`, and `typescriptreact`. After verification, remove the legacy TypeScript and inactive TSX declarations rather than maintaining fallback highlighting. See [ADR 0011](../decisions/0011-replace-legacy-typescript-syntax-with-tree-sitter.md).
7. **Separate semantic, lint, and format responsibilities.** `ts_ls` provides type semantics; `nvim-lint` runs ESLint; `conform.nvim` formats with Prettier. Conform must search upward from the buffer directory for `node_modules/.bin/prettier`: automatic formatting is allowed whenever that local binary exists, while explicit `<leader>fm` may fall back to global Prettier. ESLint must search upward for both `node_modules/.bin/eslint` and a flat/legacy config (`eslint.config.*`, `.eslintrc*`, or `package.json` `eslintConfig`): automatic post-save linting is allowed only when both exist, while an explicit lint action may report missing config or fall back to global `eslint`. Both tools execute with the nearest relevant config/package root as `cwd`. See [ADR 0006](../decisions/0006-format-on-save-with-project-local-prettier.md) and [ADR 0007](../decisions/0007-lint-on-save-with-project-local-eslint.md).
8. **Fail visibly and diagnostically.** Missing external tools must be discoverable through startup/health documentation and the smoke checker rather than silently leaving the cheatsheet's LSP commands unusable.
9. **Provision tools outside Neovim (confirmed).** Remove the obsolete LSP installers without adding Mason. Use Homebrew formulas `neovim`/`tree-sitter-cli` and npm under the active NVM default for global TypeScript 5.9.3, `typescript-language-server`, Prettier, and ESLint on both Macs, while preferring project-local tools. TypeScript 5.9.3 is the compatible global fallback because the current TypeScript 7 package lacks `lib/tsserver.js`. See [ADR 0002](../decisions/0002-provision-typescript-tools-outside-neovim.md) and [ADR 0018](../decisions/0018-use-nvm-for-node-based-editor-tools.md).
10. **Support mixed JavaScript/TypeScript projects (confirmed).** TypeScript/TSX remain the primary acceptance target, but preserve the upstream server filetype list and configure parsing, formatting, and linting for JavaScript/JSX too. See [ADR 0003](../decisions/0003-support-javascript-alongside-typescript.md).
11. **Offer inlay hints on demand (confirmed).** Configure TypeScript and JavaScript hint preferences, leave display off by default, and add a buffer-local toggle using Neovim's built-in inlay-hint API on the selected 0.12+ baseline. See [ADR 0008](../decisions/0008-configure-inlay-hints-with-an-off-by-default-toggle.md).
12. **Keep TypeScript source actions explicit (confirmed).** Expose code actions and `:LspTypescriptSourceAction`, but never organize imports or apply TypeScript fix-all from a save autocmd. See [ADR 0009](../decisions/0009-keep-typescript-source-actions-explicit.md).
13. **Use balanced diagnostics (confirmed).** Show signs/underlines for warnings and errors, inline virtual text only for errors, severity sorting, a bordered details float, and ASCII-safe signs. See [ADR 0010](../decisions/0010-use-balanced-diagnostic-presentation.md).
14. **Limit ecosystem scope (confirmed).** Support standard Node/browser JS/TS, JSX, and React-style TSX; retain upstream Deno exclusion and add no framework-specific servers. See [ADR 0013](../decisions/0013-limit-scope-to-standard-js-ts-and-react-tsx.md).
15. **Validate fixtures and real projects on both Macs (confirmed).** Run automated/headless checks and interactive project-local QA independently in `~/Documents/Github/sprtsmng` on the Mac mini and `~/draft/draftMachine` on the MacBook Pro. See [ADR 0014](../decisions/0014-validate-with-fixtures-and-real-projects-on-both-macs.md).
16. **Use the MacBook's working NVM login-shell environment (confirmed).** Remote/headless checks must resolve and report tools through interactive zsh/NVM; repairing broken `/usr/local/bin/node` and hard-coding an NVM path are out of scope. See [ADR 0015](../decisions/0015-use-the-macbook-nvm-environment-for-verification.md).
17. **Fail installation fast on unsupported Neovim (confirmed).** Before plugin/parser changes, `install.sh` must require Neovim 0.12+, fail with external upgrade guidance otherwise, and remove the misleading plain-Vim fallback. See [ADR 0016](../decisions/0016-fail-fast-on-unsupported-neovim.md).
18. **Pin the TypeScript plugin stack (confirmed).** Pin `nvim-lspconfig`, current-main `nvim-treesitter`, Conform, and `nvim-lint` to exact commits that pass the complete suite; advance them only through explicit maintenance validation. See [ADR 0017](../decisions/0017-pin-the-typescript-neovim-stack.md).
19. **Use NVM for Node-based editor tools on both Macs (confirmed).** Use Node 24 LTS as the NVM default and install global TypeScript 5.9.3, `typescript-language-server`, Prettier, and ESLint under it; never hard-code a Node-version path, and report resolved paths in verification. See [ADR 0018](../decisions/0018-use-nvm-for-node-based-editor-tools.md).
20. **Do not symlink repository docs into `$HOME` (confirmed).** Treat top-level `docs/` as repository planning and decision-record content, not user dotfile configuration. `install.sh` must skip `docs/` without changing the Neovim preflight, plugin/parser commands, or ordinary top-level symlinks. See [ADR 0019](../decisions/0019-do-not-symlink-repository-docs-to-home.md).

## 3. Current baseline

Repository evidence:

- `vimrc` sources `vimrc.bundles`, `vimrc.global`, `vimrc.plugins`, `vimrc.macros`, and `vimrc.local`; Neovim sources this Vim configuration through `~/.config/nvim/init.vim`.
- `vimrc.bundles` enables `leafgarland/typescript-vim`, declares `neovim/nvim-lspconfig` twice, and also enables the obsolete `kabouzeid/nvim-lspinstall`, `neovim/nvim-lsp`, and `williamboman/nvim-lsp-installer` plugins.
- `vimrc.bundles` leaves `peitalin/vim-jsx-typescript`, `nvim-treesitter`, `vim-prettier`, and ALE inactive.
- `vimrc.plugins` contains no LSP, Tree-sitter, formatter, or lint setup.
- `vimrc.local` assigns `typescriptcomplete#Complete` to `typescript,tx,tsx`; `tx` is a typo and this legacy omnifunc is not semantic LSP completion.
- `vimrc.global` globally maps `K` to grep. `CHEATSHEET.md` instead describes `K` as LSP hover and presents other LSP actions without stating that they require an attached server.
- `PLUGIN_INVENTORY.md` is generated by `bin/generate-vim-plugin-inventory`; any added plugins need descriptions in that generator before regeneration.
- The repository has no editor test suite. Validation currently means sourcing the config and manually checking behavior.

Observed machine baseline on 2026-07-14:

- Neovim: 0.11.1; current Homebrew stable reported as 0.12.4.
- Installed `nvim-lspconfig` checkout: `cb5bc0b` (2026-04-10), whose README requires Neovim 0.11.3+.
- `tsserver`: present at `/opt/homebrew/bin/tsserver`.
- `typescript-language-server`: absent.
- `prettier`: absent from `PATH`.
- `eslint`: absent from `PATH`.
- `tree-sitter`: 0.25.4, below the current `nvim-treesitter` requirement of 0.26.1.
- C compiler: present.

Observed MacBook baseline from an authorized read-only Tailscale SSH inspection on 2026-07-14:

- Host: `Qianas-MacBook-Pro.local` / `qianas-macbook-pro-1`, Intel `x86_64`, Homebrew prefix `/usr/local`.
- Neovim: 0.9.5; Tree-sitter CLI: 0.20.8.
- `typescript-language-server`, global `tsserver`, Prettier, and ESLint: absent from the interactive shell `PATH`.
- Loading the current config headlessly emits an `nvim-lspconfig` error (`vim.uv` unavailable) because the Neovim version is unsupported.
- Interactive zsh/NVM provides working Node 24.15.0; non-interactive `/usr/local/bin/node` is broken by a missing ICU dylib, so remote verification must deliberately use the intended shell environment.
- Copilot command/`Tab` mapping load and headless `:Copilot status` reports ready despite the unrelated LSP startup error.
- `~/draft/draftMachine` contains TS/TSX, `tsconfig.json`, and local TypeScript 5.3.3, Prettier 3.3.3, and ESLint 8.57.1. ESLint has no discoverable config and fails an stdin probe; ADR 0007 resolves this by skipping automatic lint quietly and testing publish/clear in a disposable configured fixture.

## 4. Missing capabilities

| Capability | Baseline | Target outcome |
| --- | --- | --- |
| Supported runtime | Neovim 0.11.1 is below current plugin requirements | Neovim 0.12+ and Tree-sitter CLI 0.26.1+ are documented and verified |
| TypeScript LSP transport | Only raw `tsserver` is present | `typescript-language-server` launches through `ts_ls` |
| LSP attachment | No config is enabled | `ts_ls` attaches automatically to TS/TSX project buffers |
| Diagnostics | No TypeScript semantic diagnostics | Type errors appear through `vim.diagnostic`; ESLint adds project lint findings |
| Navigation/refactor | Cheatsheet advertises actions without an attached server | Definition, references, implementation, hover, rename, code actions, imports, and source definition work and are documented |
| Completion | Legacy TypeScript omnifunc | Native LSP completion auto-triggers and remains compatible with Copilot |
| TSX parsing | Legacy TS syntax only; TSX plugin inactive | Tree-sitter parses and highlights TS/TSX and JSX constructs |
| Formatting | Prettier integration inactive | Explicit project-aware Prettier formatting via Conform |
| Linting | ALE inactive | Project-aware ESLint runs after save via `nvim-lint` |
| Regression checks | Manual sourcing only | Repeatable headless smoke checker plus documented manual QA |
| Documentation | LSP behavior is overstated and prerequisites are missing | README/CHEATSHEET state prerequisites, attachment checks, mappings, and fallback behavior accurately |

## 5. Milestones / phases

## Phase 1 - Establish the supported runtime and external tool contract

### Goal

Remove version ambiguity before enabling plugins that cannot run on the current machine baseline.

### Deliverables

- Update `README.md` requirements and TypeScript setup notes to require:
  - Neovim 0.12+.
  - `tree-sitter` CLI 0.26.1+, `curl`, `tar`, and a C compiler.
  - `typescript-language-server` plus the compatible TypeScript 5.9.3 global fallback installed through npm under the active NVM default; explain that `tsserver` alone is insufficient and TypeScript 7 currently lacks the required server module.
  - Global Prettier and ESLint installed under the NVM default as explicit fallbacks, with project-local tools preferred for project behavior.
- Document architecture-neutral `brew install neovim tree-sitter-cli`, `nvm install 24`, and `npm install -g typescript@5.9.3 typescript-language-server prettier eslint` under the Node 24 NVM default on both Macs. `install.sh` must not mutate global package state; resolve Homebrew, NVM, and tool paths dynamically.
- Upgrade Homebrew-managed Neovim and Tree-sitter CLI, then install the Node-based tools through npm under each machine's active NVM default before validating later phases.
- Add an `install.sh` preflight that requires Neovim 0.12+ before any plugin/parser command, exits non-zero with architecture-neutral upgrade guidance on failure, and removes the plain-Vim fallback without installing tools automatically.
- Keep the top-level `docs/` planning directory out of `$HOME` by making `install.sh` skip `docs/`, while preserving all other top-level symlink behavior.
- Add a clear health-check command set: `nvim --version`, `tree-sitter --version`, `command -v typescript-language-server`, `:checkhealth vim.lsp`, and `:LspInfo`.
- Document the same prerequisite and verification flow for `andrews-mac-mini-1` and `qianas-macbook-pro-1`; use Tailscale hostnames in any optional remote-verification instructions.

### Dependencies

- Homebrew or another package manager capable of supplying supported versions.
- A Node/npm toolchain only if the npm installation route is chosen.

### Risks

- NVM global packages are scoped to a Node installation and may disappear when the default changes. Document reinstall/verification after NVM upgrades. All checks must load the active NVM default; on the MacBook this also avoids the broken non-interactive Homebrew Node.
- Updating Neovim can expose unrelated deprecated configuration. Capture any startup errors, but keep fixes limited to blockers for this plan.

### Acceptance criteria

- `nvim --version` reports 0.12 or newer.
- `tree-sitter --version` reports 0.26.1 or newer.
- `typescript-language-server --version` exits successfully and the executable is on Neovim's `PATH`.
- README explicitly distinguishes `typescript-language-server`/`ts_ls` from raw `tsserver`.
- `nvim --headless -u ~/.vimrc +qa` exits successfully before plugin changes continue.
- Installer tests prove missing/old Neovim fails before plugin/parser execution and supported Neovim proceeds.
- Installer tests prove supported installation does not create `~/.docs`, still symlinks another ordinary top-level entry, and still invokes vim-plug plus the bounded parser install.
- Before shipping, the minimum-version and executable checks pass independently on both supported Macs, with remote access performed only when explicitly authorized.

## Phase 2 - Consolidate plugins and enable Tree-sitter parsing

### Goal

Replace redundant/stale TypeScript and LSP declarations with a small, supported plugin set and dependable TSX parsing.

### Deliverables

- In `vimrc.bundles`:
  - Keep exactly one `neovim/nvim-lspconfig` declaration and pin it to the exact commit selected by implementation verification.
  - Remove `kabouzeid/nvim-lspinstall`, `neovim/nvim-lsp`, and `williamboman/nvim-lsp-installer`.
  - Enable `nvim-treesitter/nvim-treesitter` on its `main` branch with its `:TSUpdate` post-update hook, no lazy-loading, and an exact tested commit pin.
  - Add `stevearc/conform.nvim` and `mfussenegger/nvim-lint`, each pinned to an exact tested commit.
  - Remove `leafgarland/typescript-vim` and the inactive `peitalin/vim-jsx-typescript` declaration after native filetype detection and Tree-sitter smoke checks pass.
  - Collapse the duplicate `pangloss/vim-javascript` declarations to one entry; do not otherwise change JavaScript behavior in this phase.
- In `vimrc.plugins`, configure Tree-sitter with the current API and start it only for the four JS/TS filetypes in scope.
- In `install.sh`, after plugin installation, synchronously install the four parsers with the equivalent of `nvim --headless -u ~/.vimrc.bundles "+lua require('nvim-treesitter').install({'javascript','jsdoc','typescript','tsx'}):wait(300000)" +qa`. Keep repeated installer runs idempotent; plugin upgrades continue to run `:TSUpdate` through the vim-plug hook.
- Add descriptions for Conform and `nvim-lint` in `bin/generate-vim-plugin-inventory`, then regenerate `PLUGIN_INVENTORY.md`.

### Dependencies

- Phase 1 runtime and Tree-sitter CLI requirements.
- Network access during initial plugin/parser installation.

### Risks

- `nvim-treesitter` main is an incompatible rewrite and requires Neovim 0.12. Implement against the README shipped by the installed checkout rather than copying legacy `require('nvim-treesitter.configs').setup` examples.
- Removing legacy syntax plugins too early can leave TS/TSX unhighlighted if parsers were not installed. Perform parser/filetype verification before `PlugClean!`.
- `install.sh` currently has a plain-Vim fallback even though the repository is Neovim-first. Remove it under the Phase 1 fail-fast preflight; Phase 2 may assume a supported `nvim` exists.

### Acceptance criteria

- `vimrc.bundles` has one LSP config plugin and none of the three obsolete LSP/install plugins; all four selected TypeScript-stack plugins declare the exact commits verified on both Macs.
- `:checkhealth nvim-treesitter` succeeds, and `require('nvim-treesitter').get_installed()` contains `javascript`, `jsdoc`, `typescript`, and `tsx`.
- Opening `.ts` reports `filetype=typescript`; opening `.tsx` reports `filetype=typescriptreact`.
- `vim.treesitter.highlighter.active[bufnr]` is present for both TS and TSX smoke buffers.
- TSX elements, TypeScript types/generics, and embedded JavaScript expressions highlight without the legacy TypeScript/TSX syntax plugins.
- Running `bin/generate-vim-plugin-inventory` produces no uncommitted inventory delta.

## Phase 3 - Enable TypeScript LSP, diagnostics, navigation, and completion

### Goal

Make semantic TypeScript editing attach automatically and expose a coherent, truthful interaction model.

### Deliverables

- In the Neovim-only Lua block in `vimrc.plugins`:
  - Enable `ts_ls` through `vim.lsp.enable('ts_ls')`; do not use deprecated `require('lspconfig').ts_ls.setup(...)`.
  - Add one named `LspAttach` augroup that enables native completion only when the client advertises completion support.
  - Use `completeopt=menu,menuone,noselect,popup` (or the Neovim-0.12 equivalent validated against `:help completeopt`).
  - Add buffer-local mappings with descriptions for `gd` (definition), `K` (hover), `[d`/`]d` (diagnostics), `<leader>fm` (explicit format), `<leader>ll` (explicit lint), and `<leader>ih` (inlay hints).
  - Retain and document Neovim's built-in `grn`, `gra`, `grr`, and `gri` mappings; do not map bare `gr` or add duplicate leader aliases for rename/code actions.
  - Configure balanced diagnostics: signs and underlines for warnings/errors, virtual text only for errors, severity ordering, a bordered details float, previous/next navigation, and ASCII-safe signs.
  - Configure TypeScript and JavaScript inlay-hint preferences, keep hints disabled initially, and add a documented buffer-local toggle using the built-in API on the selected Neovim 0.12+ baseline.
- Remove only the TypeScript/TSX `typescriptcomplete#Complete` autocmd from `vimrc.local`, including the `tx` typo; preserve the HTML, CSS, and JavaScript omnifunc entries.
- Expose and document the `nvim-lspconfig` TypeScript commands `:LspTypescriptSourceAction` and `:LspTypescriptGoToSourceDefinition` when `ts_ls` is attached. All organize-imports, add/remove-imports, and fix-all actions remain explicit; no save autocmd may invoke them.
- Ensure `K` remains the existing grep command in buffers without an attached LSP and becomes hover in attached TypeScript buffers.

### Dependencies

- Phase 1 `typescript-language-server` executable.
- Phase 2's single compatible `nvim-lspconfig` declaration.
- A TypeScript project with a package-manager lockfile or Git root and preferably `tsconfig.json` for realistic validation.

### Risks

- Native completion and Copilot may both display suggestions. Avoid any `Tab` mapping changes; validate `Ctrl-N`/`Ctrl-P`/`Ctrl-Y` for LSP completion and `Tab` for Copilot independently.
- The current standard `ts_ls` root logic intentionally avoids Deno roots. Deno behavior remains out of scope and must not be overridden.
- The config sources some split files more than once today. Use named augroups and clear them before defining autocmds so re-sourcing does not duplicate callbacks; do not restructure the source chain in this plan.

### Acceptance criteria

- `:LspInfo` shows one `ts_ls` client attached to representative `.ts`, `.tsx`, `.js`, and `.jsx` buffers.
- The attached client command is `typescript-language-server --stdio`; no process attempts to launch raw `tsserver` as an LSP.
- An intentional type error shows an ASCII-safe sign, underline, and inline error text; an intentional warning shows a sign/underline but no inline virtual text. Both can be navigated and inspected in the bordered float.
- `gd`, `grr`, `gri`, `K`, `grn`, and `gra` perform the documented semantic actions where supported.
- Rename updates references across files; explicit source actions can organize imports or add/remove imports in a disposable fixture, while an ordinary save performs none of those semantic edits.
- LSP completion offers project symbols and members, accepts with `Ctrl-Y`, and does not replace Copilot's `Tab` mapping.
- In a TypeScript buffer, `:Copilot status` reports ready, `Tab` still resolves through `copilot#Accept()`, and an interactive inline suggestion can be rendered and accepted.
- Inlay hints start disabled, appear only in the current buffer after the toggle, and disappear after toggling again in representative TypeScript and TSX buffers.
- Non-LSP buffers retain the global `K` grep behavior.

## Phase 4 - Add project-aware Prettier formatting and ESLint linting

### Goal

Provide deterministic formatting and lint feedback without forcing tools or policies into projects that do not use them.

### Deliverables

- Configure `conform.nvim` in `vimrc.plugins` for `typescript`, `typescriptreact`, `javascript`, and `javascriptreact`:
  - Start from Conform's built-in `prettier` formatter, whose `util.from_node_modules` command searches upward from the current buffer directory for `node_modules/.bin/prettier` before falling back to `prettier` on `PATH`.
  - Override the formatter `cwd`: when a local binary is found, derive the owning project root by stripping `/node_modules/.bin/prettier` from that nearest executable path; when explicit formatting uses only global Prettier, use the buffer's directory. Do not rely on Conform's config-only built-in Prettier `cwd` or Neovim's process `cwd`.
  - Add a documented `<leader>fm` buffer-safe format mapping and `:ConformInfo` troubleshooting path; this explicit path may fall back to global Prettier.
  - Configure format-on-save as a function that returns formatting options whenever an executable `node_modules/.bin/prettier` is found upward from the buffer directory. The binary alone is sufficient—no config/direct-dependency marker is required—and save must not fall back to global Prettier or LSP formatting.
- Configure `nvim-lint` for the same filetypes using ESLint:
  - Search upward from the buffer's directory for `node_modules/.bin/eslint` and a flat/legacy config (`eslint.config.*`, `.eslintrc*`, or a `package.json` `eslintConfig` key); do not rely on Neovim having been launched from the package root.
  - Use the nearest discovered config root as lint `cwd` and pass it to `try_lint`.
  - Run automatically after successful writes only when both the project-local executable and config exist, using a named augroup; otherwise skip quietly. Avoid duplicate autocmds after re-sourcing and do not lint on `InsertLeave`.
  - Add a documented explicit lint user command/mapping that prefers local ESLint and may fall back to global `eslint`.
  - Document a per-buffer/project disable path for untrusted repositories.
  - Keep TypeScript LSP diagnostics and ESLint diagnostics as separate namespaces visible through `vim.diagnostic`.
- Handle missing formatter/linter executables without startup errors. The explicit format action should report an actionable message; lint should not emit repeated command-not-found noise.
- Do not configure `ts_ls` as the primary formatter and do not enable both ALE and `nvim-lint`.

### Dependencies

- Conform and `nvim-lint` from Phase 2.
- A representative project with local Prettier, ESLint, and TypeScript parser/config packages for end-to-end validation.

### Risks

- ESLint 9/10 flat-config projects and legacy `.eslintrc` projects resolve configuration differently. Validate one real project of each style if both are used; otherwise document the untested style as unknown.
- Automatically running a project-local executable trusts that project. Limit automatic execution to normal development repositories and document how to disable linting locally for untrusted checkouts.
- Prettier can create large diffs. A discoverable local binary is the confirmed opt-in boundary; verify that the custom resolver selects the nearest executable and its owning project root, especially in nested monorepo packages.

### Acceptance criteria

- In a project with local Prettier, saving and `<leader>fm` format TS/TSX/JS/JSX according to that project's config, and `:ConformInfo` identifies the local executable.
- In a trusted project with configured local ESLint, saving a file publishes an intentional lint violation and clearing the violation removes the diagnostic.
- With local ESLint but no config (including `~/draft/draftMachine`), saving skips lint quietly and explicit lint reports the missing config clearly.
- With only global ESLint available, saving does not lint, while the explicit lint action can use the global fallback.
- With only global Prettier available, saving does not format, while explicit `<leader>fm` can use the global fallback.
- In a project without Prettier/ESLint, Neovim starts and edits normally; missing tools produce no startup exception or automatic file change.
- TypeScript type diagnostics remain present alongside ESLint diagnostics, with no duplicate ALE diagnostics.

## Phase 5 - Add repeatable verification and align user documentation

### Goal

Prevent the configuration from returning to a state where plugins are declared and cheatsheet features are advertised but no server attaches.

### Deliverables

- Add `bin/check-nvim-typescript-support`, a zsh/bash-compatible smoke checker that:
  - Validates minimum Neovim and Tree-sitter CLI versions plus required executables.
  - Asserts that the Copilot command/function load, `Tab` still maps through `copilot#Accept()`, and non-mutating headless `:Copilot status` reports ready; it must never invoke setup/signout or print authentication data.
  - Creates a disposable TS/TSX fixture outside the repository.
  - Starts Neovim headlessly with the deployed dotfiles, waits with a bounded timeout, and asserts TypeScript filetype detection, an active Tree-sitter highlighter, one attached `ts_ls` client, completion capability, and an intentional type diagnostic.
  - Cleans up its fixture and returns non-zero with an actionable failed check.
- Update `CHEATSHEET.md` with the final completion, LSP, diagnostic, TypeScript source-action, format, lint, and health-check commands. State clearly that semantic mappings require an attached client.
- Expand `README.md` troubleshooting for missing `typescript-language-server`, unsupported Neovim/Tree-sitter versions, missing project roots, unavailable parsers, and missing project format/lint tools.
- Run all static and interactive checks listed below.

### Dependencies

- Phases 1–4 complete.
- A real TS/TSX repository for manual project-local formatter/linter checks.

### Risks

- Headless LSP startup is asynchronous. The checker must use a bounded wait and report client/log state on timeout rather than relying on arbitrary sleeps.
- Cross-machine SSH checks must run in each machine's intended shell environment and report the resolved Node/Neovim paths; otherwise the MacBook's stale non-interactive Node can create a false failure.
- NERDTree's `VimEnter` autocmd can change the current headless buffer. The checker must locate the fixture buffer explicitly rather than assume buffer 0 is the TS buffer.

### Acceptance criteria

- `bin/check-nvim-typescript-support` passes on the configured machine and fails clearly when `typescript-language-server` is intentionally hidden from `PATH`.
- `nvim --headless -u ~/.vimrc +qa` exits zero with no Lua/Vimscript errors.
- `bin/generate-vim-plugin-inventory` is reproducible and `git diff --check` passes.
- README and CHEATSHEET mapping names match the actual buffer-local/default mappings.
- Manual QA passes deeply in `.ts` and `.tsx` files for diagnostics, completion, navigation, rename, imports, formatting, linting, and Copilot coexistence; focused `.js` and `.jsx` checks confirm attachment and no regressions.
- The smoke checker and real-project interactive QA pass independently on both supported Macs; an unverified machine remains a shipping blocker.

## Phase 6 - Ship and archive the in-flight plan

### Goal

Review and land the focused change without including unrelated dotfile edits, then archive planning artifacts.

### Deliverables

- Review the final diff for scope, plugin redundancy, generated-file correctness, and accidental `zshrc` inclusion.
- Re-run the full verification matrix after a clean plugin install/update and parser bootstrap.
- Prepare a focused shipping handoff. Open a PR or perform any GitHub/merge action only if the user explicitly requests and authorizes it.
- If/when the shipping change merges, move this plan and `docs/nvim-typescript-support-progress.txt` to `docs/archive/` together; otherwise leave both files in `docs/` as in-flight artifacts.

### Dependencies

- Phases 1–5 accepted.

### Risks

- `PlugClean!` is destructive to disabled plugin directories. Run it only after the replacement stack passes and review its target list before confirming.
- The working tree already contains an unrelated `zshrc` modification; staging must be path-scoped.

### Acceptance criteria

- Final diff contains only TypeScript-support implementation, generated inventory/docs changes, and these planning artifacts.
- Clean install/update produces the documented pinned plugin commits on both Macs, and smoke/manual checks pass.
- No unrelated `zshrc` change is staged or shipped.
- If the change has merged, both synchronized artifacts reside in `docs/archive/` and no in-flight copy remains in `docs/`; otherwise the archive step remains unchecked.

## 6. Test strategy

### Automated/static checks

- `nvim --headless -u ~/.vimrc +qa`
- `nvim --headless -u ~/.vimrc <fixture.ts> '+Copilot status' +qa` (expect `Copilot: Ready` without invoking setup)
- `bin/check-nvim-typescript-support`
- `bin/generate-vim-plugin-inventory`
- `git diff --check`
- Fake-home installer tests for missing, old, and supported Neovim, including no preflight HOME mutation, no supported `~/.docs` creation, ordinary top-level symlink preservation, and vim-plug/parser command invocation.
- Confirm regeneration is clean: `git diff --exit-code -- PLUGIN_INVENTORY.md` after the generator has been run and its intended update is staged/committed.

### Disposable fixture checks

Use a temporary project containing a lockfile, `tsconfig.json`, `.ts`, and `.tsx` files with:

- A cross-file symbol for definition/references/rename.
- A deliberate assignability error for TypeScript diagnostics.
- A missing/unused import for source actions.
- JSX syntax for parser/highlighting checks.
- A completion site for object members and imported symbols.

### Real-project manual QA

On each supported Mac, use at least one recorded representative project with local TypeScript, Prettier, and ESLint:

- Mac mini: `~/Documents/Github/sprtsmng`; use `apps/web` for primary TSX/Next.js QA and `apps/tui` for an additional TypeScript package. This is a pnpm monorepo with package-level `tsconfig.json` and ESLint flat configs. Its root Prettier binary is sufficient to opt into format-on-save even without a direct root dependency or style config; QA must report the selected executable/version.
- MacBook Pro: `~/draft/draftMachine`; initial files are `src/app/_components/sidenav.tsx` and `tailwind.config.ts`. Local TypeScript/Prettier work; local ESLint lacks config, so real-project saves must skip lint quietly and a disposable configured fixture covers diagnostic publish/clear without modifying the project.

1. Verify `:set filetype?`, `:LspInfo`, and `:checkhealth vim.lsp`.
2. Exercise `gd`, `grr`, `gri`, `K`, `grn`, `gra`, explicit source actions, source definition, diagnostic navigation, and the off/on/off buffer-local inlay-hint toggle; confirm ordinary save does not organize imports or apply fix-all.
3. Confirm native completion with `Ctrl-N`/`Ctrl-P`/`Ctrl-Y`; separately confirm `:Copilot status`, inline suggestion rendering, and Copilot acceptance with `Tab`.
4. Confirm a project-local Prettier formats on save and through `<leader>fm`; then hide the local binary and confirm global-only Prettier is explicit-only and ordinary save makes no formatting change.
5. In a disposable trusted fixture with configured local ESLint, save a violation, verify publish/clear, then test global-only explicit behavior. In `draftMachine`, confirm local-but-unconfigured ESLint is skipped quietly and explicit lint explains the missing config.
6. Re-source `~/.vimrc` and repeat a save/attach check to prove autocmds and clients are not duplicated.

## 7. Acceptance-criteria mapping

| User-visible criterion | Phase(s) | Verification |
| --- | --- | --- |
| Supported plugins can load on the installed runtime | 1, 2 | Version commands; headless config load |
| TS and TSX have modern parsing/highlighting | 2 | Filetype and active highlighter assertions; visual TSX QA |
| A TypeScript server attaches automatically | 1, 3 | `:LspInfo`; smoke checker client assertion |
| Type errors and semantic diagnostics appear | 3 | Intentional type error in fixture |
| Definition, references, implementation, hover, rename, imports, and code actions work | 3 | Fixture navigation/refactor QA |
| Completion is semantic and does not break Copilot | 3 | LSP completion + Copilot key-path QA |
| Prettier formatting is available and project-aware | 4 | `<leader>fm`; `:ConformInfo`; project config result |
| ESLint diagnostics run from project tooling | 4 | Save/fix lint violation; diagnostic namespace check |
| Docs no longer oversell unattached LSP behavior | 3, 5 | Mapping/config review against README/CHEATSHEET |
| Setup remains verifiable over time | 2, 5 | Inventory regeneration and smoke checker |
| Repository planning docs stay repository-local | 1 | Fake-home installer test confirms no `~/.docs` and another ordinary top-level symlink still appears |
| Unrelated dotfile behavior/change is preserved | All, 6 | Focused diff review; non-LSP `K`; `zshrc` exclusion |

## 8. Out of scope / deferred

- Unconditional format-on-save and any automatic fallback to global Prettier or `ts_ls`.
- Completion frameworks (`nvim-cmp`), snippets, and completion UI customization beyond native Neovim behavior.
- Mason or other automatic installation of language servers/formatters/linters.
- Alternative TypeScript servers such as `vtsls`, `typescript-tools.nvim`, or experimental native `tsgo`/`tsgolint` paths; reconsider only for a demonstrated workflow that `ts_ls` cannot support.
- Deno routing and framework servers/plugins for Vue, Svelte, Astro, Angular, or GraphQL.
- Test runners, debugging adapters, coverage UI, or project task execution.
- Broad cleanup of duplicated config sourcing, old inactive plugins, NERDTree startup, global mappings, or the legacy `mac` bootstrap.
- Plain Vim support.
- Repairing the MacBook's broken non-interactive `/usr/local/bin/node`/ICU linkage or hard-coding a machine-specific NVM Node path.

## 9. Completion record

1. Final focused review and clean pinned-stack verification passed on both Macs.
2. The implementation was squash-merged through PR #11 on 2026-07-15 with the unrelated `zshrc` change excluded.
3. Semantic release published repository version `v1.4.0`.
4. The synchronized plan and progress artifacts were moved together to `docs/archive/`; top-level `docs/` remains repository-only.
