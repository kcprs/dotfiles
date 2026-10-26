local M = {}

function M.setup()
    require("oil").setup({
        columns = {
            "icon",
            -- "permissions",
            -- "size",
            -- "mtime",
        },
        -- keymaps = {
        --     ["<C-v>"] = "actions.select_vsplit",
        -- },
        skip_confirm_for_simple_edits = true,
        view_options = {
            show_hidden = true,
        },
    })
    require("custom.keymaps").oil_set()
end

return M
