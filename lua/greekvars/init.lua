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

-- Namespace for extmarks
local ns = vim.api.nvim_create_namespace("greekvars_conceal")

-- Apply conceal extmarks to a buffer
local function apply_conceal_to_buffer(bufnr)
  -- Clear existing extmarks
  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
  
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  
  for lnum, line in ipairs(lines) do
    for name, sym in pairs(M.greek_vars) do
      local col = 0
      while true do
        local match_start, match_end = string.find(line, name, col + 1, true)
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
          
          -- Use virtual text with overlay position to replace text visually
          -- while preserving the highlight group
          vim.api.nvim_buf_set_extmark(bufnr, ns, row, col_start, {
            end_col = match_end,
            conceal = "",
            virt_text = {{sym, hl_group or "Normal"}},
            virt_text_pos = "overlay",
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
