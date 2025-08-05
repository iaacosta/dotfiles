return {
  -- Highlight, edit, and navigate code
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  main = 'nvim-treesitter.configs', -- Sets main module to use for opts
  dependencies = {
    {
      'nvim-treesitter/nvim-treesitter-context',
      opts = {
        enable = true,
      },
    },
    {
      'nvim-treesitter/nvim-treesitter-textobjects',
      config = function()
        require('nvim-treesitter.configs').setup {
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
  },
  -- [[ Configure Treesitter ]] See `:help nvim-treesitter`
  opts = {
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
    },
    -- Autoinstall languages that are not installed
    auto_install = true,
    highlight = {
      enable = true,
      -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
      --  If you are experiencing weird indenting issues, add the language to
      --  the list of additional_vim_regex_highlighting and disabled languages for indent.
      additional_vim_regex_highlighting = { 'ruby' },
    },
    indent = { enable = true },
  },
  -- There are additional nvim-treesitter modules that you can use to interact
  -- with nvim-treesitter. You should go explore a few and see what interests you:
  --
  --    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
  --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
}
