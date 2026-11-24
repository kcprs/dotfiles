local M = {}

function M.setup()
    require("fzf-lua").setup({
        fzf_opts = { ["--cycle"] = true },
        files = {
            fzf_opts = {
                ["--scheme"] = "default",
            },
        },
        grep = {
            hidden = true,
            rg_opts = "--glob '!.git' "
                .. require("fzf-lua").defaults.grep.rg_opts,
        },
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
