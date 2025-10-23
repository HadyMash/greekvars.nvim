# greekvars.nvim

A Neovim plugin that replaces Greek letter names with the corresponding Greek character using Vim's conceal feature.

## Features

- Automatically conceals Greek letter names (e.g., `alpha`, `beta`, `gamma`) with their corresponding Unicode symbols (α, β, γ)
- Works with multiple programming languages (Lua, Python, JavaScript, TypeScript, C, C++)
- Temporarily disables conceal during search to show search highlights properly
- Configurable file types and conceal settings
- Easy toggle command to enable/disable Greek variable conceal

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "HadyMash/greekvars.nvim",
  ft = { "lua", "python", "javascript", "typescript", "c", "cpp" },
  config = function()
    require("greekvars").setup()
  end,
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "HadyMash/greekvars.nvim",
  ft = { "lua", "python", "javascript", "typescript", "c", "cpp" },
  config = function()
    require("greekvars").setup()
  end,
}
```

### Using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'HadyMash/greekvars.nvim'
```

Then add to your `init.lua`:

```lua
require("greekvars").setup()
```

## Configuration

Default configuration:

```lua
require("greekvars").setup({
  conceallevel = 2,         -- Vim's conceallevel setting (0-3)
  concealcursor = "nc",     -- Vim's concealcursor setting
  filetypes = {             -- File types where Greek vars are concealed
    "lua",
    "python",
    "javascript",
    "typescript",
    "c",
    "cpp",
  },
})
```

## Usage

Once installed and set up, the plugin will automatically conceal Greek letter names in supported file types.

### Commands

- `:GreekVarsToggle` - Toggle Greek variable conceal on/off

### Supported Greek Letters

The following Greek letter names are supported:

| Name      | Symbol |
|-----------|--------|
| alpha     | α      |
| beta      | β      |
| gamma     | γ      |
| delta     | δ      |
| epsilon   | ε      |
| zeta      | ζ      |
| eta       | η      |
| theta     | θ      |
| iota      | ι      |
| kappa     | κ      |
| lambda    | λ      |
| mu        | μ      |
| nu        | ν      |
| xi        | ξ      |
| omicron   | ο      |
| pi        | π      |
| rho       | ρ      |
| sigma     | σ      |
| tau       | τ      |
| upsilon   | υ      |
| phi       | φ      |
| chi       | χ      |
| psi       | ψ      |
| omega     | ω      |

## How It Works

The plugin uses Vim's built-in conceal feature to replace text in the buffer display without modifying the actual file content. When you search for text, conceal is temporarily disabled so that search highlights work properly.

The concealed Greek characters preserve the syntax highlighting of the original text, whether it comes from Vim's traditional syntax highlighting, TreeSitter, or LSP semantic tokens. This means that function parameters, variables, keywords, and other highlighted text will maintain their colors even when concealed.

## License

MIT
