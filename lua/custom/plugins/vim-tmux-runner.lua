return {
  'christoomey/vim-tmux-runner',
  config = function()
    local cur_file = vim.fn.expand '%:p'
    vim.keymap.set('n', '<leader>gr', ':VtrSendCommandToRunner! go run ' .. cur_file .. ' <cr>', { desc = 'Go Run current file' })
    vim.keymap.set('n', '<leader>at', ':VtrAttachToPane<cr>', { desc = 'Attach to tmux pane' })
  end,
}
