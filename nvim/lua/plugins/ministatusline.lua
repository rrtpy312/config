return {
  { "nvim-tree/nvim-web-devicons", lazy = true },
  {
    "echasnovski/mini.statusline",
    dependencies = { "nvim-web-devicons" },
    config = function()
      require("mini.statusline").setup({
        content = {
          active = function()
            local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
            local filename = vim.fn.expand('%:~')
            local devicons = require('nvim-web-devicons')
            local icon = devicons.get_icon_by_filetype(vim.bo.filetype) or ""
            local filetype_with_icon = icon .. " " .. vim.bo.filetype
            
            if vim.bo.filetype == "markdown" then
              local words = vim.fn.wordcount().words .. ":" .. vim.fn.wordcount().chars
              return MiniStatusline.combine_groups({
                { hl = mode_hl, strings = { mode } },
                { hl = 'MiniStatuslineFilename', strings = { filename } },
                '%=',
                { hl = 'MiniStatuslineFileinfo', strings = { filetype_with_icon } },
                { hl = mode_hl, strings = { words } },
              })
            else
              local git = MiniStatusline.section_git({ trunc_width = 75 })
              local diagnostics = MiniStatusline.section_diagnostics({ trunc_width = 75 })
              local line_col = vim.fn.line('.') .. ':' .. vim.fn.col('.')
              return MiniStatusline.combine_groups({
                { hl = mode_hl, strings = { mode } },
                { hl = 'MiniStatuslineDevinfo', strings = { git, diagnostics } },
                '%<',
                { hl = 'MiniStatuslineFilename', strings = { filename } },
                '%=',
                { hl = 'MiniStatuslineFileinfo', strings = { filetype_with_icon } },
                { hl = mode_hl, strings = { line_col } },
              })
            end
          end,
        },
      })
    end,
  },
}
