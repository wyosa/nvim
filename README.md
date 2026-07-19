```
               _
   ____ _   __(_)___ ___
  / __ \ | / / / __ `__ \
 / / / / |/ / / / / / / /
/_/ /_/|___/_/_/ /_/ /_/
```

### Install

Linux:

```sh
mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}"
git clone https://github.com/wyosa/nvim.git "${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
nvim
```

macOS:

```sh
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

### Optional settings

- `vim.g.kubernetes_schema_version`: Kubernetes schema version such as `"v1.34.0"`; defaults to `"master"`.
- `vim.g.sqlfluff_dialect`: SQLFluff dialect used when a project config is unavailable.
- `NVIM_PARENT_WATCHDOG=1`: close an orphaned Neovim instance when it has no modified or terminal buffers.

### Checks

Run `tests/check.sh` after Neovim has installed the plugins from `lazy-lock.json`.
