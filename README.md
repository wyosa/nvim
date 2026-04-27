```
               _         
   ____ _   __(_)___ ___ 
  / __ \ | / / / __ `__ \
 / / / / |/ / / / / / / /
/_/ /_/|___/_/_/ /_/ /_/ 
                         
```
### Install Neovim

- [Install form package](https://github.com/neovim/neovim/blob/master/INSTALL.md#install-from-package)
- [Install form source (stable)](https://github.com/neovim/neovim/releases/tag/stable)

### Install External Dependencies

- Basic utils: `git`, `make`, `unzip`, C Compiler (`gcc`)
- [ripgrep](https://github.com/BurntSushi/ripgrep#installation),
  [fd-find](https://github.com/sharkdp/fd#installation)
- [tree-sitter CLI](https://github.com/tree-sitter/tree-sitter/blob/master/crates/cli/README.md#installation)
- Clipboard tool (xclip/xsel/win32yank or other depending on the platform)
- A [Nerd Font](https://www.nerdfonts.com/): optional, provides various icons
  - if you have it set `vim.g.have_nerd_font` in `init.lua` to true
- Emoji fonts (Ubuntu only, and only if you want emoji!) `sudo apt install fonts-noto-color-emoji`
- Language Setup:
  - If you want to write Typescript, you need `npm`
  - If you want to write Golang, you will need `go`
  - etc.
