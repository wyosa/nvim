```
               _
   ____ _   __(_)___ ___
  / __ \ | / / / __ `__ \
 / / / / |/ / / / / / / /
/_/ /_/|___/_/_/ /_/ /_/
```

### Install

```bash
# Linux
mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}"
git clone https://github.com/wyosa/nvim.git "${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
nvim

# MacOS
mkdir -p "$HOME/.config"
git clone https://github.com/wyosa/nvim.git "$HOME/.config/nvim"
nvim
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
- Nerd Font for icons (`vim.g.have_nerd_font` is set in `init.lua`)

### Rust

Install a toolchain before using Rust LSP and formatting:

```sh
rustup toolchain install stable --profile minimal --component rustfmt --component rust-src
rustup default stable
```

Neovim also finds Homebrew's Rust proxies beside `rustup` if `cargo` is missing from PATH.

### Formatting and large files

- `<leader>f`: format manually.
- `<leader>tf`: toggle format on save for the current buffer.
- `<leader>hs` / `<leader>hu`: stage or unstage the hunk under the cursor.
  The deprecated undo of the last staging operation is no longer used.
- Buffers larger than 1 MiB or 20,000 lines skip Tree-sitter, automatic formatting and expression folds.
  Set `vim.g.large_file_max_bytes` or `vim.g.large_file_max_lines` to change these limits.
- SQL formatting requires a project SQLFluff configuration or `vim.g.sqlfluff_dialect`.

### Maintenance

Server overrides live in `after/lsp/`; the enabled server list is `lua/core/lsp_servers.lua`.
Tree-sitter filetypes are resolved from parser languages, including YAML subtypes.

Use `:Lazy update` for plugins (Tree-sitter parsers are updated by its build hook).
Update language servers separately through `:Mason`; `:MasonToolsUpdate` updates the
formatters and linters declared in `lua/plugins/tools.lua`. Automatic tool updates
remain disabled so formatter changes can be coordinated with project and CI versions.

Run `sh tests/check.sh` after updates. Tests isolate plugin caches and disable LSP
startup and package installation; logs and temporary copies are removed on exit.
