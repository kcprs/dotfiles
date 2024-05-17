return {
    "hrsh7th/nvim-cmp",
    dependencies = {
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
    },
    config = function()
        vim.opt.completeopt = { "menu", "menuone", "noselect" }
        -- vim.opt.shortmess:append("c") -- TODO: try out

        local cmp = require("cmp")
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
                end
            }
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

        require("custom.keymaps").completion_set()
    end
}
