return {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        -- Fuzzy Finder Algorithm which requires local dependencies to be built.
        -- Only load if `make` is available. Make sure you have the system
        -- requirements installed.
        {
            "nvim-telescope/telescope-fzf-native.nvim",
            -- NOTE: If you are having trouble with this installation,
            --       refer to the README for telescope-fzf-native for more instructions.
            build = "make",
            cond = function()
                return vim.fn.executable("make") == 1
            end,
        },
        "nvim-telescope/telescope-ui-select.nvim",
    },
    config = function()
        require("telescope").setup({
            defaults = {
                mappings = require("custom.keymaps").telescope_defaults_mappings(),
                file_ignore_patterns = { "%.git/" },
                layout_config = {
                    prompt_position = "top",
                },
                sorting_strategy = "ascending",
            },
            pickers = {
                buffers = {
                    sort_lastused = true,
                    mappings = require("custom.keymaps").telescope_buffers_mappings()
                },
                find_files = {
                    mappings = require("custom.keymaps").telescope_find_files_mappings()
                },
                git_files = {
                    mappings = require("custom.keymaps").telescope_git_files_mappings()
                },
                live_grep = {
                    mappings = require("custom.keymaps").telescope_live_grep_mappings()
                },
                oldfiles = {
                    mappings = require("custom.keymaps").telescope_oldfiles_mappings()
                },
            },
            extensions = {
                fzf = {},
            },
        })

        -- Extensions
        pcall(require("telescope").load_extension, "fzf")
        require("telescope").load_extension("ui-select")

        require("custom.keymaps").telescope()
    end,
}
