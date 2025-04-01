local M = {}

function M.toggle_diagnostics_virtual_text()
    vim.diagnostic.config({
        virtual_text = not vim.diagnostic.config().virtual_text,
    })
end

---@class DiagnosticsPreset
---@field name string
---@field config vim.diagnostic.Opts
---@field on_select? fun(any)
---@field on_deselect? fun(any)
---@field cb_data? any

---@type DiagnosticsPreset[]
local diagnostics_presets = {
    {
        name = "basic",
        config = {
            severity_sort = true,
            update_in_insert = true,
            virtual_text = true,
            virtual_lines = false,
        },
    },
    {
        name = "virtual_lines always",
        config = {
            severity_sort = true,
            update_in_insert = false,
            virtual_text = false,
            virtual_lines = {
                -- Custom format to avoid `source` being shown in the front
                format = function(diagnostic)
                    return diagnostic.message
                end,
            },
        },
    },
    {
        name = "virtual_lines current line",
        config = {
            severity_sort = true,
            update_in_insert = false,
            virtual_text = true,
            virtual_lines = {
                current_line = true,
                -- Custom format to avoid `source` being shown in the front
                format = function(diagnostic)
                    return diagnostic.message
                end,
            }
        },
        cb_data = {
            orig_virtual_text_handler = vim.diagnostic.handlers.virtual_text
        },
        on_select = function(cb_data)
            -- Override the default virtual text handler to hide diagnostics on the current line
            vim.diagnostic.handlers.virtual_text = {
                show = function(namespace, bufnr, diagnostics, opts)
                    local cursor_line = vim.api.nvim_win_get_cursor(0)[1] - 1 -- current line (zero-indexed)
                    local filtered_diagnostics = {}
                    for _, diagnostic in ipairs(diagnostics) do
                        if not (diagnostic.lnum <= cursor_line and cursor_line <= diagnostic.end_lnum) then
                            table.insert(filtered_diagnostics, diagnostic)
                        end
                    end
                    cb_data.orig_virtual_text_handler.show(namespace, bufnr, filtered_diagnostics, opts)
                end,
                hide = function(namespace, bufnr)
                    cb_data.orig_virtual_text_handler.hide(namespace, bufnr)
                end,
            }

            -- Refresh diagnostics when the cursor moves
            local augroup_cursor = vim.api.nvim_create_augroup("UpdateDiagnosticsOnCursorMoved", { clear = true })
            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
                group = augroup_cursor,
                callback = function()
                    vim.diagnostic.show(nil, 0)
                end,
            })
        end,
        on_deselect = function(cb_data)
            -- Reset virtual text handler to original
            vim.diagnostic.handlers.virtual_text = cb_data.orig_virtual_text_handler

            -- Clear the autocommand group
            vim.api.nvim_del_augroup_by_name("UpdateDiagnosticsOnCursorMoved")
        end
    }
}

local current_diagnostics_preset_idx = nil

---@param idx number
---@param notify? boolean
function M.set_diagnostics_preset(idx, notify)
    if current_diagnostics_preset_idx ~= nil then
        local current_preset = diagnostics_presets[current_diagnostics_preset_idx]
        if current_preset.on_deselect then
            current_preset.on_deselect(current_preset.cb_data)
        end
    end

    current_diagnostics_preset_idx = idx
    local current_preset = diagnostics_presets[current_diagnostics_preset_idx]
    if current_preset.on_select then
        current_preset.on_select(current_preset.cb_data)
    end

    vim.diagnostic.config(current_preset.config)
    if notify then
        vim.notify('Switched to diagnostics preset "' .. current_preset.name .. '"', vim.log.levels.INFO)
    end
end

function M.next_diagnostics_preset()
    assert(current_diagnostics_preset_idx ~= nil, "set_diagnostics_preset() must be called first")
    M.set_diagnostics_preset(current_diagnostics_preset_idx % #diagnostics_presets + 1, true)
end

return M
