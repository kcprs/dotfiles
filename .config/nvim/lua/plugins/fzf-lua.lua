return {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        require("fzf-lua").setup({
            fzf_opts = { ["--cycle"] = true },
            keymap = {
                builtin = {
                    true,
                    ["<c-/>"] = "toggle-help",
                },
                fzf = {
                    true,
                    ["ctrl-q"] = "select-all+accept",
                },
            },
        })
        require("fzf-lua.providers.ui_select").register()
        require("custom.keymaps").fzf_lua()
    end,
}
