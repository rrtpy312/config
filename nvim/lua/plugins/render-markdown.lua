return {
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
  config = function()
    require('render-markdown').setup({
      -- Render in normal mode (not just in other modes)
      render_modes = { 'n', 'c' },
      -- Auto-enable when opening markdown files
      enabled = true,
    })
  end,
}
