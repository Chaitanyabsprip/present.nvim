local M = {}
local nnoremap = function(key)
  return function(cmd)
    return function(options)
      return function(description)
        options = vim.tbl_extend('keep', options or {}, { desc = description })
        return vim.api.nvim_set_keymap('n', key, cmd, options)
      end
    end
  end
end

local defaults = {
  default_mappings = true,
  kitty = {
    normal_font_size = 12,
    zoomed_font_size = 28,
  },
}

M.presenting = false
M.initial = {}
M.options = {}

M.setup = function(options)
  M.options = vim.tbl_deep_extend('force', {}, defaults, options or {})
end

M.kitty_resize_font = function(enable)
  if not vim.fn.executable 'kitty' then
    return
  end
  local cmd = 'kitty @ --to %s set-font-size %s'
  local socket = vim.fn.expand '$KITTY_LISTEN_ON'
  if enable then
    vim.fn.system(
      cmd:format(socket, string.format('%s', M.options.kitty.zoomed_font_size))
    )
  else
    vim.fn.system(
      cmd:format(socket, string.format('%s', M.options.kitty.normal_font_size))
    )
  end
  vim.cmd [[redraw]]
end

M.disable_ui = function(enable)
  if enable or not M.presenting then
    M.initial = {
      showtabline = vim.opt.showtabline,
      laststatus = vim.opt.laststatus,
      number = vim.opt.number,
      relativenumber = vim.opt.relativenumber,
      signcolumn = vim.opt.signcolumn,
      ruler = vim.opt.ruler,
    }
  end
  vim.opt.showtabline = 0
  vim.opt.laststatus = 1
  vim.cmd [[ echo '' ]]
  vim.opt.number = false
  vim.opt.relativenumber = false
  vim.opt.signcolumn = 'no'
  vim.opt.ruler = false
  if enable == nil or not enable then
    vim.opt.showtabline = M.initial.showtabline
    vim.opt.laststatus = M.initial.laststatus
    vim.opt.number = M.initial.number
    vim.opt.relativenumber = M.initial.relativenumber
    vim.opt.signcolumn = M.initial.signcolumn
    vim.opt.ruler = M.initial.ruler
  end
end

M.disable_markdown_format = function(enable)
  if enable then
    vim.cmd [[LspStop 1]]
  end
  vim.cmd [[LspStart]]
end

M.present = function(enable)
  if enable == nil then
    enable = not M.presenting
  end
  M.disable_ui(enable)
  M.disable_markdown_format(enable)
  if M.options.kitty ~= nil then
    M.kitty_resize_font(enable)
  end
  M.presenting = not M.presenting
  if M.options.default_mappings then
    local present = vim.api.nvim_create_augroup 'present'
    vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
      callback = function()
        require('present').keymaps()
        M.disable_ui(enable)
      end,
      group = present,
      pattern = 'slide.*',
    })
    local reset_present = vim.api.nvim_create_augroup 'reset_present'
    vim.api.nvim_create_autocmd({ 'VimLeavePre' }, {
      command = 'PresentDisable',
      group = reset_present,
      pattern = 'slide.*',
    })
  end
end

M.keymaps = function()
  nnoremap ']' ':bn<CR>' { bufnr = 0, silent = true } 'Next slide'
  nnoremap '[' ':bp<CR>' { bufnr = 0, silent = true } 'Previous slide'
end

return M
