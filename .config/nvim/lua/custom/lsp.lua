local M = {}

local show_virtual_text = true

function M.toggle_diagnostics()
  show_virtual_text = not show_virtual_text
  vim.diagnostic.show(nil, nil, nil, {
    virtual_text = show_virtual_text
  })
end

return M
