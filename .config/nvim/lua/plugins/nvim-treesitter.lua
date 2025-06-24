return {
    "nvim-treesitter/nvim-treesitter-textobjects",
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        {
            "nvim-treesitter/nvim-treesitter-context",
            dependencies = {
                "nvim-treesitter/nvim-treesitter",
            }
        },
    },
    build = ":TSUpdate",
    config = function()
        ---@diagnostic disable-next-line: missing-fields
        require("nvim-treesitter.configs").setup({
            ensure_installed = {}, -- All covered by auto-install
            auto_install = true,

            -- Modules
            highlight = { enable = true },
            indent = {
                enable = true,
                -- Indent via treesitter seems broken for c and cpp. Will use vim's cindent instead.
                disable = { "c", "cpp" },
            },
            incremental_selection = {
                enable = true,
                keymaps = require("custom.keymaps").treesitter_incremental_selection(),
            },
            textobjects = {
                select = {
                    enable = true,
                    lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
                    keymaps = require("custom.keymaps").treesitter_textobjects_select(),
                },
                move = vim.tbl_extend("error", {
                    enable = true,
                    set_jumps = true, -- whether to set jumps in the jumplist
                }, require("custom.keymaps").treesitter_textobjects_move()),
                swap = vim.tbl_extend("error", {
                    enable = true,
                }, require("custom.keymaps").treesitter_textobjects_swap()),
            },
        })

        require("treesitter-context").setup({
            multiwindow = true,
        })
    end,
}
