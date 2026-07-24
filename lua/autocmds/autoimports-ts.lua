return vim.api.nvim_create_autocmd('BufWritePost', {
  group = vim.api.nvim_create_augroup('organise_imports', { clear = true }),
  pattern = { '*.ts', '*.tsx', '*.js', '*.jsx', '*.mts', '*.mjs', '*.vue' },
  callback = function(args)
    local clients = vim.lsp.get_clients { bufnr = args.buf }
    for _, client in ipairs(clients) do
      if client.name == 'ts_ls' or client.name == 'typescript-tools' or client.name == 'vtsls' then
        local enc = client.offset_encoding
        local function run_action(only)
          local params = {
            textDocument = vim.lsp.util.make_text_document_params(args.buf),
            range = { start = { line = 0, character = 0 }, ['end'] = { line = 0, character = 0 } },
            context = { only = only, diagnostics = {} },
          }
          vim.lsp.buf_request(args.buf, 'textDocument/codeAction', params, function(err, result, ctx)
            if result then
              for _, action in ipairs(result) do
                if action.edit then
                  vim.lsp.util.apply_workspace_edit(action.edit, enc)
                end
              end
            end
          end)
        end
        run_action { 'source.addMissingImports.ts' }
        run_action { 'source.organizeImports' }
        break
      end
    end
  end,
})
