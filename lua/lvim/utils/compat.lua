local M = {}

local function diagnostic_filter(bufnr, namespace)
  local filter = {}
  if bufnr ~= nil then
    filter.bufnr = bufnr
  end
  if namespace ~= nil then
    filter.ns_id = namespace
  end
  return filter
end

function M.setup()
  vim.uv = vim.uv or vim.loop

  if vim.lsp and vim.lsp.protocol then
    vim.lsp._request_name_to_capability = vim.lsp._request_name_to_capability
      or vim.lsp.protocol._request_name_to_capability
      or vim.lsp.protocol._request_name_to_server_capability
  end

  if vim.diagnostic then
    if not vim.diagnostic.is_disabled and vim.diagnostic.is_enabled then
      vim.diagnostic.is_disabled = function(bufnr, namespace)
        return not vim.diagnostic.is_enabled(diagnostic_filter(bufnr, namespace))
      end
    end

    if not vim.diagnostic.disable and vim.diagnostic.enable then
      vim.diagnostic.disable = function(bufnr, namespace)
        return vim.diagnostic.enable(false, diagnostic_filter(bufnr, namespace))
      end
    end
  end
end

return M
