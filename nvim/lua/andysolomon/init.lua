require('andysolomon.keymaps')
print('hello from andy')
require('andysolomon.set')

vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
    pattern = "*.cls",
    command = "set filetype=java"
})
