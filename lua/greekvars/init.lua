local M = {}

-- Greek letter mappings
M.greek_vars = {
  -- Lowercase Greek letters
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
  -- Uppercase Greek letters
  ALPHA = "Α",
  BETA = "Β",
  GAMMA = "Γ",
  DELTA = "Δ",
  EPSILON = "Ε",
  ZETA = "Ζ",
  ETA = "Η",
  THETA = "Θ",
  IOTA = "Ι",
  KAPPA = "Κ",
  LAMBDA = "Λ",
  MU = "Μ",
  NU = "Ν",
  XI = "Ξ",
  OMICRON = "Ο",
  PI = "Π",
  RHO = "Ρ",
  SIGMA = "Σ",
  TAU = "Τ",
  UPSILON = "Υ",
  PHI = "Φ",
  CHI = "Χ",
  PSI = "Ψ",
  OMEGA = "Ω",
}

-- Default configuration
M.config = {
  conceallevel = 2,
  concealcursor = "nc",
  filetypes = { "lua", "python", "javascript", "typescript", "c", "cpp" },
  case_sensitive = true,    -- Whether matching is case sensitive
  case_preference = "lower", -- When case_sensitive is false, prefer "lower" or "upper" case symbols
}

-- Namespace for extmarks
local ns = vim.api.nvim_create_namespace("greekvars_conceal")

-- Apply conceal extmarks to a buffer
local function apply_conceal_to_buffer(bufnr)
  -- Clear existing extmarks
  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
  
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  
  -- Build search patterns based on case sensitivity setting
  local patterns_to_search = {}
  
  if M.config.case_sensitive then
    -- Case sensitive: use greek_vars as-is
    for name, sym in pairs(M.greek_vars) do
      table.insert(patterns_to_search, { pattern = name, symbol = sym })
    end
  else
    -- Case insensitive: for each key, check both cases and prefer based on case_preference
    local processed = {}
    for name, sym in pairs(M.greek_vars) do
      local lower_name = string.lower(name)
      if not processed[lower_name] then
        processed[lower_name] = true
        
        -- Determine which symbol to use based on preference
        local preferred_sym = sym
        if M.config.case_preference == "upper" then
          -- Try to find uppercase version
          local upper_name = string.upper(name)
          if M.greek_vars[upper_name] then
            preferred_sym = M.greek_vars[upper_name]
          end
        else
          -- Try to find lowercase version (default)
          if M.greek_vars[lower_name] then
            preferred_sym = M.greek_vars[lower_name]
          end
        end
        
        table.insert(patterns_to_search, { pattern = lower_name, symbol = preferred_sym, case_insensitive = true })
      end
    end
  end
  
  for lnum, line in ipairs(lines) do
    for _, pattern_info in ipairs(patterns_to_search) do
      local name = pattern_info.pattern
      local sym = pattern_info.symbol
      local case_insensitive = pattern_info.case_insensitive or false
      
      local col = 0
      while true do
        local match_start, match_end
        
        if case_insensitive then
          -- Case insensitive search: convert line to lowercase for matching
          local line_lower = string.lower(line)
          match_start, match_end = string.find(line_lower, name, col + 1, true)
        else
          -- Case sensitive search
          match_start, match_end = string.find(line, name, col + 1, true)
        end
        
        if not match_start then break end
        
        -- Check word boundaries manually
        local before_ok = match_start == 1 or not string.match(string.sub(line, match_start - 1, match_start - 1), "[%w_]")
        local after_ok = match_end == #line or not string.match(string.sub(line, match_end + 1, match_end + 1), "[%w_]")
        
        if before_ok and after_ok then
          -- Get treesitter highlight group at this position
          local row, col_start = lnum - 1, match_start - 1
          local hl_group = nil
          
          -- Try to get highlight from treesitter
          local ok, captures = pcall(vim.treesitter.get_captures_at_pos, bufnr, row, col_start)
          if ok and captures and #captures > 0 then
            -- Get the last (most specific) capture's highlight group
            hl_group = "@" .. captures[#captures].capture
          end
          
          -- Apply extmark with conceal that preserves treesitter highlighting
          -- The hl_group parameter applies to the concealed character
          vim.api.nvim_buf_set_extmark(bufnr, ns, row, col_start, {
            end_col = match_end,
            conceal = sym,
            hl_group = hl_group or "Normal",
          })
        end
        
        col = match_end
      end
    end
  end
end

-- Setup conceal for Greek variables
local function setup_greek_conceal()
  vim.opt.conceallevel = M.config.conceallevel
  vim.opt.concealcursor = M.config.concealcursor

  local bufnr = vim.api.nvim_get_current_buf()
  
  -- Apply conceal immediately
  apply_conceal_to_buffer(bufnr)
  
  -- Reapply on text changes
  vim.api.nvim_buf_attach(bufnr, false, {
    on_lines = function()
      -- Debounce using vim.defer_fn to avoid too many updates
      vim.defer_fn(function()
        if vim.api.nvim_buf_is_valid(bufnr) then
          apply_conceal_to_buffer(bufnr)
        end
      end, 100)
    end,
  })
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
    
    -- Handle greek_vars customization
    if opts.greek_vars then
      -- Merge user-provided greek_vars with defaults
      M.greek_vars = vim.tbl_deep_extend("force", M.greek_vars, opts.greek_vars)
      
      -- Remove entries that user set to false or vim.NIL
      for key, value in pairs(M.greek_vars) do
        if value == false or value == vim.NIL then
          M.greek_vars[key] = nil
        end
      end
    end
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
