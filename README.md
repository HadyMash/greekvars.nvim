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
  config = function()
    require("greekvars").setup()
  end,
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "HadyMash/greekvars.nvim",
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
  case_sensitive = true,    -- Whether matching is case sensitive
  case_preference = "lower", -- When case_insensitive, prefer "lower" or "upper" case symbols
  greek_vars = {},          -- Custom greek variable mappings (optional)
})
```

### Customizing Greek Variables

You can customize the Greek variable mappings by providing a `greek_vars` table in the setup configuration. This allows you to:
- Override existing mappings (e.g., change `alpha` to display as `"a"` instead of `"α"`)
- Add new custom symbols (e.g., `mysymbol = "★"`)
- Remove default mappings (set them to `false` or `vim.NIL`)

Example:

```lua
require("greekvars").setup({
  greek_vars = {
    -- Override existing Greek letters
    alpha = "a",
    beta = "b",
    
    -- Add custom symbols
    star = "★",
    heart = "♥",
    diamond = "♦",
    
    -- Remove defaults
    gamma = false,      -- Remove gamma from conceal
    DELTA = vim.NIL,    -- Remove DELTA from conceal
  },
})
```

In this example:
- `alpha` will be concealed as `"a"` instead of `"α"`
- `beta` will be concealed as `"b"` instead of `"β"`
- `gamma` and `DELTA` will not be concealed at all
- All other default Greek letters will continue to use their default symbols
- New custom words like `star`, `heart`, and `diamond` will be concealed with their respective symbols

### Case Sensitivity

By default, the plugin uses case-sensitive matching. You can control this behavior:

#### Case Sensitive (Default)

```lua
require("greekvars").setup({
  case_sensitive = true,  -- Default
})
```

With case-sensitive matching:
- `alpha` matches only `alpha` → α
- `ALPHA` matches only `ALPHA` → Α
- `Alpha` is not concealed

#### Case Insensitive

```lua
require("greekvars").setup({
  case_sensitive = false,
  case_preference = "lower",  -- or "upper"
})
```

With case-insensitive matching:
- `alpha`, `ALPHA`, `Alpha`, `aLpHa` all match and get concealed
- `case_preference = "lower"` uses lowercase symbols (α) for all matches
- `case_preference = "upper"` uses uppercase symbols (Α) for all matches

### Removing All Defaults

To start with an empty set and only use your custom symbols:

```lua
-- Get all default keys
local default_keys = {
  "alpha", "beta", "gamma", "delta", "epsilon", "zeta", "eta", "theta",
  "iota", "kappa", "lambda", "mu", "nu", "xi", "omicron", "pi", "rho",
  "sigma", "tau", "upsilon", "phi", "chi", "psi", "omega",
  "ALPHA", "BETA", "GAMMA", "DELTA", "EPSILON", "ZETA", "ETA", "THETA",
  "IOTA", "KAPPA", "LAMBDA", "MU", "NU", "XI", "OMICRON", "PI", "RHO",
  "SIGMA", "TAU", "UPSILON", "PHI", "CHI", "PSI", "OMEGA",
}

local remove_defaults = {}
for _, key in ipairs(default_keys) do
  remove_defaults[key] = false
end

require("greekvars").setup({
  greek_vars = vim.tbl_extend("force", remove_defaults, {
    -- Now add only your custom symbols
    star = "★",
    heart = "♥",
  }),
})
```

## Usage

Once installed and set up, the plugin will automatically conceal Greek letter names in supported file types.

### Commands

- `:GreekVarsToggle` - Toggle Greek variable conceal on/off

### Supported Greek Letters

The following Greek letter names are supported by default:

| Lowercase | Symbol | Uppercase | Symbol |
|-----------|--------|-----------|--------|
| alpha     | α      | ALPHA     | Α      |
| beta      | β      | BETA      | Β      |
| gamma     | γ      | GAMMA     | Γ      |
| delta     | δ      | DELTA     | Δ      |
| epsilon   | ε      | EPSILON   | Ε      |
| zeta      | ζ      | ZETA      | Ζ      |
| eta       | η      | ETA       | Η      |
| theta     | θ      | THETA     | Θ      |
| iota      | ι      | IOTA      | Ι      |
| kappa     | κ      | KAPPA     | Κ      |
| lambda    | λ      | LAMBDA    | Λ      |
| mu        | μ      | MU        | Μ      |
| nu        | ν      | NU        | Ν      |
| xi        | ξ      | XI        | Ξ      |
| omicron   | ο      | OMICRON   | Ο      |
| pi        | π      | PI        | Π      |
| rho       | ρ      | RHO       | Ρ      |
| sigma     | σ      | SIGMA     | Σ      |
| tau       | τ      | TAU       | Τ      |
| upsilon   | υ      | UPSILON   | Υ      |
| phi       | φ      | PHI       | Φ      |
| chi       | χ      | CHI       | Χ      |
| psi       | ψ      | PSI       | Ψ      |
| omega     | ω      | OMEGA     | Ω      |

## How It Works

The plugin uses Vim's built-in conceal feature to replace text in the buffer display without modifying the actual file content. When you search for text, conceal is temporarily disabled so that search highlights work properly.

The concealed Greek characters preserve the syntax highlighting of the original text, whether it comes from Vim's traditional syntax highlighting, TreeSitter, or LSP semantic tokens. This means that function parameters, variables, keywords, and other highlighted text will maintain their colors even when concealed.

## License

MIT
