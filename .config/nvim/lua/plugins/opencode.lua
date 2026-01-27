return {
    "NickvanDyke/opencode.nvim",
    dependencies = {
        -- Recommended for `ask()` and `select()`.
        -- Required for `snacks` provider.
        ---@module 'snacks' <- Loads `snacks.nvim` types for configuration intellisense.
        {
            "folke/snacks.nvim",
            opts = {
                input = {},
                picker = {},
                terminal = {},
            },
        },
    },
    config = function()
        ---@type opencode.Opts
        vim.g.opencode_opts = {
            provider = {
                snacks = {
                    start_insert = false,
                    auto_insert = false,
                }
            },
        }

        -- Required for `opts.events.reload`.
        vim.o.autoread = true

        require("custom.keymaps").opencode()
    end,
}
