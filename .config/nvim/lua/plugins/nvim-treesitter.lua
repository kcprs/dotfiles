return {
    enabled = false,
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    branch = "main",
    build = ":TSUpdate",
    config = function()
        vim.api.nvim_create_autocmd("FileType", {
            group = vim.api.nvim_create_augroup("CustomTreesitter", { clear = true }),
            callback = function(args)
                local ft = vim.bo[args.buf].filetype
                local lang = vim.treesitter.language.get_lang(ft)
                if not lang then
                    return
                end

                -- Check if parser is already installed before attempting install
                local ok = pcall(vim.treesitter.language.inspect, lang)
                if not ok then
                    require("nvim-treesitter").install({ lang })
                end

                -- Enable treesitter highlighting
                vim.treesitter.start(args.buf)

                -- Enable treesitter indent selectively
                local disabled_indent = { "c", "cpp" }
                if not vim.tbl_contains(disabled_indent, ft) then
                    vim.bo[args.buf].indentexpr =
                        "v:lua.require'nvim-treesitter'.indentexpr()"
                end

            end,
        })

        ---@diagnostic disable-next-line: missing-fields
        require("nvim-treesitter.configs").setup({

            -- Modules
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
    end,
}
