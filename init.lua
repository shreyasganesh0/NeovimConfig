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
Plug 'arizzoni/wal.nvim'
Plug 'rebelot/kanagawa.nvim'
Plug 'numToStr/Comment.nvim'
call plug#end()
]]

require('Comment').setup()

-- Default options:
require('kanagawa').setup({
    compile = false,             -- enable compiling the colorscheme
    undercurl = true,            -- enable undercurls
    commentStyle = { italic = true },
    functionStyle = {},
    keywordStyle = { italic = true},
    statementStyle = { bold = true },
    typeStyle = {},
    transparent = false,         -- do not set background color
    dimInactive = false,         -- dim inactive window `:h hl-NormalNC`
    terminalColors = true,       -- define vim.g.terminal_color_{0,17}
    colors = {                   -- add/modify theme and palette colors
        palette = {},
        theme = { wave = {}, lotus = {}, dragon = {}, all = {} },
    },
    overrides = function(colors) -- add/modify highlights
        return {}
    end,
    theme = "wave",              -- Load "wave" theme
    background = {               -- map the value of 'background' option to a theme
        dark = "wave",           -- try "dragon" !
        light = "lotus"
    },
})

-- setup must be called before loading
vim.cmd("colorscheme kanagawa")

vim.o.termguicolors = true          -- enable GUI colors in the TUI 
vim.env.NVIM_TUI_ENABLE_TRUE_COLOR = 1  -- ensure legacy support if needed
-- vim.g.wal_path = os.getenv("HOME") .. "/.cache/wal/colors.json"
vim.cmd('colorscheme kanagawa')   -- or "wpgtkAlt"

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
