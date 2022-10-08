local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
vim.g.mapleader = ' '
vim.opt.number = true
vim.opt.mouse = 'a'
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.wrap = true
vim.opt.breakindent = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.relativenumber=true
vim.opt.swapfile=false
vim.opt.scrolloff=8
vim.opt.backupcopy='no'

require('plugins')

--setup theme

require("tokyonight").setup({
  -- your configuration comes here
  -- or leave it empty to use the default settings
  style = "storm", -- The theme comes in three styles, `storm`, `moon`, a darker variant `night` and `day`
  light_style = "day", -- The theme is used when the background is set to light
  transparent = false, -- Enable this to disable setting the background color
  terminal_colors = true, -- Configure the colors used when opening a `:terminal` in Neovim
  styles = {
    -- Style to be applied to different syntax groups
    -- Value is any valid attr-list value for `:help nvim_set_hl`
    comments = { italic = true },
    keywords = { italic = true },
    functions = {},
    variables = {},
    -- Background styles. Can be "dark", "transparent" or "normal"
    sidebars = "dark", -- style for sidebars, see below
    floats = "dark", -- style for floating windows
  },
  sidebars = { "qf", "help" }, -- Set a darker background on sidebar-like windows. For example: `["qf", "vista_kind", "terminal", "packer"]`
  day_brightness = 0.3, -- Adjusts the brightness of the colors of the **Day** style. Number between 0 and 1, from dull to vibrant colors
  hide_inactive_statusline = false, -- Enabling this option, will hide inactive statuslines and replace them with a thin border instead. Should work with the standard **StatusLine** and **LuaLine**.
  dim_inactive = false, -- dims inactive windows
  lualine_bold = false, -- When `true`, section headers in the lualine theme will be bold

  --- You can override specific color groups to use other groups or a hex color
  --- function will be called with a ColorScheme table
  ---@param colors ColorScheme
  on_colors = function(colors) end,

  --- You can override specific highlights to use other groups or a hex color
  --- function will be called with a Highlights and ColorScheme table
  ---@param highlights Highlights
  ---@param colors ColorScheme
  on_highlights = function(highlights, colors) end,
})

vim.cmd[[colorscheme tokyonight]]
--setup lualine

require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'tokyonight',
    component_separators = { left = '', right = ''},
    section_separators = { left = '', right = ''},
    disabled_filetypes = {
      statusline = {},
      winbar = {},
    },
    ignore_focus = {},
    always_divide_middle = true,
    globalstatus = false,
    refresh = {
      statusline = 1000,
      tabline = 1000,
      winbar = 1000,
    }
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff', 'diagnostics'},
    lualine_c = {'filename'},
    lualine_x = {'encoding', 'fileformat', 'filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {'filename'},
    lualine_x = {'location'},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  winbar = {},
  inactive_winbar = {},
  extensions = {}
}

--debugging setup using DAP

require("nvim-dap-virtual-text").setup()
local dap, dapui = require("dap"), require("dapui")
dapui.setup()
dap.adapters.node2 = {
  type = 'executable',
  command = 'node',
  args = {os.getenv('HOME') .. '/Documents/Coding/node_debug_server/out/src/nodeDebug.js'},
}
dap.configurations.javascript = {
  {
    name = 'Launch',
    type = 'node2',
    request = 'launch',
    program = '${file}',
    cwd = vim.fn.getcwd(),
    sourceMaps = true,
    protocol = 'inspector',
    console = 'integratedTerminal',
  },
  {
    -- For this to work you need to make sure the node process is started with the `--inspect` flag.
    name = 'Attach to process',
    type = 'node2',
    request = 'attach',
    processId = require'dap.utils'.pick_process,
  },
}
dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close()
end

function map(lhs, rhs,customModes )
    
        modes = {'n', 'i', 'v'}
    if customModes then 
        modes = customModes 
    end
    opts = {noremap=true, nowait=true}
    vim.keymap.set(modes, lhs, rhs, opts)

end

--mappings for dap
    map('<C-5>', ':lua require("dap").continue()<CR>', 'n')

--LSP setup

    require'lspconfig'.eslint.setup{}
    require'lspconfig'.tsserver.setup{
            capabilities=capabilities,
            on_attach = function()
                vim.keymap.set('n', 'K', vim.lsp.buf.hover, {buffer=0})
                vim.keymap.set('n','gd', vim.lsp.buf.definition, {buffer=0})
                vim.keymap.set('n','gt', vim.lsp.buf.type_definition, {buffer=0})
                vim.keymap.set('n','gi', vim.lsp.buf.implementation, {buffer=0})
                vim.keymap.set('n',']d', vim.diagnostic.goto_next, {buffer=0})
                vim.keymap.set('n','[d', vim.diagnostic.goto_prev, {buffer=0})
                vim.keymap.set('n','<leader>r', vim.lsp.buf.rename, {buffer=0})
            end
    }

vim.opt.completeopt={"menu","menuone","noselect"}

  -- Set up nvim-cmp and snippets
  local cmp = require('cmp')
  local luasnip = require('luasnip')
  require("luasnip.loaders.from_vscode").lazy_load()
  require("luasnip.loaders.from_vscode").lazy_load({ paths = { "./mySnippets" } })
  luasnip.filetype_extend("javascript",{"javascriptreact"})
--cmp setup function
  cmp.setup({
    snippet = {
      -- REQUIRED - you must specify a snippet engine
      expand = function(args)
        require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
      end,
    },
    window = {
        documentation = cmp.config.window.bordered()
    },
    mapping = cmp.mapping.preset.insert({
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-J>'] = cmp.mapping.select_prev_item(select_opts),
      ['<C-K>'] = cmp.mapping.select_next_item(select_opts),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
      ['<C-d>']=cmp.mapping(function(fallback)
          if luasnip.jumpable(1) then
              luasnip.jump(1)
          else 
              fallback()
          end 
        end, {'i','s'}),

      ['<C-b>']=cmp.mapping(function(fallback)
          if luasnip.jumpable(-1) then
              luasnip.jump(-1)
          else 
              fallback()
          end 
        end, {'i','s'}),
      ['<Tab>']=cmp.mapping(function(fallback)
          local col = vim.fn.col('.')-1
          if cmp.visible() then
             cmp.select_next_item(select_opts) 
          elseif col==0 or vim.fn.getline('.'):sub(col,col):match('%s') then 
              fallback()
          else 
              cmp.complete()
          end 
        end, {'i','s'}),
      ['<S-Tab>']=cmp.mapping(function(fallback)
          if cmp.visible() then
             cmp.select_prev_item(select_opts) 
          else 
             fallback() 
          end 
        end, {'i','s'}),
    }),
    sources = cmp.config.sources({
        {name = 'path'}, 
      { name = 'nvim_lsp' },
       { name = 'luasnip' }, -- For luasnip users.
    }, {
      { name = 'buffer' },
    }),
    formatting = {
        fields = {'menu','abbr','kind'}
    }
  })

  -- Set configuration for specific filetype.
  cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
      { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
    }, {
      { name = 'buffer' },
    })
  })

  -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline({ '/', '?' }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = 'buffer' }
    }
  })

  -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = 'path' }
    }, {
      { name = 'cmdline' }
    })
  })

  


local opts = { noremap=true, silent=true }
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)


--Keymappings
--vim.keymap.set({'n','i','v'},'<C-C>','+y',{noremap=true, nowait=true})
--vim.keymap.set('n', '<C-V>', '+p',{noremap=true, nowait=true})


--vim.keymap.set({'n','i', 'v'}, '<C-p>', ':FZF<CR>',{noremap=true, nowait=true})
--vim.keymap.set('n', '<C-V>', '+p',{noremap=true, nowait=true})

--autcomplete mappings

--autosave plugin
vim.api.nvim_set_keymap("n", "<leader>n", ":ASToggle<CR>", {})

--General 
map( '<C-P>' ,':FZF<CR>')
map( '<C-C>' ,'"+y')
map( '<C-V>' ,'"+p')
map( '<A-D>' ,':NERDTreeToggle<CR>')
--Harpoon keymaps
map( '<C-A>' ,':lua require("harpoon.mark").add_file()<CR>')
map( '<C-S>' ,':lua require("harpoon.ui").toggle_quick_menu()<CR>')
map( '<A-A>' ,':lua require("harpoon.ui").nav_next()<CR>')
map( '<C-1>' ,':lua require("harpoon.ui").nav_file(1)<CR>')
map( '<C-2>' ,':lua require("harpoon.ui").nav_file(2)<CR>')
map( '<C-3>' ,':lua require("harpoon.ui").nav_file(3)<CR>')
map( '<C-4>' ,':lua require("harpoon.ui").nav_file(4)<CR>')
--map( '<C-A>' ,':bufdo tab split<CR>')

--tabs
map( '<C-J>' ,':tabnext<CR>')
map( '<C-T>' ,':tabnew<CR>')
map( '<C-Y>' ,':tabc<CR>')

--debugging
map('<C-B>', ':DapToggleBreakpoint<CR>')
