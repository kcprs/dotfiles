local M = {}

local show_virtual_text = true

function M.toggle_diagnostics_virtual_text()
    show_virtual_text = not show_virtual_text
    vim.diagnostic.show(nil, nil, nil, {
      virtual_text = show_virtual_text
    })
end

function M.is_virtual_text_enabled()
    return show_virtual_text
end

return M
