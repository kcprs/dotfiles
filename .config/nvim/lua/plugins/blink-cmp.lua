return {
    "saghen/blink.cmp",

    -- use a release tag to download pre-built binaries
    version = "*",

    dependencies = { "L3MON4D3/LuaSnip", version = "v2.*", build = "make install_jsregexp" },

    config = function()
        require("blink.cmp").setup({
            -- 'default' for mappings similar to built-in completion
            -- 'super-tab' for mappings similar to vscode (tab to accept, arrow keys to navigate)
            -- 'enter' for mappings similar to 'super-tab' but with 'enter' to accept
            -- See the full "keymap" documentation for information on defining your own keymap.
            keymap = { preset = "default" },

            appearance = {
                -- Sets the fallback highlight groups to nvim-cmp's highlight groups
                -- Useful for when your theme doesn't support blink.cmp
                -- Will be removed in a future release
                use_nvim_cmp_as_default = true,
                -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
                -- Adjusts spacing to ensure icons are aligned
                nerd_font_variant = "mono"
            },

            snippets = { preset = 'luasnip' },

            -- Experimental signature help support
            signature = { enabled = true }
        })

        -- LuaSnip
        local ls = require("luasnip")
        ls.setup({
            update_events = { "TextChanged", "TextChangedI" },
            -- The four options below allow to jump back into snippets after they have been exited
            keep_roots = true,
            link_roots = true,
            link_children = true,
            exit_roots = false,
        })

        -- If opts.paths in [lazy]_load(opts) is not set runtimepath is searched for directories that contain snippets.
        --
        --     lua: the snippet-library has to be in a directory named "luasnippets".
        --     snipmate: similar to lua, but the directory has to be "snippets".
        --     vscode: any directory in runtimepath that contains a package.json contributing snippets.
        require("luasnip.loaders.from_lua").lazy_load()

        require("custom.keymaps").luasnip_set()
    end,

}
