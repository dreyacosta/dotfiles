-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.relativenumber = false
vim.opt.colorcolumn = "80,100"
-- Use terminal clipboard copying in sessions without a desktop clipboard.
if not vim.env.WAYLAND_DISPLAY and not vim.env.DISPLAY and not vim.env.TMUX then
  local osc52 = require("vim.ui.clipboard.osc52")
  local last_yank = { {}, "v" }
  local function copy(register)
    return function(lines, regtype)
      last_yank = { vim.deepcopy(lines), regtype }
      osc52.copy(register)(lines, regtype)
    end
  end
  vim.g.clipboard = {
    name = "OSC 52 (copy with cached paste)",
    copy = { ["+"] = copy("+"), ["*"] = copy("*") },
    -- Avoid clipboard read queries, which Herdr may not answer.
    paste = {
      ["+"] = function() return last_yank end,
      ["*"] = function() return last_yank end,
    },
  }
end
vim.opt.clipboard = "unnamedplus"
vim.g.autoformat = false
vim.g.lazyvim_eslint_auto_format = true
vim.g.lazyvim_prettier_needs_config = true
vim.g.ai_cmp = true
