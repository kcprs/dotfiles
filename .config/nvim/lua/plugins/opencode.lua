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
            -- provider = {
            --     snacks = {
            --         start_insert = false,
            --         auto_insert = false,
            --     },
            -- },
            provider = {
                enabled = "terminal",
                terminal = {
                    split = "right",
                    width = math.floor(vim.o.columns * 0.35),
                },
            },
            -- provider = {
            --     enabled = "snacks",
            --     snacks = {
            --         start_insert = false,
            --         auto_insert = false,
            --         win = {
            --             -- Always a bottom panel spanning the editor width
            --             position = "right",
            --             relative = "editor",
            --             height = math.floor(vim.o.lines * 0.35),
            --             -- Window-local overrides to keep it clean
            --             wo = {
            --                 winbar = "",
            --                 number = false,
            --                 relativenumber = false,
            --                 signcolumn = "no",
            --                 cursorline = false,
            --                 wrap = false,
            --             },
            --             bo = {
            --                 filetype = "opencode_terminal",
            --             },
            --         },
            --     },
            -- },
        }

        -- Required for `opts.events.reload`.
        vim.o.autoread = true

        require("custom.keymaps").opencode()
    end,
}
