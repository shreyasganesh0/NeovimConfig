-- ~/.config/nvim/init.lua

-- Leader must be set before lazy
vim.g.mapleader = ' '

-- Options
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.termguicolors = true
vim.opt.clipboard = "unnamedplus"

vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_python3_provider = 0

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.install").install({ "c", "cpp", "rust", "java", "json", "yaml" })
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("TSHighlight", { clear = true }),
        callback = function(ev)
          pcall(vim.treesitter.start, ev.buf)
        end,
      })
    end,
  },

  -- Harpoon
  {
    "ThePrimeagen/harpoon",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local mark = require("harpoon.mark")
      local ui = require("harpoon.ui")
      vim.keymap.set("n", "<leader>a", mark.add_file,          { desc = "Harpoon: add file" })
      vim.keymap.set("n", "<leader>o", ui.toggle_quick_menu,   { desc = "Harpoon: menu" })
      vim.keymap.set("n", "<C-h>", function() ui.nav_file(1) end, { desc = "Harpoon: file 1" })
      vim.keymap.set("n", "<C-j>", function() ui.nav_file(2) end, { desc = "Harpoon: file 2" })
      vim.keymap.set("n", "<C-k>", function() ui.nav_file(3) end, { desc = "Harpoon: file 3" })
      vim.keymap.set("n", "<C-l>", function() ui.nav_file(4) end, { desc = "Harpoon: file 4" })
    end,
  },

  -- Comment
  { "numToStr/Comment.nvim", opts = {} },

  -- Colorscheme
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha",
        transparent_background = true,
      })
      vim.cmd("colorscheme catppuccin-mocha")
    end,
  },

  -- Completion
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      { "L3MON4D3/LuaSnip", build = vim.fn.has("win32") == 0 and "make install_jsregexp" or nil },
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        snippet = {
          expand = function(args) luasnip.lsp_expand(args.body) end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-d>"]     = cmp.mapping.scroll_docs(-4),
          ["<C-f>"]     = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"]      = cmp.mapping.confirm({ select = true }),
          ["<Tab>"]     = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end,
  },

  -- Java LSP (only loads when a Java file is opened)
  {
    "mfussenegger/nvim-jdtls",
    ft = "java",
    config = function()
      local jdtls = require("jdtls")
      local jdtls_path = vim.fn.stdpath("data") .. "/mason/packages/jdtls"
      local launcher_jar = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")

      local config_dir = ""
      for _, dir in ipairs({ "config_mac_arm64", "config_mac", "config_win", "config_linux" }) do
        local path = jdtls_path .. "/" .. dir
        if vim.fn.isdirectory(path) == 1 then
          config_dir = path
          break
        end
      end

      if launcher_jar == "" or config_dir == "" then
        vim.notify("JDTLS not found. Launcher: " .. launcher_jar .. "  Config: " .. config_dir, vim.log.levels.WARN)
        return
      end

      local workspace_dir = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")

      local config = {
        cmd = {
          "java",
          "-Declipse.application=org.eclipse.jdt.ls.core.id1",
          "-Dosgi.bundles.defaultStartLevel=4",
          "-Declipse.product=org.eclipse.jdt.ls.core.product",
          "-Dlog.protocol=true",
          "-Dlog.level=ALL",
          "-Xms1g",
          "--add-modules=ALL-SYSTEM",
          "--add-opens", "java.base/java.util=ALL-UNNAMED",
          "--add-opens", "java.base/java.lang=ALL-UNNAMED",
          "-jar", launcher_jar,
          "-configuration", config_dir,
          "-data", vim.fn.stdpath("cache") .. "/jdtls-workspace/" .. workspace_dir,
        },
        root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }),
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
              "org.mockito.Mockito.*",
            },
          },
          sources = { organizeImports = { starThreshold = 9999, staticStarThreshold = 9999 } },
          codeGeneration = {
            toString = { template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}" },
          },
        },
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
        on_attach = function(_, bufnr)
          local opts = { buffer = bufnr, silent = true }
          vim.keymap.set("n", "<leader>jo", jdtls.organize_imports,                        opts)
          vim.keymap.set("n", "<leader>jv", jdtls.extract_variable,                        opts)
          vim.keymap.set("v", "<leader>jv", function() jdtls.extract_variable(true) end,   opts)
          vim.keymap.set("n", "<leader>jc", jdtls.extract_constant,                        opts)
          vim.keymap.set("v", "<leader>jc", function() jdtls.extract_constant(true) end,   opts)
          vim.keymap.set("v", "<leader>jm", function() jdtls.extract_method(true) end,     opts)
          vim.keymap.set("n", "<leader>jr", function() jdtls.code_action(false, "refactor") end, opts)
          vim.keymap.set("n", "gd",          vim.lsp.buf.definition,  opts)
          vim.keymap.set("n", "K",           vim.lsp.buf.hover,       opts)
          vim.keymap.set("n", "<leader>ca",  vim.lsp.buf.code_action, opts)
          vim.keymap.set("n", "<leader>rn",  vim.lsp.buf.rename,      opts)
          vim.keymap.set("n", "gr",          vim.lsp.buf.references,  opts)
        end,
      }

      jdtls.start_or_attach(config)
    end,
  },

}, {
  -- lazy.nvim options
  install = { colorscheme = { "catppuccin" } },
  checker = { enabled = false },
})

-- Keymaps
vim.keymap.set("n", "<leader>pv", ":Ex<CR>",  { noremap = true, silent = true, desc = "Open netrw" })
vim.keymap.set("v", "<leader>y",  '"+y',      { desc = "Copy to clipboard" })
vim.keymap.set("v", "<leader>p",  '"+p',      { desc = "Paste from clipboard" })

-- Project-specific config
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    local project_config = vim.fn.getcwd() .. "/.nvim.lua"
    if vim.fn.filereadable(project_config) == 1 then
      dofile(project_config)
      vim.notify("Loaded project config: " .. project_config)
    end
  end,
})
