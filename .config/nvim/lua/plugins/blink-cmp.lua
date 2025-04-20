return {
    "saghen/blink.cmp",

    -- use a release tag to download pre-built binaries
    version = '1.*',

    config = function()
        require("blink.cmp").setup({
            -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
            -- 'super-tab' for mappings similar to vscode (tab to accept)
            -- 'enter' for enter to accept
            -- 'none' for no mappings
            --
            -- All presets have the following mappings:
            -- C-space: Open menu or open docs if already open
            -- C-n/C-p or Up/Down: Select next/previous item
            -- C-e: Hide menu
            -- C-k: Toggle signature help (if signature.enabled = true)
            --
            -- See :h blink-cmp-config-keymap for defining your own keymap
            keymap = { preset = 'default' },

            appearance = {
                -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
                -- Adjusts spacing to ensure icons are aligned
                nerd_font_variant = "mono",
            },

            completion = {
                -- Show documentation when selecting a completion item
                documentation = { auto_show = true, auto_show_delay_ms = 500 },
            },

            -- Default list of enabled providers defined so that you can extend it
            -- elsewhere in your config, without redefining it, due to `opts_extend`
            sources = {
                default = { 'lsp', 'path', 'snippets', 'buffer' },  -- TODO: tailwind-tools.nvim?
                -- Provide path completions relative to cwd insted of current file path
                -- providers = {
                --     path = {
                --         opts = {
                --             get_cwd = function(_)
                --                 return vim.fn.getcwd()
                --             end,
                --         }
                --     }
                -- }
            },

             -- Experimental signature help support
            signature = { enabled = true },
        })
    end,
}
