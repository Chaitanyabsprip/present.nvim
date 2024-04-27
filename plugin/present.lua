if not vim.api.nvim_has_feature 'nvim-0.5' then
  vim.api.nvim_echo(
    { { 'Present needs Neovim >= 0.5', 'WarningMsg' } },
    true,
    {}
  )
  return
end

vim.api.nvim_create_user_command('Present', function()
  require('present').present()
end, { desc = 'Toggle Presentation view' })
vim.api.nvim_create_user_command('PresentEnable', function()
  require('present').present(true)
end, { desc = 'Enable Presentation view' })
vim.api.nvim_create_user_command('PresentDisable', function()
  require('present').present(false)
end, { desc = 'Disable Presentation view' })
