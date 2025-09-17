return {
  "nvimdev/dashboard-nvim",
  config = function()
    require("dashboard").setup({
      theme = "doom",
      config = {
        header = {
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          " ███╗   ██╗ ██████╗ ████████╗███████╗███████╗",
          " ████╗  ██║██╔═══██╗╚══██╔══╝██╔════╝██╔════╝",
          " ██╔██╗ ██║██║   ██║   ██║   █████╗  ███████╗", 
          " ██║╚██╗██║██║   ██║   ██║   ██╔══╝  ╚════██║",
          " ██║ ╚████║╚██████╔╝   ██║   ███████╗███████║",
          " ╚═╝  ╚═══╝ ╚═════╝    ╚═╝   ╚══════╝╚══════╝",
          "",
          ""
        },
        center = {
          { 
            icon = "", 
            desc = "✨  Create new note    <leader>zc", 
            action = "lua vim.ui.input({ prompt = 'Title: ' }, function(title) if not title or title == '' then return end; local filename = title:gsub('[^%w%s%-_]', ''):gsub('%s+', '-'):lower(); local filepath = vim.fn.expand('~/notes') .. '/' .. filename .. '.md'; if vim.fn.filereadable(filepath) == 1 then vim.notify('File already exists: ' .. filename .. '.md', vim.log.levels.WARN); return end; local content = { '# ' .. title, '', '' }; vim.fn.writefile(content, filepath); vim.cmd('edit ' .. filepath); vim.api.nvim_win_set_cursor(0, {3, 0}); vim.notify('Created note: ' .. title, vim.log.levels.INFO) end)"
          },
          { 
            icon = "", 
            desc = "📄  Find by name       <leader>fn", 
            action = "Telescope find_files cwd=~/notes hidden=false"
          },
          { 
            icon = "", 
            desc = "🔍  Search content     <leader>fw", 
            action = "Telescope current_buffer_fuzzy_find previewer=false"
          },
          { 
            icon = "", 
            desc = "🏷️   Find tags          <leader>ft", 
            action = "lua require('telescope.builtin').live_grep({ default_text = '#', prompt_title = 'Find Tags', type_filter = 'md', cwd = vim.fn.expand('~/notes') })"
          },
          { 
            icon = "", 
            desc = "🔗  Find backlinks     <leader>fb", 
            action = "lua local current_file = vim.fn.expand('%:t:r'); if current_file ~= '' then require('telescope.builtin').live_grep({ default_text = current_file, prompt_title = 'Find Backlinks: ' .. current_file, type_filter = 'md', cwd = vim.fn.expand('~/notes') }) else vim.notify('No current file to find backlinks for', vim.log.levels.WARN) end"
          },
          { 
            icon = "", 
            desc = "📁  Browse files       <leader>fe", 
            action = "lua require('mini.files').open(vim.fn.expand('~/notes'))"
          },
          { 
            icon = "", 
            desc = "⏰  Recent files       <leader>fr", 
            action = "Telescope oldfiles"
          },
          { 
            icon = "", 
            desc = "❌  Quit               :qa", 
            action = "qa"
          }
        },
        footer = {},
        disable_move = false
      },
      hide = {
        statusline = true,
        tabline = true,
        winbar = true
      }
    })
  end
}