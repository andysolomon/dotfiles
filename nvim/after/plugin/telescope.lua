local builtin = require('telescope.builtin')

vim.keymap.set('n', '<Leader>os', function()
  builtin.find_files({prompt_title = '< Search in .sfdx >', cwd = './.sfdx/tools/sobjects'})
end, {noremap = true, silent = true, desc = '[O]bject [S]earch'})

vim.keymap.set('n', '<Leader>og', function()
  builtin.live_grep({prompt_title = '< Live Grep in .sfdx >', cwd = './.sfdx/tools/sobjects'})
end, {noremap = true, silent = true, desc = '[O]bject [G]rep'})
