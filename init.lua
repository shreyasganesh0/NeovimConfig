-- ~/.config/nvim/init.lua

-- Basic vim options
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.o.termguicolors = true
vim.env.NVIM_TUI_ENABLE_TRUE_COLOR = 1

-- Leader key
vim.g.mapleader = ' '

-- Plugin management
vim.cmd [[
call plug#begin('~/.config/nvim/plugged')
" Core plugins
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'ThePrimeagen/harpoon'
Plug 'nvim-lua/plenary.nvim'
Plug 'numToStr/Comment.nvim'

" Colorschemes
Plug 'deviantfero/wpgtk.vim'
Plug 'arizzoni/wal.nvim'
Plug 'rebelot/kanagawa.nvim'

" Java Development (loaded conditionally)
Plug 'mfussenegger/nvim-jdtls'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'L3MON4D3/LuaSnip'
Plug 'saadparwaiz1/cmp_luasnip'
Plug 'rafamadriz/friendly-snippets'
call plug#end()
]]

-- Core plugin setup
require('Comment').setup()

-- Profile system
local profiles = {
  default = function()
    -- Default treesitter setup
    require('nvim-treesitter.configs').setup {
      ensure_installed = { 'c', 'cpp', 'rust' },
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
    }
    print("Default profile loaded")
  end,

  java = function()
    -- Java-specific treesitter
    require('nvim-treesitter.configs').setup {
      ensure_installed = { 'c', 'cpp', 'rust', 'java', 'json', 'yaml' },
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
    }

    -- Setup completion
    local cmp = require('cmp')
    local luasnip = require('luasnip')
    
    cmp.setup({
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      mapping = cmp.mapping.preset.insert({
        ['<C-d>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
        ['<Tab>'] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          else
            fallback()
          end
        end, { 'i', 's' }),
      }),
      sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
        { name = 'buffer' },
        { name = 'path' },
      })
    })

    -- Load snippets
    require("luasnip.loaders.from_vscode").lazy_load()

    -- Java LSP setup
    local jdtls = require('jdtls')
    local home = os.getenv('HOME')
    local workspace_dir = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
    
    -- Find the correct launcher jar (resolve wildcard)
    local jdtls_path = home .. '/.local/share/nvim/mason/packages/jdtls'
    local launcher_jar = vim.fn.glob(jdtls_path .. '/plugins/org.eclipse.equinox.launcher_*.jar')
    
    -- Find the correct config directory for the platform
    local config_dir = ''
    for _, dir in ipairs({'config_mac_arm64', 'config_mac', 'config_linux'}) do
      local path = jdtls_path .. '/' .. dir
      if vim.fn.isdirectory(path) == 1 then
        config_dir = path
        break
      end
    end
    
    -- Check if JDTLS is properly installed
    if launcher_jar == '' or config_dir == '' then
      print("JDTLS not found or incomplete. Please run the installation script.")
      print("Launcher jar: " .. (launcher_jar ~= '' and launcher_jar or "NOT FOUND"))
      print("Config dir: " .. (config_dir ~= '' and config_dir or "NOT FOUND"))
      return
    end

    local config = {
      cmd = {
        'java',
        '-Declipse.application=org.eclipse.jdt.ls.core.id1',
        '-Dosgi.bundles.defaultStartLevel=4',
        '-Declipse.product=org.eclipse.jdt.ls.core.product',
        '-Dlog.protocol=true',
        '-Dlog.level=ALL',
        '-Xms1g',
        '--add-modules=ALL-SYSTEM',
        '--add-opens', 'java.base/java.util=ALL-UNNAMED',
        '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
        '-jar', launcher_jar,
        '-configuration', config_dir,
        '-data', home .. '/.cache/jdtls-workspace/' .. workspace_dir,
      },
      root_dir = require('jdtls.setup').find_root({'.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle'}),
      settings = {
        java = {
          eclipse = { downloadSources = true },
          configuration = { updateBuildConfiguration = "interactive" },
          maven = { downloadSources = true },
          implementationsCodeLens = { enabled = true },
          referencesCodeLens = { enabled = true },
          references = { includeDecompiledSources = true },
          format = { enabled = true },
        },
        signatureHelp = { enabled = true },
        completion = {
          favoriteStaticMembers = {
            "org.hamcrest.MatcherAssert.assertThat",
            "org.hamcrest.Matchers.*",
            "org.hamcrest.CoreMatchers.*",
            "org.junit.jupiter.api.Assertions.*",
            "java.util.Objects.requireNonNull",
            "java.util.Objects.requireNonNullElse",
            "org.mockito.Mockito.*"
          }
        },
        sources = {
          organizeImports = {
            starThreshold = 9999,
            staticStarThreshold = 9999,
          }
        },
        codeGeneration = {
          toString = {
            template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}"
          }
        },
      },
      capabilities = require('cmp_nvim_lsp').default_capabilities(),
      on_attach = function(client, bufnr)
        -- Java-specific keymaps
        local opts = { buffer = bufnr, silent = true }
        vim.keymap.set('n', '<leader>jo', function() jdtls.organize_imports() end, opts)
        vim.keymap.set('n', '<leader>jv', function() jdtls.extract_variable() end, opts)
        vim.keymap.set('v', '<leader>jv', function() jdtls.extract_variable(true) end, opts)
        vim.keymap.set('n', '<leader>jc', function() jdtls.extract_constant() end, opts)
        vim.keymap.set('v', '<leader>jc', function() jdtls.extract_constant(true) end, opts)
        vim.keymap.set('v', '<leader>jm', function() jdtls.extract_method(true) end, opts)
        vim.keymap.set('n', '<leader>jr', function() jdtls.code_action(false, 'refactor') end, opts)

        -- LSP keymaps
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
        vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
      end,
    }

    -- Auto-start JDTLS for Java files
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "java",
      callback = function()
        jdtls.start_or_attach(config)
      end
    })

    print("Java profile loaded - JDTLS will start when you open Java files")
  end,

  minimal = function()
    -- Minimal setup - just basic treesitter
    require('nvim-treesitter.configs').setup {
      ensure_installed = { 'c' },
      highlight = { enable = true },
    }
    print("Minimal profile loaded")
  end
}

-- Profile switching function
local current_profile = "default"
local function switch_profile(profile_name)
  if profiles[profile_name] then
    current_profile = profile_name
    profiles[profile_name]()
  else
    print("Profile '" .. profile_name .. "' not found")
    print("Available profiles: " .. table.concat(vim.tbl_keys(profiles), ", "))
  end
end

-- Profile keymaps
vim.keymap.set('n', '<leader>pd', function() switch_profile('default') end, { desc = "Switch to default profile" })
vim.keymap.set('n', '<leader>pj', function() switch_profile('java') end, { desc = "Switch to Java profile" })
vim.keymap.set('n', '<leader>pm', function() switch_profile('minimal') end, { desc = "Switch to minimal profile" })

-- Auto-detect and switch to Java profile for Java projects
local function auto_detect_profile()
  local cwd = vim.fn.getcwd()
  if vim.fn.glob(cwd .. "/*.java") ~= "" or 
     vim.fn.filereadable(cwd .. "/pom.xml") == 1 or
     vim.fn.filereadable(cwd .. "/build.gradle") == 1 then
    switch_profile('java')
  else
    switch_profile('default')
  end
end

-- Colorscheme setup
require('kanagawa').setup({
    compile = false,
    undercurl = true,
    commentStyle = { italic = true },
    functionStyle = {},
    keywordStyle = { italic = true},
    statementStyle = { bold = true },
    typeStyle = {},
    transparent = false,
    dimInactive = false,
    terminalColors = true,
    colors = {
        palette = {},
        theme = { wave = {}, lotus = {}, dragon = {}, all = {} },
    },
    overrides = function(colors)
        return {}
    end,
    theme = "wave",
    background = {
        dark = "wave",
        light = "lotus"
    },
})

vim.cmd("colorscheme kanagawa")
vim.cmd [[
  highlight Normal   guibg=NONE ctermbg=NONE
  highlight NonText  guibg=NONE ctermbg=NONE
]]

-- Harpoon setup
local harpoon_mark = require("harpoon.mark")
local harpoon_ui = require("harpoon.ui")

vim.keymap.set("n", "<leader>a", harpoon_mark.add_file, { desc = "Add file to Harpoon" })
vim.keymap.set("n", "<leader>o", harpoon_ui.toggle_quick_menu, { desc = "Open Harpoon menu" })
vim.keymap.set("n", "<C-h>", function() harpoon_ui.nav_file(1) end, { desc = "Go to Harpoon file 1" })
vim.keymap.set("n", "<C-j>", function() harpoon_ui.nav_file(2) end, { desc = "Go to Harpoon file 2" })
vim.keymap.set("n", "<C-k>", function() harpoon_ui.nav_file(3) end, { desc = "Go to Harpoon file 3" })
vim.keymap.set("n", "<C-l>", function() harpoon_ui.nav_file(4) end, { desc = "Go to Harpoon file 4" })

-- Basic keymaps
vim.keymap.set('n', '<leader>pv', ':Ex<CR>', {noremap = true, silent = true, desc = 'Open netrw'})
vim.keymap.set("v", "<leader>y", '"+y', { desc = "Copy to clipboard" })
vim.keymap.set("v", "<leader>p", '"+p', { desc = "Paste from clipboard" })

-- Load initial profile
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.defer_fn(auto_detect_profile, 100)
  end
})

-- Project-specific config loading
local function load_project_config()
  local project_config = vim.fn.getcwd() .. "/.nvim.lua"
  if vim.fn.filereadable(project_config) == 1 then
    dofile(project_config)
    print("Loaded project-specific config")
  end
end

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.defer_fn(load_project_config, 200)
  end
})
