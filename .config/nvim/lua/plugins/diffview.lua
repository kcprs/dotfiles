return {
    "sindrets/diffview.nvim",
    config = function()
        require("diffview").setup({
            enhanced_diff_hl = true, -- See |diffview-config-enhanced_diff_hl|
            -- file_panel = {
            --     win_config = {
            --         position = "right",
            --     },
            -- },
            keymaps = {
                view = require("custom.keymaps").diffview_view(),
            },
            hooks = {
                view_opened = function()
                    -- Move cursor to current version of opened file as opposed to tree view
                    vim.cmd([[
                        wincmd l
                        wincmd l
                    ]])
                end,
                view_enter = function ()
                    -- Avoid folding areas that are the same, see :h diffopt
                    vim.opt.diffopt:append("context:99999")
                end,
                view_leave = function ()
                    vim.opt.diffopt:remove("context:99999")
                end,
                diff_buf_read = function(bufnr)
                    local ok, wk = pcall(require, "which-key")
                    if ok then
                        wk.register({
                            [require("custom.keymaps").diffview_conflict_prefix()] = { name = "conflict" },
                        }, {
                            mode = "n",
                            buffer = bufnr,
                        })
                    end
                end,
            },
        })

        require("custom.keymaps").diffview_global()
    end,
}
