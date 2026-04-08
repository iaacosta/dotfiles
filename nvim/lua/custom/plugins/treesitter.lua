return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'master',
    lazy = false,
    build = ':TSUpdate',
    dependencies = {
      { 'nvim-treesitter/nvim-treesitter-context' },
    },
    config = function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = {
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
        },
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = { 'ruby' },
        },
        indent = { enable = true },
      }
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
