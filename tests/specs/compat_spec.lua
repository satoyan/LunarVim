describe("compat", function()
  local compat = require "lvim.utils.compat"
  local saved_lsp_request_name_to_capability
  local saved_disable
  local saved_enable
  local saved_is_disabled
  local saved_is_enabled

  before_each(function()
    saved_lsp_request_name_to_capability = vim.lsp._request_name_to_capability
    saved_disable = vim.diagnostic.disable
    saved_enable = vim.diagnostic.enable
    saved_is_disabled = vim.diagnostic.is_disabled
    saved_is_enabled = vim.diagnostic.is_enabled
  end)

  after_each(function()
    vim.lsp._request_name_to_capability = saved_lsp_request_name_to_capability
    vim.diagnostic.disable = saved_disable
    vim.diagnostic.enable = saved_enable
    vim.diagnostic.is_disabled = saved_is_disabled
    vim.diagnostic.is_enabled = saved_is_enabled
  end)

  it("should provide vim.diagnostic.is_disabled when only is_enabled exists", function()
    local received_filter

    vim.diagnostic.is_disabled = nil
    vim.diagnostic.is_enabled = function(filter)
      received_filter = filter
      return false
    end

    compat.setup()

    assert.True(vim.diagnostic.is_disabled(7, 11))
    assert.same({ bufnr = 7, ns_id = 11 }, received_filter)
  end)

  it("should provide vim.diagnostic.disable when only enable exists", function()
    local received_enable
    local received_filter

    vim.diagnostic.disable = nil
    vim.diagnostic.enable = function(enable, filter)
      received_enable = enable
      received_filter = filter
    end

    compat.setup()
    vim.diagnostic.disable(13, 17)

    assert.False(received_enable)
    assert.same({ bufnr = 13, ns_id = 17 }, received_filter)
  end)

  it("should provide the old LSP request capability map from the new protocol map", function()
    vim.lsp._request_name_to_capability = nil

    compat.setup()

    assert.same(
      vim.lsp.protocol._request_name_to_server_capability,
      vim.lsp._request_name_to_capability
    )
  end)
end)
