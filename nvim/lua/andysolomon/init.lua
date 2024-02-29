require('andysolomon.keymaps')
print('hello from andy')
require('andysolomon.set')

vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
    pattern = {"*.cls", "*.trigger"},
    command = "set filetype=java"
})

vim.api.nvim_create_user_command('DeployCurrentFile', function()
  vim.cmd('!sf project deploy start --source-path ' .. vim.fn.expand('%:p'))
end, {})
