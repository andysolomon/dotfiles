local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
vim.filetype = on

vim.filetype.add({
  extension = {
    cls = 'java',
    apex = 'apex',
    trigger = 'apexcode',
    soql = 'soql',
    sosl = 'sosl',
  }
})
