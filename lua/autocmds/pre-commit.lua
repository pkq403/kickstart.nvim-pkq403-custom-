return vim.api.nvim_create_autocmd('BufWritePost', {
  group = vim.api.nvim_create_augroup('pre_commit', { clear = true }),
  callback = function(args)
    if vim.fn.executable 'pre-commit' ~= 1 then
      return
    end
    local file = vim.api.nvim_buf_get_name(args.buf)
    if file == '' or vim.bo[args.buf].buftype ~= '' then
      return
    end
    local found = vim.fs.find('.pre-commit-config.yaml', {
      path = vim.fs.dirname(file),
      upward = true,
      stop = vim.loop.os_homedir(),
    })[1]
    if not found then
      return
    end
    local root = vim.fs.dirname(found)
    local rel = vim.fn.fnamemodify(file, ':.')
    vim.system(
      { 'pre-commit', 'run', '--files', rel },
      { cwd = root, text = true },
      vim.schedule_wrap(function(obj)
        if obj.code ~= 0 and obj.stdout ~= '' then
          vim.notify('[pre-commit]\n' .. obj.stdout, vim.log.levels.WARN)
        end
      end)
    )
  end,
})
