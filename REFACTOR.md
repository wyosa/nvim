# Neovim Refactor Plan

## Goals

- Keep the config modern for Neovim `0.12+`.
- Preserve a broad polyglot setup for TS/JS, React, Vue, Go, Python, Rust, SQL, YAML, JSON, Markdown, Docker, shell and occasional other languages.
- Keep global indent at `3`; language-specific indentation remains in `after/ftplugin/*`.
- Format on save always.
- Keep Wakatime and Discord Presence always on.
- Add a debugger setup that works well for the main languages, not just installed adapters.
- Prefer small, explicit changes over distro-like abstraction.

## User Decisions

- Primary languages: TS/JS, React, Vue, Go, Python, Rust, SQL, YAML, JSON, Markdown.
- Secondary language support should remain available when needed.
- Global indentation width `3` is intentional.
- Formatting should run on every save.
- `vim-wakatime` and `presence.nvim` should start with Neovim.
- Keep `lazy.nvim`; do not migrate to `vim.pack` yet.

## High Priority Fixes

1. Replace deprecated Neovim APIs.
   - `vim.highlight.on_yank()` -> `vim.hl.on_yank()`.
   - `diagnostic.jump.float` -> `diagnostic.jump.on_jump`.
   - `buffer = ...` in Lua opts -> `buf = ...` where applicable.

2. Fix Mason tool installation.
   - Current `vim.tbl_keys(servers or fallback)` makes fallback tools unreachable.
   - Split LSP servers and external tools into separate lists.
   - Use `mason-lspconfig.nvim` for LSP server install/enable.
   - Use `mason-tool-installer.nvim` for formatters, linters and debug adapters.

3. Fix Telescope mapping conflict.
   - `<leader>ss` is currently assigned twice.
   - Keep one binding for Telescope builtins or spell suggestions, move the other.

4. Make the parent-process autocmd safer.
   - Avoid unconditional `quitall!`, because it can discard unsaved changes.
   - Prefer `quitall` with confirmation or skip closing if modified buffers exist.

5. Update Treesitter config for `nvim-treesitter` main branch.
   - The main branch is a rewrite for Neovim `0.12+`.
   - Avoid old-style `ensure_installed`/`auto_install` assumptions.
   - Use `require("nvim-treesitter").install(languages)`.
   - Enable features manually with `vim.treesitter.start()`.

## Neovim 0.12 Modernization

### Core Options

- Keep:
  - `number`, `relativenumber`
  - `undofile`
  - `splitright`, `splitbelow`
  - `confirm`
  - global indent `3`

- Add or review:
  - `vim.o.winborder = "rounded"` or `"single"` for consistent floats.
  - `vim.o.pumborder = "rounded"` or `"single"` for popup menu border.
  - `vim.o.pummaxwidth = 80` or similar to avoid huge completion popups.
  - `vim.o.diffopt` should benefit from new defaults, including inline diff.

- Do not enable native `autocomplete` while using `blink.cmp`.

### Diagnostics

Target setup:

```lua
vim.diagnostic.config({
  update_in_insert = false,
  severity_sort = true,
  signs = true,
  underline = { severity = vim.diagnostic.severity.ERROR },
  virtual_text = {
    source = "if_many",
    spacing = 2,
  },
  virtual_lines = false,
  float = { source = "if_many" },
  jump = {
    on_jump = function(diagnostic, bufnr)
      if not diagnostic then
        return
      end
      vim.diagnostic.show(diagnostic.namespace, bufnr, { diagnostic }, {
        virtual_lines = { current_line = true },
        virtual_text = false,
      })
    end,
  },
})
```

Add toggles:

- Toggle diagnostics on/off.
- Toggle virtual lines.
- Toggle inlay hints.
- Toggle spell.
- Toggle wrap.
- Toggle list chars.

## LSP Plan

### Architecture

- Keep `neovim/nvim-lspconfig`, but use it only as a provider of server configs.
- Use modern API:
  - `vim.lsp.config()` for overrides.
  - `vim.lsp.enable()` for activation.
- Avoid `require("lspconfig").server.setup()`.
- Use global config for shared capabilities.

Target shape:

```lua
local capabilities = require("blink.cmp").get_lsp_capabilities()

vim.lsp.config("*", {
  capabilities = capabilities,
})

vim.lsp.enable({
  "vtsls",
  "vue_ls",
  "eslint",
  "html",
  "cssls",
  "tailwindcss",
  "emmet_language_server",
  "jsonls",
  "yamlls",
  "lua_ls",
  "gopls",
  "pyright",
  "ruff",
  "rust_analyzer",
  "sqlls",
  "taplo",
  "bashls",
  "dockerls",
  "docker_compose_language_service",
  "marksman",
})
```

### Main Servers

- TS/JS/React/Vue:
  - Use `vtsls` as the main TS/JS server.
  - Use `vue_ls` for Vue SFC support.
  - Do not enable `ts_ls` at the same time.
  - Remove `typescript-tools.nvim` unless there is a specific feature that `vtsls` cannot cover.

- Go:
  - `gopls`
  - Keep Go tools through Mason: `gofumpt`, `goimports`, `golines`, `delve`.

- Python:
  - `pyright` for type checking.
  - `ruff` for lint/code actions.
  - Formatting through Conform, not LSP formatting.

- Rust:
  - `rust_analyzer`.
  - Keep code lenses and debug-related commands.

- SQL:
  - `sqlls` or consider `postgres_lsp` later if PostgreSQL is the main SQL dialect.
  - Formatter/linter dialect decision still needed.

- Config/data files:
  - `jsonls`, `yamlls`, `taplo`, `marksman`, `bashls`, `dockerls`, `docker_compose_language_service`.

### Optional Servers To Keep Available

- `astro`
- `angularls`
- `graphql`
- `helm_ls`
- `clangd`
- `intelephense`

Install these if they are useful, but avoid starting extra servers in normal projects unless the filetype/root matches.

### TypeScript/Vue Target Config

- Configure `vtsls` with the Vue TypeScript plugin from Mason:

```lua
local vue_language_server_path = vim.fn.stdpath("data")
  .. "/mason/packages/vue-language-server/node_modules/@vue/language-server"

local vue_plugin = {
  name = "@vue/typescript-plugin",
  location = vue_language_server_path,
  languages = { "vue" },
  configNamespace = "typescript",
}

vim.lsp.config("vtsls", {
  settings = {
    vtsls = {
      tsserver = {
        globalPlugins = { vue_plugin },
      },
    },
  },
  filetypes = {
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
    "vue",
  },
})

vim.lsp.enable({ "vtsls", "vue_ls" })
```

## Mason Plan

### LSP Servers

Install through `mason-lspconfig.nvim`:

```lua
ensure_installed = {
  "vtsls",
  "vue_ls",
  "eslint",
  "html",
  "cssls",
  "tailwindcss",
  "emmet_language_server",
  "jsonls",
  "yamlls",
  "lua_ls",
  "gopls",
  "pyright",
  "ruff",
  "rust_analyzer",
  "sqlls",
  "taplo",
  "bashls",
  "dockerls",
  "docker_compose_language_service",
  "marksman",
  "astro",
  "angularls",
  "graphql",
  "helm_ls",
  "clangd",
  "intelephense",
}
```

### External Tools

Install through `mason-tool-installer.nvim`:

```lua
ensure_installed = {
  "prettierd",
  "prettier",
  "stylua",
  "shfmt",
  "shellcheck",
  "hadolint",
  "yamllint",
  "actionlint",
  "markdownlint-cli2",
  "gofumpt",
  "goimports",
  "golines",
  "black",
  "isort",
  "sqlfluff",
  "sqruff",
  "clang-format",
  "debugpy",
  "delve",
  "codelldb",
  "js-debug-adapter",
  "bash-debug-adapter",
}
```

Recommended Mason tool installer options:

```lua
require("mason-tool-installer").setup({
  ensure_installed = tools,
  run_on_start = true,
  start_delay = 3000,
  debounce_hours = 12,
})
```

## Treesitter Plan

### Parser List

Recommended parsers:

```lua
local languages = {
  "bash",
  "c",
  "css",
  "diff",
  "dockerfile",
  "fish",
  "gitcommit",
  "gitignore",
  "go",
  "gomod",
  "gosum",
  "graphql",
  "html",
  "javascript",
  "json",
  "jsonc",
  "lua",
  "luadoc",
  "markdown",
  "markdown_inline",
  "python",
  "query",
  "regex",
  "rust",
  "sql",
  "toml",
  "tsx",
  "typescript",
  "vim",
  "vimdoc",
  "vue",
  "xml",
  "yaml",
  "zsh",
}
```

Optional parsers:

- `angular`
- `astro`
- `php`
- `scss`
- `tmux`
- `clickhouse`
- `postgresql`

### Setup Shape

```lua
require("nvim-treesitter").setup()
require("nvim-treesitter").install(languages)

vim.api.nvim_create_autocmd("FileType", {
  pattern = {
    "bash",
    "c",
    "css",
    "dockerfile",
    "go",
    "gomod",
    "gosum",
    "html",
    "javascript",
    "javascriptreact",
    "json",
    "jsonc",
    "lua",
    "markdown",
    "python",
    "rust",
    "sql",
    "toml",
    "typescript",
    "typescriptreact",
    "vim",
    "vue",
    "xml",
    "yaml",
    "zsh",
  },
  callback = function(args)
    if vim.bo[args.buf].buftype ~= "" then
      return
    end

    pcall(vim.treesitter.start, args.buf)
    vim.wo.foldmethod = "expr"
    vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
  end,
})
```

### Folding

- Keep high fold level by default.
- Default to Treesitter folds.
- Prefer LSP fold expression per buffer when supported:

```lua
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client and client:supports_method("textDocument/foldingRange") then
      vim.wo.foldexpr = "v:lua.vim.lsp.foldexpr()"
    end
  end,
})
```

## Formatting Plan

Use `conform.nvim` as the only formatting orchestrator.

Target formatter map:

```lua
formatters_by_ft = {
  lua = { "stylua" },

  javascript = { "prettierd", "prettier", stop_after_first = true },
  javascriptreact = { "prettierd", "prettier", stop_after_first = true },
  typescript = { "prettierd", "prettier", stop_after_first = true },
  typescriptreact = { "prettierd", "prettier", stop_after_first = true },
  vue = { "prettierd", "prettier", stop_after_first = true },
  astro = { "prettierd", "prettier", stop_after_first = true },
  css = { "prettierd", "prettier", stop_after_first = true },
  scss = { "prettierd", "prettier", stop_after_first = true },
  html = { "prettierd", "prettier", stop_after_first = true },
  json = { "prettierd", "prettier", stop_after_first = true },
  jsonc = { "prettierd", "prettier", stop_after_first = true },
  yaml = { "prettierd", "prettier", stop_after_first = true },
  markdown = { "prettierd", "prettier", stop_after_first = true },
  graphql = { "prettierd", "prettier", stop_after_first = true },

  go = { "goimports", "gofumpt", "golines" },
  python = { "ruff_organize_imports", "ruff_format", "black", stop_after_first = false },
  rust = { "rustfmt" },
  sh = { "shfmt" },
  bash = { "shfmt" },
  zsh = { "shfmt" },
  sql = { "sqlfluff" },

  ["_"] = { "trim_whitespace", "trim_newlines" },
}
```

Format on save:

```lua
format_on_save = {
  timeout_ms = 1500,
  lsp_format = "fallback",
}
```

Notes:

- SQL formatter requires a dialect decision.
- If `sqlfluff` is too slow/noisy, consider `sqruff` or make SQL formatting manual only.
- Since the user wants always format-on-save, do not gate by formatter config files.

## Linting Plan

Use `nvim-lint` for standalone linters that complement LSP.

Target lint map:

```lua
linters_by_ft = {
  javascript = { "eslint_d" },
  javascriptreact = { "eslint_d" },
  typescript = { "eslint_d" },
  typescriptreact = { "eslint_d" },
  vue = { "eslint_d" },
  python = { "ruff" },
  sh = { "shellcheck" },
  bash = { "shellcheck" },
  zsh = { "shellcheck" },
  dockerfile = { "hadolint" },
  yaml = { "yamllint" },
  markdown = { "markdownlint-cli2" },
  sql = { "sqlfluff" },
}
```

Autocmd strategy:

- Run on `BufWritePost`.
- Optionally run on `BufReadPost`.
- Avoid global `InsertLeave` for all linters because it can be noisy and expensive.
- For GitHub Actions, use filetype detection for `yaml.ghaction` and run `actionlint`.

## Completion Plan

Keep `blink.cmp` stable:

- Continue using `version = "1.*"`.
- Do not move to v2/main yet because it is under active development with breaking changes.
- Add `buffer` source.
- Prefer Rust/prebuilt fuzzy matcher if available.
- Keep `signature.enabled = true`.

Target options:

```lua
opts = {
  keymap = { preset = "default" },
  appearance = { nerd_font_variant = "mono" },
  completion = {
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 500,
    },
    ghost_text = { enabled = true },
  },
  sources = { default = { "lsp", "path", "snippets", "buffer" } },
  snippets = { preset = "luasnip" },
  fuzzy = { implementation = "prefer_rust" },
  signature = { enabled = true },
}
```

## Debugger Plan

### Base Plugins

Keep:

- `mfussenegger/nvim-dap`
- `rcarriga/nvim-dap-ui`
- `nvim-neotest/nvim-nio`
- `jay-babu/mason-nvim-dap.nvim`
- `leoluz/nvim-dap-go`

Add:

- `theHamsta/nvim-dap-virtual-text`
- Optional: `nvim-telescope/telescope-dap.nvim`

### Debug Adapters

Install via Mason:

- Go: `delve`
- Python: `debugpy`
- Rust: `codelldb`
- JS/TS/React/Vue/Node: `js-debug-adapter`
- Shell optional: `bash-debug-adapter`

### Go Debugging

Use `nvim-dap-go`:

- Debug current package.
- Debug current file/package.
- Debug nearest test.
- Debug last test.
- Attach process.

Suggested mappings:

- `<leader>dt` debug nearest Go test.
- `<leader>dT` debug Go package tests.

### Python Debugging

Use `debugpy`:

- Launch current file.
- Attach to process/port.
- Resolve Python path in this order:
  - `VIRTUAL_ENV/bin/python`
  - `.venv/bin/python`
  - `python3`
  - `python`

Target config idea:

```lua
local function python_path()
  if vim.env.VIRTUAL_ENV then
    return vim.env.VIRTUAL_ENV .. "/bin/python"
  end

  local venv = vim.fs.root(0, { ".venv" })
  if venv then
    return venv .. "/.venv/bin/python"
  end

  return vim.fn.exepath("python3") or vim.fn.exepath("python") or "python"
end
```

### Rust Debugging

Use `codelldb`:

- Launch executable.
- Prompt for binary path.
- Later integrate `rust-analyzer.debugSingle` if desired.

Useful config:

```lua
program = function()
  return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/target/debug/", "file")
end
```

### JS/TS/React/Vue Debugging

Use VS Code JS debug adapter through `js-debug-adapter`:

- `pwa-node` launch current file.
- `pwa-node` attach to process.
- `pwa-node` attach to port `9229`.
- `pwa-chrome` attach to browser on port `9222`.
- Support React/Vue frontend debugging by launching Chrome manually with remote debugging:

```sh
open -a "Google Chrome" --args --remote-debugging-port=9222
```

Recommended scenarios:

- Node backend: launch/attach.
- Vitest/Jest: launch npm test command with selected test file.
- React/Vue frontend: attach browser to `localhost` app.

### Shell Debugging

Optional:

- `bash-debug-adapter` for shell scripts.

### Debug UI Behavior

- Open DAP UI when session starts.
- Close DAP UI when session terminates/exits.
- Enable virtual text for variable values.
- Add REPL toggle.
- Add hover and preview variable mappings.

### Debug Keymaps

Recommended final keymap layout:

- `<F5>` continue/start.
- `<F10>` step over.
- `<F11>` step into.
- `<F12>` step out.
- `<leader>db` toggle breakpoint.
- `<leader>dB` conditional breakpoint.
- `<leader>dl` logpoint.
- `<leader>dr` toggle REPL.
- `<leader>du` toggle DAP UI.
- `<leader>dh` hover variable.
- `<leader>dp` preview variable.
- `<leader>dc` run to cursor.
- `<leader>dx` terminate.
- `<leader>dL` run last.

### SQL Debugging

- There is no good universal SQL DAP workflow.
- For SQL, prioritize:
  - LSP/completion.
  - Formatter/linter.
  - Query runner.
  - Result viewer.
- PostgreSQL stored procedure debugging is possible only with server-specific tooling and should be a separate task.

## Telescope Plan

Fix mappings:

- Keep `<leader>sf` for files.
- Keep `<leader>sg` for live grep.
- Move custom multigrep into search namespace, for example `<leader>sG`.
- Move spell suggestions away from `<leader>ss`, for example `<leader>z=` or `<leader>sp`.

Improve search behavior:

- Default hidden file search should respect `.gitignore`.
- Keep a separate “search all, including ignored files” mapping.

Example:

```lua
vim.keymap.set("n", "<leader>sa", function()
  builtin.find_files({ hidden = true })
end, { desc = "[S]earch [A]ll hidden" })

vim.keymap.set("n", "<leader>sA", function()
  builtin.find_files({ hidden = true, no_ignore = true })
end, { desc = "[S]earch [A]bsolutely all" })
```

Trouble integration:

- Add `<C-t>` in Telescope insert/normal mode to open results in Trouble.

## Keymaps And Which-Key Plan

Move all mappings out of `init.lua` into `lua/core/keymaps.lua`.

Recommended groups:

- `<leader>s` Search.
- `<leader>c` Code.
- `<leader>x` Diagnostics/Trouble.
- `<leader>g` Git.
- `<leader>h` Git hunk, if keeping current convention.
- `<leader>d` Debug.
- `<leader>t` Toggles.
- `<leader>l` LSP or LazyGit, decide one namespace.

Avoid duplicating new Nvim defaults unless the custom key is clearly more comfortable.

Nvim default LSP mappings to remember:

- `gra` code action.
- `gri` implementation.
- `grn` rename.
- `grr` references.
- `grt` type definition.
- `grx` codelens run.
- `gO` document symbols.

Nvim default diagnostic mappings:

- `]d` next diagnostic.
- `[d` previous diagnostic.
- `]D` last diagnostic.
- `[D` first diagnostic.
- `<C-w>d` diagnostic float.

## Git Plan

Current `gitsigns.nvim` setup is mostly good.

Recommended changes:

- Consider enabling `attach_to_untracked = true` if untracked files should show signs.
- Add mappings for:
  - `gitsigns.setqflist("all")`
  - `gitsigns.setloclist()`
  - `gitsigns.blame()` full panel
- Keep LazyGit always lazy-loaded by command/key.

## UI And Statusline Plan

Improve `lualine.nvim`:

- Add git branch.
- Add git diff.
- Add diagnostics.
- Add active LSP clients.
- Add formatter status if useful.
- Add DAP status.
- Add lazy update indicator.
- Add `vim.ui.progress_status()` or keep `fidget.nvim` as primary LSP progress UI.

Example components:

- `branch`
- `diff`
- `diagnostics`
- `require("dap").status`
- `require("lazy.status").updates`

## Plugin Cleanup

### Keep Always On

- `wakatime/vim-wakatime` with `lazy = false`.
- `andweeb/presence.nvim` with `lazy = false`.

### Remove Duplicate Surround

Currently both are present:

- `mini.surround`
- `kylechui/nvim-surround`

Recommendation:

- Keep `mini.ai`.
- Keep `mini.surround`.
- Remove `nvim-surround` unless there is a specific behavior you prefer from it.

### Lazy Loading

- Telescope: load by `cmd = "Telescope"` and keys.
- Trouble: already good with `cmd = "Trouble"` and keys.
- Neo-tree: already good with `cmd = "Neotree"` and keys.
- DAP: load by debug keys.
- Indent guides: load on file read/new file.
- Guess indent: load on file read/new file.

Do not lazy-load `nvim-treesitter` main branch; upstream says it does not support lazy-loading.

## File Structure Refactor

Suggested structure:

```text
init.lua
lua/core/options.lua
lua/core/keymaps.lua
lua/core/autocmds.lua
lua/core/diagnostic.lua
lua/core/lazy.lua
lua/plugins/colorscheme.lua
lua/plugins/lsp.lua
lua/plugins/treesitter.lua
lua/plugins/format.lua
lua/plugins/lint.lua
lua/plugins/completion.lua
lua/plugins/debug.lua
lua/plugins/search.lua
lua/plugins/git.lua
lua/plugins/ui.lua
lua/plugins/editing.lua
after/ftplugin/python.lua
after/ftplugin/go.lua
after/ftplugin/rust.lua
after/ftplugin/typescript.lua
after/ftplugin/javascript.lua
after/ftplugin/vue.lua
after/ftplugin/sql.lua
```

Keep individual plugin files if preferred, but group by concern if files become too small and scattered.

## README Updates

Update `README.md` with:

- Neovim `0.12.2+` requirement.
- `tree-sitter-cli >= 0.26.1` installed from package manager, not npm.
- Required external tools:
  - `git`
  - `make`
  - C compiler
  - `ripgrep`
  - `fd`
  - `node`/`npm`
  - `go`
  - `python`/`uv`
  - `rustup`
- Optional tools:
  - Chrome for browser debugging.
  - Docker tools.
  - SQL formatter dependencies.

## Verification Checklist

Run after implementation:

- `nvim --version`
- `:checkhealth vim.lsp`
- `:checkhealth nvim-treesitter`
- `:checkhealth lazy`
- `:checkhealth telescope`
- `:ConformInfo`
- `:Mason`
- `:Lazy profile`

Manual smoke tests:

- Open a TS React file and verify `vtsls`, eslint, completion, formatting.
- Open a Vue file and verify both `vue_ls` and `vtsls` attach.
- Open Go file and verify `gopls`, format, DAP test debug.
- Open Python file and verify `pyright`, `ruff`, formatting and `debugpy` launch.
- Open Rust file and verify `rust_analyzer`, format and `codelldb` launch.
- Open SQL file and verify formatting/linting behavior is acceptable.
- Open JSON/YAML/Markdown files and verify schemas/formatters.
- Check Telescope mappings.
- Check Trouble diagnostics and symbols.
- Check Wakatime and Presence start automatically.

## Suggested Implementation Order

1. Neovim 0.12 API cleanup.
2. Mason split into LSP/tools/debug adapters.
3. LSP rewrite with `vtsls + vue_ls`.
4. Treesitter main branch rewrite.
5. Conform and nvim-lint expansion.
6. Debugger setup for Go, Python, Rust, JS/TS.
7. Telescope/keymap/which-key cleanup.
8. UI/statusline improvements.
9. Plugin cleanup and README update.
10. Health checks and smoke tests.
