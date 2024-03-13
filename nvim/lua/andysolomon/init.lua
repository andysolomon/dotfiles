require('andysolomon.keymaps')
require('andysolomon.set')

vim.api.nvim_create_user_command('DeployCurrentFile', function(args)
   -- Check if an environment argument is provided
  if args.args == nil or args.args == "" then
    -- Print a failure message to the Neovim command line
    vim.api.nvim_echo({{"No environment specified. Deployment failed.", "WarningMsg"}}, false, {})
    return -- Exit the function early
  end

  local environment = args.args
  local filePath = vim.fn.expand('%:p')
  vim.cmd('!sf project deploy start --source-dir ' .. filePath .. ' -o ' .. environment)
end, {nargs = 1})

vim.api.nvim_create_user_command('RetrieveCurrentFile', function(args)
   -- Check if an environment argument is provided
  if args.args == nil or args.args == "" then
    -- Print a failure message to the Neovim command line
    vim.api.nvim_echo({{"No environment specified. Deployment failed.", "WarningMsg"}}, false, {})
    return -- Exit the function early
  end

  local environment = args.args
  local filePath = vim.fn.expand('%:p')
  vim.cmd('!sf project retrieve start --source-dir ' .. filePath .. ' -o ' .. environment)
end, {nargs = 1})

-- Set the keybinding for DeployCurrentFile to <leader>df
vim.api.nvim_set_keymap('n', '<leader>df', ':DeployCurrentFile ', {noremap = true, silent = false})

-- Set the keybinding for RetrieveCurrentFile to <leader>rf
vim.api.nvim_set_keymap('n', '<leader>rf', ':RetrieveCurrentFile ', {noremap = true, silent = false})
