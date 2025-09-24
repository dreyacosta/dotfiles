return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = { enabled = false },
      servers = {
        eslint = {
          settings = {
            -- helps eslint find the eslintrc when it's placed in a subfolder instead of the cwd root
            workingDirectory = { mode = "auto" },
          },
        },
        vim.lsp.enable("cspell_ls"),
        vim.lsp.config("cspell_ls", {
          cmd = { "cspell-lsp", "--stdio" },
          filetypes = {
            "lua",
            "python",
            "javascript",
            "typescript",
            "html",
            "css",
            "json",
            "yaml",
            "markdown",
            "gitcommit",
          },
          root_markers = { ".git" },
        }),
      },
      setup = {
        eslint = function()
          -- automatically fix linting errors on save (but only if an eslint config file exists in project)
          local function has_eslint_config()
            local config_files = {
              ".eslintrc",
              ".eslintrc.js",
              ".eslintrc.json",
              ".eslintrc.cjs",
              ".eslintrc.yaml",
              ".eslintrc.yml",
              "eslint.config.mjs",
              "package.json",
            }
            local cwd = vim.loop.cwd()
            for _, fname in ipairs(config_files) do
              local full_path = cwd .. "/" .. fname
              local stat = vim.loop.fs_stat(full_path)
              if stat then
                if fname == "package.json" then
                  local file = io.open(full_path, "r")
                  if file then
                    local content = file:read("*a")
                    file:close()
                    if content:find('"eslintConfig"') then
                      return true
                    end
                  end
                else
                  return true
                end
              end
            end
            return false
          end

          if has_eslint_config() then
            vim.api.nvim_create_autocmd("BufWritePre", {
              pattern = { "*.tsx", "*.ts", "*.jsx", "*.js" },
              command = "LspEslintFixAll",
            })
          end
        end,
      },
    },
  },
}
