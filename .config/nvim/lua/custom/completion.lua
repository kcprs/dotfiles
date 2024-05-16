vim.opt.completeopt = { "menu", "menuone", "noselect" }
-- vim.opt.shortmess:append("c") -- TODO: try out

local lspkind = require("lspkind")
lspkind.init()

local cmp = require("cmp")
cmp.setup({
    sources = {
        { name = "nvim_lsp" },
        { name = "path" },
        { name = "buffer" },
    },
    mapping = require("custom.keymaps").cmp_get_mapping(),
    snippet = {
        expand = function(args)
            require("luasnip").lsp_expand(args.body)
        end
    }
})
