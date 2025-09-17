return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "markdown", "markdown_inline", "lua" },
        highlight = { 
          enable = true,
          -- Add this for zk wiki-links [[]] to work properly
          additional_vim_regex_highlighting = { "markdown" }
        },
      })
    end,
  },
}