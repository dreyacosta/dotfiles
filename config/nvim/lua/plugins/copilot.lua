return {
  {
    "zbirenbaum/copilot.lua",
    enabled = vim.g.ai_cmp,
    opts = {
      logger = {
        file = vim.fn.stdpath("log") .. "/copilot-lua.log",
        file_log_level = vim.log.levels.DEBUG,
        print_log_level = vim.log.levels.WARN,
        trace_lsp = "verbose",
        trace_lsp_progress = true,
        log_lsp_messages = true,
      },
      suggestion = {
        enabled = true,
        auto_trigger = true,
        hide_during_completion = false,
        keymap = { accept = "<Tab>" },
      },
      filetypes = {
        markdown = true,
      },
    },
  },
}
