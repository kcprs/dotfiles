return {
    "sindrets/diffview.nvim",
    config = function()
        require("diffview").setup({
            enhanced_diff_hl = true, -- See |diffview-config-enhanced_diff_hl|
            file_panel = {
                win_config = {
                    position = "right",
                },
            },
        })

        require("custom.keymaps").diffview()
    end,
}
