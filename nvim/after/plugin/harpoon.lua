local harpoon = require("harpoon")
local mark = require("harpoon.mark")
local ui = require("harpoon.ui")

-- Define the reorder function
local function remove_first_empty_mark()
    local marks = harpoon.get_mark_config().marks
    local found_empty = false

    for i = 1, #marks do
        if marks[i].filename == '(empty)' then
            table.remove(marks, i)
            found_empty = true
            break
        end
    end

    if found_empty then
       print('Reordered Harpoon List')
    end
end

local function add_file_and_remove_empty()
    mark.add_file()  -- This will add the file to harpoon marks.
    remove_first_empty_mark()  -- This will remove the first empty mark if it exists.
end

vim.keymap.set("n", "ha", add_file_and_remove_empty)
vim.keymap.set("n", "hd", mark.rm_file)
vim.keymap.set("n", "hc", mark.clear_all)
vim.keymap.set("n", "hn", ui.nav_next)
vim.keymap.set("n", "hp", ui.nav_prev)
vim.keymap.set("n", "<C-e>", ui.toggle_quick_menu)

vim.keymap.set("n", "<C-h>", function() ui.nav_file(1) end)
vim.keymap.set("n", "<C-t>", function() ui.nav_file(2) end)
vim.keymap.set("n", "<C-n>", function() ui.nav_file(3) end)
vim.keymap.set("n", "<C-s>", function() ui.nav_file(4) end)

vim.keymap.set("n", "hr", remove_first_empty_mark, { silent = true, noremap = true })
