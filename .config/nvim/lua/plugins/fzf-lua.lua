local M = {}

function M.setup()
    require("fzf-lua").setup({
        fzf_opts = { ["--cycle"] = true },
        keymap = {
            builtin = {
                true,
                ["<c-j>"] = "toggle-help",
            },
            fzf = {
                true,
                ["ctrl-q"] = "select-all+accept",
            },
        },
    })
    require("fzf-lua.providers.ui_select").register()
    require("custom.keymaps").fzf_lua()
end

return M
