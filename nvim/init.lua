require("config.lazy")


vim.opt.number = true-- numbers
vim.opt.relativenumber = true
vim.opt.spell = true
vim.opt.spelllang = "en_us"

vim.g.mapleader = " "

-- Add this to your init.lua instead
vim.keymap.set('n', '<leader>cc', function()
  local question = vim.fn.input('Ask Claude: ')
  if question ~= '' then
    local cmd = 'echo "' .. question .. '" | claude'
    vim.cmd('split | terminal ' .. cmd)
  end
end, { desc = 'Ask Claude' })



vim.opt.clipboard = "unnamedplus"
vim.g.clipboard = {
  name = 'win32yank-wsl',
  copy = {
    ['+'] = 'win32yank.exe -i --crlf',
    ['*'] = 'win32yank.exe -i --crlf',
  },
  paste = {
    ['+'] = 'win32yank.exe -o --lf',
    ['*'] = 'win32yank.exe -o --lf',
  },
  cache_enabled = 0,
}
