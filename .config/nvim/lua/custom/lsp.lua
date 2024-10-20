local M = {}

function M.is_virtual_text_enabled()
    local global_config = vim.diagnostic.config()
    -- nil is never returned if first arg to config() is not given.
    ---@diagnostic disable-next-line: need-check-nil
    return global_config.virtual_text
end

function M.toggle_diagnostics_virtual_text()
    vim.diagnostic.config({
        virtual_text = not M.is_virtual_text_enabled()
    })
end

return M
