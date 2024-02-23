vim.g.mapleader = ','
vim.keymap.set('n', '<Leader>pv', vim.cmd.Ex)
vim.keymap.set("n", "<Leader>o", "o<Esc>^Da")
vim.keymap.set("n", "te", ":tabedit")
vim.keymap.set('i', 'jk', '<Esc>')
vim.keymap.set('v', 'jk', '<Esc>')

-- Automatic Bracketing
vim.keymap.set('i', '(', '()<Esc>:let leavechar=")"<CR>i')
vim.keymap.set('i', "'", "''<Esc>:let leavechar=\"'\"<CR>i", { noremap = true })
vim.keymap.set('i', "`", "``<Esc>:let leavechar='`'<CR>i", { noremap = true })
vim.keymap.set('i', '[', '[]<Esc>:let leavechar="]"<CR>i', { noremap = true })
vim.keymap.set('i', '{', '{}<Esc>:let leavechar="}"<CR>i', { noremap = true })
vim.keymap.set('i', '"', '""<Esc>:let leavechar="""<CR>i', { noremap = true })

-- Manual Surronds
vim.keymap.set('n', '<leader>"', 'viw<esc>a"<esc>bi"<esc>lel', { noremap = true })
vim.keymap.set('n', "<leader>'", "viw<esc>a'<esc>bi'<esc>lel", { noremap = true })
vim.keymap.set('n', '<leader>`', 'viw<esc>a`<esc>bi`<esc>lel', { noremap = true })

-- Git
vim.api.nvim_create_user_command('LazyGit', function()
    vim.cmd('terminal lazygit')
    vim.cmd('startinsert')
end, {})
vim.keymap.set('n', '<leader>g', ':LazyGit<CR>', { noremap = true, silent = true })

-- Source MYVIMRC
vim.api.nvim_set_keymap('n', '<leader>sv', ':luafile $MYVIMRC<CR>', { noremap = true, silent = true })

