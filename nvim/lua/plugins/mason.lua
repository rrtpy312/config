return {
  -- 1. Mason first
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },
  
  -- 2. LSP Config
  {
    "neovim/nvim-lspconfig",
  },
  
  -- 3. Mason-LSPConfig bridge (depends on both above)
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig"
    },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "marksman" }, -- Add this line
        handlers = {
          function(server_name)
            require('lspconfig')[server_name].setup({
              capabilities = require('blink.cmp').get_lsp_capabilities(),
            })
          end,
        }
      })
    end,
  },
}
