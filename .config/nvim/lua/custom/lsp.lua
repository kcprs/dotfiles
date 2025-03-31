local M = {}

function M.toggle_diagnostics_virtual_text()
    vim.diagnostic.config({
        virtual_text = not vim.diagnostic.config().virtual_text,
    })
end

---@type any
local next_virtual_lines = {
    current_line = true,
    -- Custom format to avoid `source` being shown in the front
    format = function(diagnostic)
        return diagnostic.message
    end,
}
function M.toggle_diagnostics_virtual_lines()
    local current_virtual_lines = vim.diagnostic.config().virtual_lines
    vim.diagnostic.config({ virtual_lines = next_virtual_lines })
    next_virtual_lines = current_virtual_lines
end

return M
