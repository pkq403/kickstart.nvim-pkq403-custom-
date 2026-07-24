-- debug.lua
--
-- Shows how to use the DAP plugin to debug your code.
--
-- Primarily focused on configuring the debugger for Go, but can
-- be extended to other languages as well. That's why it's called
-- kickstart.nvim and not kitchen-sink.nvim ;)

return {
  'mfussenegger/nvim-dap',
  dependencies = {
    'rcarriga/nvim-dap-ui',
    'nvim-neotest/nvim-nio',
    'williamboman/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',
    -- Add your own debuggers here
    'leoluz/nvim-dap-go',
    'mfussenegger/nvim-dap-python',
  },
  keys = {
    -- Basic debugging keymaps, feel free to change to your liking!
    {
      '<F5>',
      function()
        require('dap').continue()
      end,
      desc = 'Debug: Start/Continue',
    },
    {
      '<F1>',
      function()
        require('dap').step_into()
      end,
      desc = 'Debug: Step Into',
    },
    {
      '<F2>',
      function()
        require('dap').step_over()
      end,
      desc = 'Debug: Step Over',
    },
    {
      '<F3>',
      function()
        require('dap').step_out()
      end,
      desc = 'Debug: Step Out',
    },
    {
      '<leader>b',
      function()
        require('dap').toggle_breakpoint()
      end,
      desc = 'Debug: Toggle Breakpoint',
    },
    {
      '<leader>B',
      function()
        require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ')
      end,
      desc = 'Debug: Set Breakpoint',
    },
    -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
    {
      '<F7>',
      function()
        require('dapui').toggle()
      end,
      desc = 'Debug: See last session result.',
    },
    {
      '<leader>dh',
      function()
        require('dapui').eval()
      end,
      desc = 'Debug: Hover/Eval variable',
    },
  },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'
    require('mason-nvim-dap').setup {
      -- Makes a best effort to setup the various debuggers with
      -- reasonable debug configurations
      automatic_installation = true,

      -- You can provide additional configuration to the handlers,
      -- see mason-nvim-dap README for more information
      handlers = {},

      -- You'll need to check that you have the required things installed
      -- online, please don't ask me how to install them :)
      ensure_installed = {
        -- Update this to ensure that you have the debuggers for the langs you want
        'delve',
        'python',
        'js-debug-adapter',
      },
    }

    -- Dap UI setup
    -- For more information, see |:help nvim-dap-ui|
    dapui.setup {
      -- Set icons to characters that are more likely to work in every terminal.
      --    Feel free to remove or use ones that you like more! :)
      --    Don't feel like these are good choices.
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
      controls = {
        icons = {
          pause = '⏸',
          play = '▶',
          step_into = '⏎',
          step_over = '⏭',
          step_out = '⏮',
          step_back = 'b',
          run_last = '▶▶',
          terminate = '⏹',
          disconnect = '⏏',
        },
      },
    }

    -- Change breakpoint icons
    -- vim.api.nvim_set_hl(0, 'DapBreak', { fg = '#e51400' })
    -- vim.api.nvim_set_hl(0, 'DapStop', { fg = '#ffcc00' })
    -- local breakpoint_icons = vim.g.have_nerd_font
    --     and { Breakpoint = '', BreakpointCondition = '', BreakpointRejected = '', LogPoint = '', Stopped = '' }
    --   or { Breakpoint = '●', BreakpointCondition = '⊜', BreakpointRejected = '⊘', LogPoint = '◆', Stopped = '⭔' }
    -- for type, icon in pairs(breakpoint_icons) do
    --   local tp = 'Dap' .. type
    --   local hl = (type == 'Stopped') and 'DapStop' or 'DapBreak'
    --   vim.fn.sign_define(tp, { text = icon, texthl = hl, numhl = hl })
    -- end

    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close

    -- Install golang specific config
    require('dap-go').setup {
      delve = {
        -- On Windows delve must be run attached or it crashes.
        -- See https://github.com/leoluz/nvim-dap-go/blob/main/README.md#configuring
        detached = vim.fn.has 'win32' == 0,
      },
    }

  -- Python debugging via nvim-dap-python --------------------------------
  local mason_debugpy = vim.fn.stdpath('data') .. '/mason/packages/debugpy'
  local debugpy_python = mason_debugpy .. (vim.fn.has('win32') == 1 and '/venv/Scripts/python.exe' or '/venv/bin/python')
  if vim.fn.executable(debugpy_python) ~= 1 then
    debugpy_python = 'python3'
  end
  require('dap-python').setup(debugpy_python, {
    include_configs = true,
    console = 'integratedTerminal',
  })
  require('dap-python').test_runner = 'pytest'

  table.insert(dap.configurations.python, {
    type = 'python',
    request = 'launch',
    name = 'pytest: current file',
    module = 'pytest',
    args = { '${file}' },
    console = 'integratedTerminal',
  })
  table.insert(dap.configurations.python, {
    type = 'python',
    request = 'launch',
    name = 'pytest: prompt args',
    module = 'pytest',
    args = function()
      local s = vim.fn.input('pytest args: ')
      if s == '' then
        return nil
      end
      local utils = require('dap.utils')
      if utils.splitstr and vim.fn.has('nvim-0.10') == 1 then
        return utils.splitstr(s)
      end
      return vim.split(s, ' +')
    end,
    console = 'integratedTerminal',
  })

  -- JavaScript / TypeScript / Vue / React debugging ---------------------
  if vim.fn.executable('node') == 1 then
    local js_dap_server = vim.fn.stdpath('data') .. '/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js'
    if vim.uv.fs_stat(js_dap_server) then
      dap.adapters['pwa-node'] = {
        type = 'server',
        host = 'localhost',
        port = '${port}',
        executable = { command = 'node', args = { js_dap_server, '${port}' } },
      }
      dap.adapters['pwa-chrome'] = dap.adapters['pwa-node']

      local js_configs = {
        {
          type = 'pwa-node',
          request = 'launch',
          name = 'Node: launch file',
          program = '${file}',
          cwd = '${workspaceFolder}',
        },
        {
          type = 'pwa-node',
          request = 'launch',
          name = 'Node: launch file (args)',
          program = '${file}',
          cwd = '${workspaceFolder}',
          args = function()
            local s = vim.fn.input('Arguments: ')
            local utils = require('dap.utils')
            if utils.splitstr and vim.fn.has('nvim-0.10') == 1 then
              return utils.splitstr(s)
            end
            return vim.split(s, ' +')
          end,
        },
        {
          type = 'pwa-node',
          request = 'attach',
          name = 'Node: attach (localhost:9229)',
          address = 'localhost',
          port = 9229,
          cwd = '${workspaceFolder}',
          restart = true,
          sourceMaps = true,
        },
        {
          type = 'pwa-chrome',
          request = 'launch',
          name = 'Chrome: launch (Vite/React/Vue dev)',
          url = function()
            return vim.fn.input('Dev server URL: ', 'http://localhost:5173')
          end,
          webRoot = '${workspaceFolder}',
          sourceMaps = true,
          userDataDir = false,
        },
        {
          type = 'pwa-chrome',
          request = 'attach',
          name = 'Chrome: attach (localhost:9222)',
          address = 'localhost',
          port = 9222,
          webRoot = '${workspaceFolder}',
          sourceMaps = true,
        },
      }
      for _, ft in ipairs({ 'javascript', 'typescript', 'javascriptreact', 'typescriptreact', 'vue' }) do
        dap.configurations[ft] = dap.configurations[ft] or {}
        vim.list_extend(dap.configurations[ft], js_configs)
      end
    end
  end
  end,
}
