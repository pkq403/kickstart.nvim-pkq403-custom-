local M = {}
local uv = vim.uv or vim.loop

local is_win = vim.fn.has('win32') == 1
local venv_names = { '.venv', 'venv', 'env' }

function M.exe(venv)
  if is_win then
    return venv .. '\\Scripts\\python.exe'
  end
  return venv .. '/bin/python'
end

function M.find_venv(start)
  local venv = os.getenv('VIRTUAL_ENV')
  if venv then
    local s = uv.fs_stat(venv)
    if s and s.type == 'directory' then
      return venv
    end
  end
  local hits = vim.fs.find(venv_names, {
    path = start or vim.fn.getcwd(),
    upward = true,
    limit = 1,
    stop = uv.os_homedir(),
  })
  for _, p in ipairs(hits) do
    local s = uv.fs_stat(p)
    if s and s.type == 'directory' then
      return p
    end
  end
  return nil
end

function M.python(start)
  local venv = M.find_venv(start)
  if venv then
    local exe = M.exe(venv)
    if vim.fn.executable(exe) == 1 then
      return exe
    end
  end
  if vim.fn.executable('python3') == 1 then
    return 'python3'
  end
  return nil
end

return M