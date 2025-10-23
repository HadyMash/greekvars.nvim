local M = {}

-- Greek letter mappings
M.greek_vars = {
  alpha = "α",
  beta = "β",
  gamma = "γ",
  delta = "δ",
  epsilon = "ε",
  zeta = "ζ",
  eta = "η",
  theta = "θ",
  iota = "ι",
  kappa = "κ",
  lambda = "λ",
  mu = "μ",
  nu = "ν",
  xi = "ξ",
  omicron = "ο",
  pi = "π",
  rho = "ρ",
  sigma = "σ",
  tau = "τ",
  upsilon = "υ",
  phi = "φ",
  chi = "χ",
  psi = "ψ",
  omega = "ω",
}

-- Default configuration
M.config = {
  conceallevel = 2,
  concealcursor = "nc",
  filetypes = { "lua", "python", "javascript", "typescript", "c", "cpp" },
}

-- Setup conceal for Greek variables
local function setup_greek_conceal()
  vim.opt.conceallevel = M.config.conceallevel
  vim.opt.concealcursor = M.config.concealcursor

  for name, sym in pairs(M.greek_vars) do
    local pattern = [[\<]] .. name .. [[\>]]
    local cmd = string.format(
      -- Add "contains=@NoSpell" so it doesn't break search or spell
      -- and use "concealends" so highlighting still applies to the whole word
      "syntax match GreekVar_%s /%s/ conceal concealends cchar=%s contains=@NoSpell",
      name,
      pattern,
      sym
    )
    vim.cmd(cmd)

    -- Make sure the highlight group doesn't override Search highlight
    vim.api.nvim_set_hl(0, "GreekVar_" .. name, { link = "Normal" })
  end
end

-- Toggle conceal visibility
function M.toggle()
  if vim.opt.conceallevel:get() > 0 then
    vim.opt.conceallevel = 0
    print "Greek conceal disabled"
  else
    vim.opt.conceallevel = M.config.conceallevel
    print "Greek conceal enabled"
  end
end

-- Setup the plugin
function M.setup(opts)
  -- Merge user config with defaults
  if opts then
    M.config = vim.tbl_deep_extend("force", M.config, opts)
  end

  -- Disable conceal while searching so highlights show
  vim.api.nvim_create_autocmd({ "CmdlineEnter" }, {
    pattern = { "/", "?" },
    callback = function()
      vim.opt.conceallevel = 0
    end,
  })

  -- Restore conceal after leaving search
  vim.api.nvim_create_autocmd({ "CmdlineLeave" }, {
    pattern = { "/", "?" },
    callback = function()
      vim.opt.conceallevel = M.config.conceallevel
    end,
  })

  -- Setup conceal for configured file types
  vim.api.nvim_create_autocmd("FileType", {
    pattern = M.config.filetypes,
    callback = setup_greek_conceal,
  })

  -- Create toggle command
  vim.api.nvim_create_user_command("GreekVarsToggle", M.toggle, {})
end

return M
