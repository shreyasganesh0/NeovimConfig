# Neovim Config

Personal Neovim config using [lazy.nvim](https://github.com/folke/lazy.nvim). Works on Linux, macOS, and Windows.

## Prerequisites

| Requirement | Linux | macOS | Windows |
|---|---|---|---|
| Neovim 0.10+ | [releases](https://github.com/neovim/neovim/releases) | `brew install neovim` | `winget install Neovim.Neovim` |
| git | `sudo apt install git` | `brew install git` | `winget install Git.Git` |
| C compiler (treesitter) | `sudo apt install gcc` | Xcode CLI tools | Visual Studio Build Tools |
| tree-sitter CLI (0.22+) | [GitHub releases](https://github.com/tree-sitter/tree-sitter/releases) (apt version too old) | `brew install tree-sitter` | [GitHub releases](https://github.com/tree-sitter/tree-sitter/releases) |
| Java 17+ (JDTLS only) | `sudo apt install openjdk-17-jdk` | `brew install openjdk@17` | [Adoptium](https://adoptium.net) |

## Install

Clone the config into the correct location for your platform:

**Linux / macOS**
```bash
git clone git@github.com:shreyasganesh0/NeovimConfig.git ~/.config/nvim
```

**Windows** (PowerShell)
```powershell
git clone git@github.com:shreyasganesh0/NeovimConfig.git "$env:LOCALAPPDATA\nvim"
```

## First Launch

Open Neovim — lazy.nvim will bootstrap itself and install all plugins automatically:

```bash
nvim
```

## Java / JDTLS Setup

JDTLS (Java language server) must be installed separately before opening Java files.

**Linux / macOS**
```bash
bash ~/.config/nvim/install_jdtls.sh
```

**Windows** (PowerShell, run as Administrator)
```powershell
~\AppData\Local\nvim\install_jdtls.ps1
```

JDTLS will then start automatically when you open a `.java` file.

## Key Mappings

| Key | Action |
|---|---|
| `<Space>pv` | Open file explorer (netrw) |
| `<Space>a` | Add file to Harpoon |
| `<Space>o` | Open Harpoon menu |
| `<C-h/j/k/l>` | Navigate Harpoon files 1–4 |
| `<Space>y` (visual) | Copy to system clipboard |
| `<Space>p` (visual) | Paste from system clipboard |
| **Java only** | |
| `<Space>jo` | Organize imports |
| `<Space>jv` | Extract variable |
| `<Space>jc` | Extract constant |
| `<Space>jm` | Extract method (visual) |
| `<Space>jr` | Refactor action |
| `gd` | Go to definition |
| `K` | Hover docs |
| `<Space>ca` | Code action |
| `<Space>rn` | Rename symbol |
| `gr` | References |
