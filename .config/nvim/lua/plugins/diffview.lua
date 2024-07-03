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
            hooks = {
                view_opened = function()
                    -- Set move cursor to current file as opposed to tree view
                    print("DiffviewOpen autocmd triggered")
                    vim.cmd([[
                        wincmd l
                        wincmd l
                    ]])
                end,
                diff_buf_win_enter = function()
                    vim.opt_local.foldmethod = "manual"
                    vim.opt_local.foldlevel = 99
                end,
            }
        })

        require("custom.keymaps").diffview()
    end,
}
