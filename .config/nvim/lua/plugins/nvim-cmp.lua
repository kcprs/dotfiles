return {
    "hrsh7th/nvim-cmp",
    dependencies = {
        { "L3MON4D3/LuaSnip", build = "make install_jsregexp" },
        "saadparwaiz1/cmp_luasnip",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "onsails/lspkind.nvim",
        "luckasRanarison/tailwind-tools.nvim",
    },
    config = function()
        vim.opt.completeopt = { "menu", "menuone", "noselect" }
        -- vim.opt.shortmess:append("c") -- TODO: try out

        local cmp = require("cmp")
        local lspkind = require("lspkind")
        local ls = require("luasnip")
        cmp.setup({
            sources = {
                { name = "luasnip" },
                { name = "nvim_lsp" },
                { name = "path" },
                { name = "buffer" },
            },
            mapping = require("custom.keymaps").cmp_get_mapping(),
            snippet = {
                expand = function(args)
                    ls.lsp_expand(args.body)
                end,
            },
            ---@diagnostic disable-next-line: missing-fields
            formatting = {
                format = lspkind.cmp_format({
                    mode = "symbol", -- show only symbol annotations
                    maxwidth = 50, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
                    -- can also be a function to dynamically calculate max width such as
                    -- maxwidth = function() return math.floor(0.45 * vim.o.columns) end,
                    ellipsis_char = "...", -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
                    show_labelDetails = true, -- show labelDetails in menu. Disabled by default

                    -- The function below will be called before any actual modifications from lspkind
                    -- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
                    before = require("tailwind-tools.cmp").lspkind_format,
                }),
            },
        })

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
