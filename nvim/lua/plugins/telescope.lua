return {
  "nvim-telescope/telescope.nvim",
  dependencies = { 
    "nvim-lua/plenary.nvim",
    "echasnovski/mini.files",
  },
  config = function()
    local telescope = require("telescope")
    local builtin = require("telescope.builtin")
    
    -- Setup mini.files with persistent behavior
    require("mini.files").setup({
      windows = {
        preview = true, -- Enable preview
        width_focus = 30,
        width_nofocus = 15,
        width_preview = 50,
      },
      options = {
        permanent_delete = false,
        use_as_default_explorer = false,
      },
      mappings = {
        close       = '',    -- Disable default close mapping
        go_in       = 'l',   -- Enter directory/open file
        go_in_plus  = 'L',   -- Enter directory/open file and close mini.files
        go_out      = 'h',   -- Go to parent directory
        go_out_plus = 'H',   -- Go to parent directory and close mini.files
        reset       = '<BS>',
        reveal_cwd  = '@',
        show_help   = 'g?',
        synchronize = '=',
        trim_left   = '<',
        trim_right  = '>',
      },
    })
    
    -- Custom function to setup mini.files keymaps after opening
    local function setup_minifiles_keymaps(buf_id)
      local map_split = function(buf_id, lhs, direction)
        local rhs = function()
          local new_target_window
          vim.api.nvim_win_call(MiniFiles.get_target_window() or 0, function()
            vim.cmd(direction .. ' split')
            new_target_window = vim.api.nvim_get_current_win()
          end)
          MiniFiles.set_target_window(new_target_window)
          MiniFiles.go_in({ close_on_file = false })  -- Don't close when opening file
        end
        vim.keymap.set('n', lhs, rhs, { buffer = buf_id, desc = 'Split ' .. direction })
      end

      local map = function(buf_id, lhs, rhs, desc)
        vim.keymap.set('n', lhs, rhs, { buffer = buf_id, desc = desc })
      end

      -- Add split mappings that don't close mini.files
      map_split(buf_id, '<C-s>', 'belowright horizontal')
      map_split(buf_id, '<C-v>', 'belowright vertical')
      
      -- Only these keys will close mini.files
      map(buf_id, 'q', function() 
        MiniFiles.close()
      end, 'Close mini.files')
      
      map(buf_id, '<C-c>', function() 
        MiniFiles.close()
      end, 'Close mini.files')
      
      -- Override Enter to not close mini.files when opening files
      map(buf_id, '<CR>', function()
        MiniFiles.go_in({ close_on_file = false })
      end, 'Open file/directory (keep mini.files open)')
    end

    -- Setup autocommand to apply custom keymaps when mini.files opens
    vim.api.nvim_create_autocmd('User', {
      pattern = 'MiniFilesBufferCreate',
      callback = function(args)
        setup_minifiles_keymaps(args.data.buf_id)
      end,
    })
    
    -- Setup telescope
    telescope.setup({
      defaults = {
        file_ignore_patterns = { "node_modules", ".git/" },
      },
      pickers = {
        find_files = {
          find_command = { "fdfind", "--type", "f", "--hidden", "--follow" },
        },
      },
    })
    
    local notes_dir = "/mnt/d/notes"
    
    -- Create note with selected template
    local function create_note_with_template(template_name, target_dir)
      vim.ui.input({ prompt = "Title: " }, function(title)
        if not title or title == "" then
          return
        end
        
        -- Clean title for filename
        local filename = title:gsub("[^%w%s%-_]", ""):gsub("%s+", "-"):lower()
        local filepath = target_dir .. "/" .. filename .. ".md"
        
        -- Check if file already exists
        if vim.fn.filereadable(filepath) == 1 then
          vim.notify("File already exists: " .. filename .. ".md", vim.log.levels.WARN)
          return
        end
        
        -- Read the selected template
        local template_path = vim.fn.expand(notes_dir) .. "/templates/" .. template_name .. ".md"
        
        if vim.fn.filereadable(template_path) == 1 then
          local content = vim.fn.readfile(template_path)
          
          -- Replace variables in each line
          for i, line in ipairs(content) do
            content[i] = line:gsub("{{title}}", title)
            content[i] = content[i]:gsub("{{date}}", os.date("%Y-%m-%d"))
            content[i] = content[i]:gsub("{{time}}", os.date("%H:%M"))
            content[i] = content[i]:gsub("{{datetime}}", os.date("%Y-%m-%d %H:%M"))
            content[i] = content[i]:gsub("{{filename}}", filename)
          end
          
          -- Write and open the file
          vim.fn.writefile(content, filepath)
          vim.cmd("edit " .. filepath)
          vim.api.nvim_win_set_cursor(0, {#content, 0})
          vim.notify("Created note: " .. title .. " (using " .. template_name .. ") in " .. vim.fn.fnamemodify(target_dir, ":~"), vim.log.levels.INFO)
        else
          vim.notify("Template not found: " .. template_name .. ".md", vim.log.levels.ERROR)
        end
      end)
    end
    
    -- Fallback when no templates exist
    local function create_note_with_fallback()
      vim.ui.input({ prompt = "Title: " }, function(title)
        if not title or title == "" then
          return
        end
        
        local filename = title:gsub("[^%w%s%-_]", ""):gsub("%s+", "-"):lower()
        local filepath = vim.fn.expand(notes_dir) .. "/" .. filename .. ".md"
        
        if vim.fn.filereadable(filepath) == 1 then
          vim.notify("File already exists: " .. filename .. ".md", vim.log.levels.WARN)
          return
        end
        
        local content = {
          "# " .. title,
          "",
          "**Created:** " .. os.date("%Y-%m-%d %H:%M"),
          "**Tags:** ",
          "",
          ""
        }
        
        vim.fn.writefile(content, filepath)
        vim.cmd("edit " .. filepath)
        vim.api.nvim_win_set_cursor(0, {#content, 0})
        vim.notify("Created note: " .. title .. " (no templates found)", vim.log.levels.INFO)
      end)
    end
    
    -- Search in notes directory only (FAST)
    vim.keymap.set("n", "<leader>fn", function()
      builtin.find_files({ 
        prompt_title = "Find Notes",
        cwd = notes_dir, -- Notes directory only
        hidden = false, -- Skip hidden files for speed
      })
    end, { desc = "Find Notes" })
    
    -- Search only in current open file (NO PREVIEW)
    vim.keymap.set("n", "<leader>fw", function()
      builtin.current_buffer_fuzzy_find({ 
        prompt_title = "Search Words",
        previewer = false,  -- Remove the preview panel
      })
    end, { desc = "Search Words" })
    
    -- Search only in notes directory for tags
    vim.keymap.set("n", "<leader>ft", function()
      builtin.live_grep({
        default_text = "#",
        prompt_title = "Find Tags",
        type_filter = "md",
        cwd = notes_dir,  -- Only search in notes directory
      })
    end, { desc = "Find tags" })
    
    -- Find backlinks only in notes directory
    vim.keymap.set("n", "<leader>fb", function()
      local current_file = vim.fn.expand("%:t:r")  -- filename without extension
      builtin.live_grep({
        default_text = current_file,
        prompt_title = "Find Backlinks: " .. current_file,
        type_filter = "md",
        cwd = notes_dir,  -- Only search in notes directory
      })
    end, { desc = "Find Backlinks" })
    
    -- Recent files everywhere, all file types
    vim.keymap.set("n", "<leader>fr", function()
      local pickers = require("telescope.pickers")
      local finders = require("telescope.finders")
      local conf = require("telescope.config").values
      local actions = require("telescope.actions")
      local action_state = require("telescope.actions.state")
      
      builtin.oldfiles({
        prompt_title = "Recent Files",
        attach_mappings = function(prompt_bufnr, map)
          -- Add Ctrl+L to permanently clear recent files
          local clear_and_refresh = function()
            -- Clear the oldfiles list in current session
            vim.v.oldfiles = {}
            
            -- Write empty oldfiles to shada file to make it permanent
            vim.cmd("wshada!")
            
            -- Refresh the picker with empty list
            local current_picker = action_state.get_current_picker(prompt_bufnr)
            current_picker:refresh(finders.new_table({
              results = {},
              entry_maker = function(entry)
                return {
                  value = entry,
                  display = entry,
                  ordinal = entry,
                }
              end,
            }))
            vim.notify("Recent files permanently cleared!", vim.log.levels.INFO)
          end
          
          map("i", "<C-l>", clear_and_refresh)
          map("n", "<C-l>", clear_and_refresh)
          
          return true
        end,
      })
    end, { desc = "Recent files" })
    
    -- Smart file explorer - opens current file's directory, defaults to notes
    vim.keymap.set("n", "<leader>fe", function()
      local mini_files = require("mini.files")
      
      -- Get current buffer info
      local current_file = vim.api.nvim_buf_get_name(0)
      local buffer_type = vim.bo.buftype
      local file_type = vim.bo.filetype
      
      -- Check if we have a real file (not dashboard, empty buffer, etc.)
      local is_real_file = current_file ~= "" 
        and vim.fn.filereadable(current_file) == 1 
        and buffer_type == ""  -- Normal file buffer
        and file_type ~= "dashboard"  -- Not dashboard
      
      if is_real_file then
        -- Open the directory where the current file is located
        local current_dir = vim.fn.fnamemodify(current_file, ":p:h")
        mini_files.open(current_dir, false)
        vim.notify("Opening: " .. vim.fn.fnamemodify(current_dir, ":~"), vim.log.levels.INFO)
      else
        -- Default to notes directory for dashboard/empty buffers
        mini_files.open(notes_dir, false)
        vim.notify("Opening: " .. vim.fn.fnamemodify(vim.fn.expand(notes_dir), ":~"), vim.log.levels.INFO)
      end
    end, { desc = "Open file explorer (smart location)" })
    
    -- Separate keymap to always open notes directory
    vim.keymap.set("n", "<leader>fE", function()
      local mini_files = require("mini.files")
      mini_files.open(notes_dir, false)
    end, { desc = "Open notes file manager" })
    
    -- Create new note with auto-template based on directory
    vim.keymap.set("n", "<leader>zc", function()
      -- Get current directory
      local current_dir = vim.fn.expand("%:p:h")
      local notes_expanded = vim.fn.expand(notes_dir)
      
      -- Determine template and target directory based on current directory
      local template_name = "note" -- default
      local target_dir = notes_expanded .. "/main" -- default to main
      
      if string.find(current_dir, notes_expanded .. "/main") then
        template_name = "note"
        target_dir = notes_expanded .. "/main"
      elseif string.find(current_dir, notes_expanded .. "/source") then
        template_name = "source"
        target_dir = notes_expanded .. "/source"
      elseif current_dir == notes_expanded then
        -- If we're in the root notes directory, default to main
        template_name = "note"
        target_dir = notes_expanded .. "/main"
      end
      
      -- Ensure target directory exists
      if vim.fn.isdirectory(target_dir) == 0 then
        vim.fn.mkdir(target_dir, "p")
      end
      
      -- Create note with the determined template in the proper directory
      create_note_with_template(template_name, target_dir)
    end, { desc = "Create new note (auto-template)" })
    
    -- Improved Ctrl+C to close special windows with better error handling
    vim.keymap.set("n", "<C-c>", function()
      -- Check if we're in a telescope buffer
      if vim.bo.filetype == "TelescopePrompt" then
        -- Use the safer way to close telescope
        local ok, actions = pcall(require, "telescope.actions")
        if ok then
          actions.close(vim.api.nvim_get_current_buf())
        else
          vim.cmd("close")
        end
        return
      end
      
      -- Check if we're in mini.files
      if vim.bo.filetype == "minifiles" then
        require("mini.files").close()
        return
      end
      
      -- For everything else, try to close the window
      local ok, err = pcall(vim.cmd, "close")
      if not ok then
        -- If close fails (maybe last window), try quit
        local confirm = vim.fn.confirm("Close last window? This will exit Neovim.", "&Yes\n&No", 2)
        if confirm == 1 then
          vim.cmd("quit")
        end
      end
    end, { desc = "Close current window" })
    
    -- Note navigation commands
    -- gf - Go to file under cursor (enhanced for notes)
    vim.keymap.set("n", "gf", function()
      local word = vim.fn.expand("<cWORD>")
      
      -- Clean the word (remove punctuation, brackets, etc.)
      local filename = word:gsub("[%[%]%(%)%,%.]", ""):gsub("^%s+", ""):gsub("%s+$", "")
      
      -- Try different file extensions and locations
      local possible_paths = {
        notes_dir .. "/" .. filename .. ".md",
        notes_dir .. "/main/" .. filename .. ".md", 
        notes_dir .. "/source/" .. filename .. ".md",
        filename .. ".md",  -- relative to current directory
        filename,  -- exact filename
      }
      
      for _, path in ipairs(possible_paths) do
        if vim.fn.filereadable(vim.fn.expand(path)) == 1 then
          vim.cmd("edit " .. path)
          vim.notify("Opened: " .. vim.fn.fnamemodify(path, ":~"), vim.log.levels.INFO)
          return
        end
      end
      
      -- If file doesn't exist, offer to create it
      vim.ui.select({"Create in main/", "Create in source/", "Cancel"}, {
        prompt = "File '" .. filename .. ".md' not found. Create it?",
      }, function(choice)
        if choice == "Create in main/" then
          create_note_with_template("note", notes_dir .. "/main")
        elseif choice == "Create in source/" then
          create_note_with_template("source", notes_dir .. "/source") 
        end
      end)
    end, { desc = "Go to file under cursor (smart note navigation)" })
    
    -- gb - Go back to previous file
    vim.keymap.set("n", "gb", function()
      vim.cmd("buffer #")
    end, { desc = "Go back to previous buffer" })
    
    -- K - Show preview/hover info (enhanced for notes)
    vim.keymap.set("n", "K", function()
      local word = vim.fn.expand("<cWORD>")
      local filename = word:gsub("[%[%]%(%)%,%.]", ""):gsub("^%s+", ""):gsub("%s+$", "")
      
      -- Try to find and preview the file
      local possible_paths = {
        notes_dir .. "/" .. filename .. ".md",
        notes_dir .. "/main/" .. filename .. ".md",
        notes_dir .. "/source/" .. filename .. ".md",
      }
      
      for _, path in ipairs(possible_paths) do
        if vim.fn.filereadable(vim.fn.expand(path)) == 1 then
          -- Read first few lines of the file for preview
          local lines = vim.fn.readfile(vim.fn.expand(path), "", 10)
          local preview = table.concat(lines, "\n")
          
          -- Show preview in a floating window
          local buf = vim.api.nvim_create_buf(false, true)
          vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
          vim.api.nvim_buf_set_option(buf, 'filetype', 'markdown')
          
          local width = math.min(80, vim.o.columns - 4)
          local height = math.min(#lines + 2, 15)
          
          vim.api.nvim_open_win(buf, false, {
            relative = 'cursor',
            width = width,
            height = height,
            row = 1,
            col = 0,
            style = 'minimal',
            border = 'rounded',
            title = ' ' .. filename .. '.md ',
            title_pos = 'center',
          })
          
          return
        end
      end
      
      -- Fallback to default K behavior
      vim.cmd("normal! K")
    end, { desc = "Preview file under cursor or show help" })
    
  end,
}