vim.opt.number = true

vim.opt.relativenumber = true

vim.g.mapleader = ' '

vim.keymap.set('n', '<leader>pv', ':Ex<CR>', {noremap = true, silent = true, desc = 'Open netrw'})

vim.cmd [[
call plug#begin('~/.config/nvim/plugged')
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'ThePrimeagen/harpoon'
Plug 'nvim-lua/plenary.nvim'
Plug 'deviantfero/wpgtk.vim'
call plug#end()
]]

vim.o.termguicolors = true          -- enable GUI colors in the TUI 
vim.env.NVIM_TUI_ENABLE_TRUE_COLOR = 1  -- ensure legacy support if needed
vim.cmd('colorscheme wpgtk')   -- or "wpgtkAlt"

vim.cmd [[
  highlight Normal   guibg=NONE ctermbg=NONE
  highlight NonText  guibg=NONE ctermbg=NONE
]]

require('nvim-treesitter.configs').setup {
  ensure_installed = { 'c', 'cpp', 'rust' },
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
}


vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.smartindent = true

local harpoon_mark = require("harpoon.mark")
local harpoon_ui = require("harpoon.ui")

-- Add current file to Harpoon list
vim.keymap.set("n", "<leader>a", harpoon_mark.add_file, { desc = "Add file to Harpoon" })

-- Toggle Harpoon quick menu
vim.keymap.set("n", "<leader>o", harpoon_ui.toggle_quick_menu, { desc = "Open Harpoon menu" })

-- Navigate to files 1-4 in Harpoon list
vim.keymap.set("n", "<C-h>", function() harpoon_ui.nav_file(1) end, { desc = "Go to Harpoon file 1" })
vim.keymap.set("n", "<C-j>", function() harpoon_ui.nav_file(2) end, { desc = "Go to Harpoon file 2" })
vim.keymap.set("n", "<C-k>", function() harpoon_ui.nav_file(3) end, { desc = "Go to Harpoon file 3" })
vim.keymap.set("n", "<C-l>", function() harpoon_ui.nav_file(4) end, { desc = "Go to Harpoon file 4" })


-- copy paste clipboard
vim.keymap.set("v", "<leader>y", '"+y', { desc = "Go to Harpoon file 1" })
vim.keymap.set("v", "<leader>p", '"+p', { desc = "Go to Harpoon file 1" })
