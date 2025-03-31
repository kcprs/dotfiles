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
                diff_buf_win_enter = function()
                    -- Folds are reset to all closed on file change - fix by unfolding
                    vim.cmd("normal! zR")
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
