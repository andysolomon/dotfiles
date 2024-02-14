local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
parser_config.apex = {
  install_info = {
    url = "~/tree-sitter-apex/", -- local path or git repo
    files = {"src/parser.c"}
  },
  filetype = "apexcode", -- if filetype does not agrees with parser name
}
