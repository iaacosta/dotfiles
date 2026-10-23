return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',
    dependencies = {
      { 'nvim-treesitter/nvim-treesitter-context' },
    },
    config = function()
      local ts = require 'nvim-treesitter'
      ts.install {
        'bash',
        'c',
        'diff',
        'html',
        'lua',
        'luadoc',
        'markdown',
        'markdown_inline',
        'query',
        'vim',
        'vimdoc',
        'go',
        'javascript',
        'typescript',
        'yaml',
        'ruby',
        'vue',
      }

      -- Languages that also keep regex highlighting on top of treesitter
      local regex_highlighting = { ruby = true }

      local function attach(buf, lang)
        if not vim.api.nvim_buf_is_valid(buf) or not pcall(vim.treesitter.start, buf, lang) then
          return
        end
        vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        if regex_highlighting[lang] then
          vim.bo[buf].syntax = 'ON'
        end
      end

      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('custom-treesitter', { clear = true }),
        callback = function(args)
          local lang = vim.treesitter.language.get_lang(args.match)
          if not lang then
            return
          end
          if vim.tbl_contains(ts.get_installed 'parsers', lang) then
            attach(args.buf, lang)
          elseif vim.tbl_contains(ts.get_available(), lang) then
            -- Install missing parsers on first use
            ts.install(lang):await(function()
              vim.schedule(function()
                attach(args.buf, lang)
              end)
            end)
          end
        end,
      })
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
    init = function()
      vim.g.no_plugin_maps = true
    end,
    config = function()
      require('nvim-treesitter-textobjects').setup {
        select = { lookahead = true },
      }

      local selectors = {
        { 'af', '@function.outer' },
        { 'if', '@function.inner' },
        { 'ac', '@class.outer' },
        { 'ic', '@class.inner' },
        { 'ar', '@block.outer' },
        { 'ir', '@block.inner' },
        { 'az', '@statement.outer' },
        { 'iz', '@statement.inner' },
      }

      for _, selector in ipairs(selectors) do
        local mapping, builtin = unpack(selector)
        vim.keymap.set({ 'x', 'o' }, mapping, function()
          require('nvim-treesitter-textobjects.select').select_textobject(builtin, 'textobjects')
        end)
      end
    end,
  },
}
