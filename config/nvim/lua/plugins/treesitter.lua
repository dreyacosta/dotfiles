return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  event = "BufReadPost",
  opts = {
    highlight = { enable = true },
    ensure_installed = {
      "lua",
      "javascript",
      "typescript",
      "html",
      "css",
      "sql",
      "prisma",
      "yaml",
      "go",
      "json",
      "vimdoc",
      "markdown",
      "markdown_inline",
    },
    ident = { enable = true },
  },
}
