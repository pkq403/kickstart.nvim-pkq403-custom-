return {
  'zbirenbaum/copilot.lua',
  dependencies = {
    {
      'copilotlsp-nvim/copilot-lsp',
      init = function()
        vim.g.copilot_nes_debounce = 500
      end,
    },
  },
  cmd = 'Copilot',
  event = 'InsertEnter',
  config = function()
    vim.notify('copilot setup running', vim.log.levels.INFO, { title = 'copilot.lua' })
    require('copilot').setup {
      panel = {
        enabled = true,
        auto_refresh = false,
        keymap = {
          jump_prev = '[[',
          jump_next = ']]',
          accept = '<CR>',
          refresh = 'gr',
          open = '<M-CR>',
        },
        layout = {
          position = 'bottom', -- | top | left | right | bottom |
          ratio = 0.4,
        },
      },
      suggestion = {
        enabled = true,
        auto_trigger = true,
        hide_during_completion = false,
        debounce = 15,
        trigger_on_accept = true,
        keymap = {
          accept = '<M-l>',
          accept_word = false,
          accept_line = false,
          next = '<M-]>',
          prev = '<M-[>',
          dismiss = '<C-]>',
          toggle_auto_trigger = false,
        },
      },
      nes = {
        enabled = true, -- requires copilot-lsp as a dependency
        auto_trigger = false,
        keymap = {
          accept_and_goto = '<leader>p',
          accept = false,
          dismiss = false,
        },
      },
      auth_provider_url = nil, -- URL to authentication provider, if not "https://github.com/"
      copilot_node_command = 'node', -- Node.js version must be > 22
      workspace_folders = {},
      copilot_model = '',
      disable_limit_reached_message = false, -- Set to `true` to suppress completion limit reached popup
      root_dir = function()
        return vim.fs.dirname(vim.fs.find('.git', { upward = true })[1])
      end,
      should_attach = function(buf_id, _)
        if not vim.bo[buf_id].buflisted then
          return false
        end

        if vim.bo[buf_id].buftype ~= '' then
          return false
        end

        return true
      end,
      server = {
        type = 'nodejs', -- "nodejs" | "binary"
        custom_server_filepath = nil,
      },
      server_opts_overrides = {},
    }
    vim.notify('copilot setup donw', vim.log.levels.INFO, { title = 'copilot.lua' })
    vim.notify(vim.inspect(vim.fn.maparg('<M-l>', 'i', false, true)), vim.log.levels.INFO)
  end,
}
