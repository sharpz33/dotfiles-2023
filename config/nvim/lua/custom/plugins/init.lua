-- lua/custom/plugins/init.lua
return {
  -- Mason: core
  {
    'williamboman/mason.nvim',
    cmd = { 'Mason', 'MasonInstall', 'MasonUpdate', 'MasonUninstall', 'MasonLog' },
    build = ':MasonUpdate',
    opts = {}, -- require('mason').setup({})
  },

  -- Mason LSP bridge: nazwy SERWERÓW z lspconfig
  {
    'williamboman/mason-lspconfig.nvim',
    dependencies = { 'williamboman/mason.nvim' },
    opts = function(_, opts)
      local extra = { 'lua_ls', 'ts_ls', 'pyright', 'gopls', 'rust_analyzer' }
      opts.ensure_installed = opts.ensure_installed or {}
      for _, srv in ipairs(extra) do
        if not vim.tbl_contains(opts.ensure_installed, srv) then
          table.insert(opts.ensure_installed, srv)
        end
      end
    end,
  },

  -- Mason Tool Installer: nazwy PACZEK z registry Masona (bez "rustfmt")
  {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    dependencies = { 'williamboman/mason.nvim' },
    opts = {
      ensure_installed = {
        -- LSP packages
        'lua-language-server',
        'typescript-language-server',
        'pyright',
        'gopls',
        'rust-analyzer',
        -- Formatters / tools
        'stylua',
        'prettierd', -- lub 'prettier'
        'eslint_d',
        'black',
        'gofumpt',
        'goimports',
      },
      auto_update = true,
      run_on_start = true,
      start_delay = 0,
      debounce_hours = 24,
    },
  },

  -- Telescope: dodatkowe skróty
  {
    'nvim-telescope/telescope.nvim',
    keys = {
      { '<leader>pp', function() require('telescope.builtin').find_files() end, desc = 'Project files' },
      { '<leader>po', function() require('telescope.builtin').oldfiles()   end, desc = 'Recent files' },
      { '<leader>pb', function() require('telescope.builtin').buffers()    end, desc = 'Buffers' },
    },
  },

  -- Treesitter: rozszerz języki
  {
    'nvim-treesitter/nvim-treesitter',
    opts = function(_, opts)
      local extra = { 'javascript', 'typescript', 'tsx', 'json', 'yaml', 'python', 'go', 'rust' }
      opts.ensure_installed = opts.ensure_installed or {}
      for _, lang in ipairs(extra) do
        if not vim.tbl_contains(opts.ensure_installed, lang) then
          table.insert(opts.ensure_installed, lang)
        end
      end
    end,
  },

  -- Conform: mapowanie formaterów (uwaga: 'rustfmt' instaluje się przez rustup)
  {
    'stevearc/conform.nvim',
    opts = {
      formatters_by_ft = {
        lua        = { 'stylua' },
        javascript = { 'prettierd', 'prettier' },
        typescript = { 'prettierd', 'prettier' },
        json       = { 'prettierd', 'prettier' },
        css        = { 'prettierd', 'prettier' },
        html       = { 'prettierd', 'prettier' },
        python     = { 'black' },
        go         = { 'gofumpt', 'goimports' },
        rust       = { 'rustfmt' }, -- działa, jeśli masz `rustup component add rustfmt`
      },
    },
  },

  -- Neo-tree: skrót do eksploratora
  {
    'nvim-neo-tree/neo-tree.nvim',
    keys = {
      { '<leader>e', '<cmd>Neotree toggle<CR>', desc = 'Explorer (neo-tree)' },
    },
  },

  -- Harpoon v2: working set plików
  {
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local harpoon = require('harpoon')
      harpoon:setup()

      local list = harpoon:list()
      vim.keymap.set('n', '<leader>a', function() list:add() end,                         { desc = 'Harpoon: add file' })
      vim.keymap.set('n', '<leader>h', function() harpoon.ui:toggle_quick_menu(list) end, { desc = 'Harpoon: quick menu' })
      vim.keymap.set('n', '<leader>1', function() list:select(1) end,                     { desc = 'Harpoon: file 1' })
      vim.keymap.set('n', '<leader>2', function() list:select(2) end,                     { desc = 'Harpoon: file 2' })
      vim.keymap.set('n', '<leader>3', function() list:select(3) end,                     { desc = 'Harpoon: file 3' })
      vim.keymap.set('n', '<leader>4', function() list:select(4) end,                     { desc = 'Harpoon: file 4' })
      vim.keymap.set('n', ']h',        function() list:next() end,                        { desc = 'Harpoon: next' })
      vim.keymap.set('n', '[h',        function() list:prev() end,                        { desc = 'Harpoon: prev' })
    end,
  },

  {
  'folke/which-key.nvim',
  event = 'VeryLazy',            -- załaduj po starcie, szybko ale bez blokowania
  opts = {
    plugins = { spelling = true },
    show_help = false,
    show_keys = true,
    delay = 300,                 -- responsywność panelu po wciśnięciu <leader>
  },
  config = function(_, opts)
    local wk = require('which-key')
    wk.setup(opts)

    -- Grupki pod <leader> (tytuły w panelu)
    wk.add({
      { '<leader>b', group = '[B]uffer' },
      { '<leader>c', group = '[C]ode' },
      { '<leader>g', group = '[G]it' },
      { '<leader>h', desc  = 'Harpoon menu' }, -- bo już masz <leader>h pod harpoon
      { '<leader>p', group = '[P]roject' },    -- np. pp/po/pb z Telescope
      { '<leader>s', group = '[S]earch' },
      { '<leader>t', group = '[T]oggle' },
      { '<leader>e', desc  = 'Explorer (neo-tree)' },
    })
  end,
},

}

