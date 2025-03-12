vim.opt.number = true

vim.opt.relativenumber = true

vim.g.mapleader = ' '

vim.keymap.set('n', '<leader>pv', ':Ex<CR>', {noremap = true, silent = true, desc = 'Open netrw'})

vim.cmd [[
call plug#begin('~/.config/nvim/plugged')
Plug 'catppuccin/nvim', { 'as': 'catppuccin' }
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
call plug#end()
]]
require('catppuccin').setup({
  flavour = 'mocha',
  transparent_background = false,
  term_colors = true,
})
vim.cmd 'colorscheme catppuccin'
require('nvim-treesitter.configs').setup {
  ensure_installed = { 'c', 'cpp', 'rust' },
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
}
