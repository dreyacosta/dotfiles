return {
  "pwntester/octo.nvim",
  cmd = "Octo",
  opts = {
    -- or "fzf-lua" or "snacks" or "default"
    picker = "telescope",
    -- bare Octo command opens picker of commands
    enable_builtin = true,
    use_local_fs = true,
    submit_win = {
      approve_review = { lhs = "<C-S-a>", desc = "approve review", mode = { "n", "i" } },
      comment_review = { lhs = "<C-m>", desc = "comment review", mode = { "n", "i" } },
      request_changes = { lhs = "<C-r>", desc = "request changes review", mode = { "n", "i" } },
      close_review_tab = { lhs = "<C-c>", desc = "close review tab", mode = { "n", "i" } },
    },
  },
  keys = {
    {
      "<leader>oi",
      "<CMD>Octo issue list<CR>",
      desc = "List GitHub Issues",
    },
    {
      "<leader>op",
      "<CMD>Octo pr list<CR>",
      desc = "List GitHub PullRequests",
    },
    {
      "<leader>od",
      "<CMD>Octo discussion list<CR>",
      desc = "List GitHub Discussions",
    },
    {
      "<leader>on",
      "<CMD>Octo notification list<CR>",
      desc = "List GitHub Notifications",
    },
    {
      "<leader>os",
      function()
        require("octo.utils").create_base_search_command({ include_current_repo = true })
      end,
      desc = "Search GitHub",
    },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
    -- OR "ibhagwan/fzf-lua",
    -- OR "folke/snacks.nvim",
    "folke/snacks.nvim",
    "nvim-tree/nvim-web-devicons",
  },
}
