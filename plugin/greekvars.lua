-- greekvars.nvim
-- A Neovim plugin that replaces Greek letter names with the corresponding Greek character

-- Prevent loading the plugin twice
if vim.g.loaded_greekvars then
  return
end
vim.g.loaded_greekvars = true

-- The plugin does not automatically setup.
-- Users must call require('greekvars').setup() in their config.
