-- Adapted from paulbkim-dev/vim-herdr-navigation (Apache-2.0), commit
-- 820d48f5d9c9a7dece6a4bebfa3982ec30bbfbb7.

local function nav(wincmd, direction)
  local previous_window = vim.api.nvim_get_current_win()
  vim.cmd("wincmd " .. wincmd)
  if vim.api.nvim_get_current_win() ~= previous_window then
    return
  end

  if vim.env.HERDR_PANE_ID and vim.env.HERDR_PANE_ID ~= "" then
    local herdr = vim.env.HERDR_BIN_PATH
    if herdr == nil or herdr == "" then
      herdr = "herdr"
    end
    vim.fn.system({ herdr, "pane", "focus", "--direction", direction, "--pane", vim.env.HERDR_PANE_ID })
  elseif vim.env.TMUX and vim.env.TMUX ~= "" then
    local tmux_directions = { left = "Left", down = "Down", up = "Up", right = "Right" }
    pcall(vim.cmd, "TmuxNavigate" .. tmux_directions[direction])
  end
end

local function map(key, wincmd, direction, description)
  vim.keymap.set("n", key, function()
    nav(wincmd, direction)
  end, { silent = true, noremap = true, desc = description })
end

map("<C-h>", "h", "left", "Navigate left (vim/herdr)")
map("<C-j>", "j", "down", "Navigate down (vim/herdr)")
map("<C-k>", "k", "up", "Navigate up (vim/herdr)")
map("<C-l>", "l", "right", "Navigate right (vim/herdr)")
