```
               _
   ____ _   __(_)___ ___
  / __ \ | / / / __ `__ \
 / / / / |/ / / / / / / /
/_/ /_/|___/_/_/ /_/ /_/
```

### Requirements

- Neovim `0.12.2+`
- `git`, `make`, `unzip`, `curl`, `tar`
- C compiler (`gcc`, `clang`, or platform equivalent)
- `ripgrep`
- `fd`
- `tree-sitter-cli >= 0.26.1` from a package manager, not npm
- `node` and `npm`
- `go`
- `python` and optionally `uv`
- `rustup`
- Clipboard tool for your platform (`pbcopy`, `xclip`, `xsel`, `win32yank`, etc.)

### Optional Tools

- Nerd Font for icons (`vim.g.have_nerd_font` is set in `init.lua`)
- Google Chrome for frontend debugging with `pwa-chrome`
- Docker tooling for Dockerfile and Compose workflows
- SQL formatter dependencies for `sqlfluff`; default dialect is `postgres` and can be overridden with `vim.g.sqlfluff_dialect`

### Notes

- Plugins are managed by `lazy.nvim`.
- LSP servers are installed through `mason-lspconfig.nvim`.
- Formatters and standalone lint tools are installed through `mason-tool-installer.nvim`.
- Debug adapters are installed through `mason-nvim-dap.nvim`.
- Formatting runs on every save through `conform.nvim`.
- Editor diagnostics come from LSP plus `nvim-lint` for CI-like checks such as `actionlint`, `yamllint`, `hadolint`, `markdownlint-cli2`, `shellcheck`, and `sqlfluff`.
