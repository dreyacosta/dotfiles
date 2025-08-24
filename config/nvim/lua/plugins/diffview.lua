return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles" },
  keys = {
    {
      "<leader>go",
      function()
        local function open_for(branch)
          if branch and branch ~= "" then
            vim.cmd("DiffviewOpen " .. branch .. "...HEAD")
          end
        end

        local ok, builtin = pcall(require, "telescope.builtin")
        if ok then
          builtin.git_branches({
            attach_mappings = function(_, map)
              local actions = require("telescope.actions")
              local action_state = require("telescope.actions.state")
              local function confirm(prompt_bufnr)
                local entry = action_state.get_selected_entry()
                actions.close(prompt_bufnr)
                open_for(entry.value)
              end
              map("i", "<CR>", confirm)
              map("n", "<CR>", confirm)
              return true
            end,
          })
        else
          local default = "origin/main"
          local branch = vim.fn.input("Diff against branch: ", default)
          open_for(branch)
        end
      end,
      desc = "Diffview: open against chosen branch",
    },
    { "<leader>gq", "<cmd>DiffviewClose<CR>", desc = "Diffview: close" },
  },
}
