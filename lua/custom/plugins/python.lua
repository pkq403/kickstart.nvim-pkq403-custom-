return {
  {
    'nvim-neotest/neotest',
    dependencies = {
      'nvim-neotest/nvim-nio',
      'nvim-neotest/neotest-python',
      'nvim-treesitter/nvim-treesitter',
    },
    keys = {
      { '<leader>Tt', function() require('neotest').run.run() end, desc = '[T]est nearest [t]est' },
      { '<leader>Tf', function() require('neotest').run.run(vim.fn.expand('%')) end, desc = '[T]est current [f]ile' },
      { '<leader>TD', function() require('neotest').run.run { strategy = 'dap' } end, desc = '[T]est [D]ebug nearest' },
      { '<leader>Tr', function() require('neotest').run.run_last() end, desc = '[T]est [r]e-run last' },
      { '<leader>Ts', function() require('neotest').summary.toggle() end, desc = '[T]est [s]ummary' },
      { '<leader>To', function() require('neotest').output_panel.toggle() end, desc = '[T]est [o]utput panel' },
      { '<leader>TO', function() require('neotest').output.open { enter = true, auto_close = true } end, desc = '[T]est [O]utput float' },
      { '<leader>Tx', function() require('neotest').run.stop() end, desc = '[T]est stop [x]' },
    },
    config = function()
      require('neotest').setup {
        adapters = {
          require('neotest-python')({
            runner = 'pytest',
            python = function()
              return require('custom.python').python()
            end,
          }),
        },
      }
    end,
  },
}