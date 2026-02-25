return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'master',
    lazy = false,
    build = ':TSUpdate',
    dependencies = {
      { 'nvim-treesitter/nvim-treesitter-context' },
      { 'nvim-treesitter/nvim-treesitter-textobjects' },
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
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ['af'] = { query = '@function.outer', desc = 'around function' },
              ['if'] = { query = '@function.inner', desc = 'inside function' },
              ['ac'] = { query = '@class.outer', desc = 'around class' },
              ['ic'] = { query = '@class.inner', desc = 'inside class' },
              ['ar'] = { query = '@block.outer', desc = 'around block' },
              ['ir'] = { query = '@block.inner', desc = 'inside block' },
              ['az'] = { query = '@statement.outer', desc = 'around statement' },
              ['iz'] = { query = '@statement.inner', desc = 'inside statement' },
            },
          },
        },
      }
    end,
  },
}
