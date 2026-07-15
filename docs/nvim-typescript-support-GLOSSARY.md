# Neovim TypeScript Support Glossary

This glossary records the terms used by the TypeScript-support plan and its decision records.

- **LSP (Language Server Protocol):** The protocol Neovim uses to communicate with a language server for diagnostics, completion, navigation, rename, and code actions.
- **`tsserver`:** TypeScript's native editor service. It does not speak LSP directly.
- **`typescript-language-server`:** The executable adapter that wraps `tsserver` and exposes LSP. The standard invocation is `typescript-language-server --stdio`.
- **`ts_ls`:** The `nvim-lspconfig` configuration name for `typescript-language-server`. It is not an alias for launching raw `tsserver`.
- **Tree-sitter:** Neovim's parser-based syntax/highlighting system. It is the sole selected TS/TSX highlighter after migration, but it does not provide type checking or other LSP features.
- **TSX:** TypeScript syntax with JSX, normally detected by Neovim as the `typescriptreact` filetype.
- **JS/JSX filetypes:** Neovim detects JavaScript as `javascript` and JSX as `javascriptreact`; this effort intentionally applies the same server/parser/format/lint stack to them for mixed projects.
- **Native LSP completion:** Neovim's built-in `vim.lsp.completion` support, used by this plan instead of a completion framework such as `nvim-cmp`.
- **Copilot coexistence:** Native LSP completion uses `Ctrl-N`/`Ctrl-P`/`Ctrl-Y`, while `github/copilot.vim` retains insert-mode `Tab` for accepting inline suggestions; each path is tested independently.
- **Inlay hint:** A non-editing inline annotation supplied by the language server, such as an inferred parameter name or return type. Hints are configured but off by default and toggled per buffer.
- **Source action:** A whole-file semantic operation such as organize imports, add missing imports, remove unused code, or TypeScript fix-all. This plan exposes source actions only through explicit invocation, never on save.
- **Balanced diagnostics:** Signs and underlines show warnings/errors, virtual text is limited to errors, and full messages are available through a bordered diagnostic float and navigation mappings.
- **Native-first mappings:** The plan follows Neovim's `grn`/`gra`/`grr`/`gri` LSP family and adds only focused buffer/tool mappings, avoiding a conflicting bare `gr` or duplicate leader vocabulary.
- **Project-local tool:** A binary under a project's `node_modules/.bin`, allowing the project to control its TypeScript, Prettier, or ESLint version.
- **Global fallback:** A tool found on the shell/Neovim `PATH` when no project-local executable exists. Global Prettier is permitted for explicit formatting but never for format-on-save.
- **Local-only format-on-save:** Automatic formatting that runs whenever `node_modules/.bin/prettier` is found upward from the current buffer; the binary alone is the opt-in signal, its owning project root becomes formatter `cwd`, and no global or LSP formatter fallback is allowed.
- **Local-only automatic linting:** Post-save linting that runs only when both `node_modules/.bin/eslint` and a discoverable flat/legacy ESLint config are found upward from the current buffer; unconfigured projects skip quietly and global ESLint is explicit-only.
- **External provisioning:** Installing the `neovim`/`tree-sitter-cli` Homebrew formulas and Node-based editor tools through npm under the active NVM default, rather than through Mason. The tested global TypeScript fallback is 5.9.3 because TypeScript 7 lacks the server module required by `typescript-language-server` 5.3.0.
- **Supported Macs:** `andrews-mac-mini-1` (current Mac mini) and `qianas-macbook-pro-1` (remote MacBook Pro), connected through Tailscale and expected to run the same tracked dotfiles.
- **Supported ecosystem:** Standard Node/browser JavaScript and TypeScript projects, including JSX and React-style TSX. Deno and framework-specific Vue/Svelte/Astro/Angular language-server integration are separate future efforts.
- **Two-layer validation:** Automated disposable-fixture/headless checks plus interactive QA in a real project with local TypeScript, Prettier, and ESLint, performed independently on both supported Macs.
- **MacBook verification shell:** The interactive zsh/NVM environment used for remote checks because it provides working Node; the broken non-interactive Homebrew Node is outside this effort.
- **Fail-fast installer preflight:** An `install.sh` check that requires Neovim 0.12+ before any plugin/parser mutation and exits with external upgrade guidance instead of continuing or falling back to plain Vim.
- **Pinned TypeScript stack:** Exact tested commits for `nvim-lspconfig`, current-main `nvim-treesitter`, Conform, and `nvim-lint`, shared by both Macs and updated only through deliberate maintenance validation.
- **Repository-only docs:** The top-level `docs/` planning and ADR directory, which `install.sh` intentionally skips instead of creating `~/.docs`.
