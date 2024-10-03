return {
    "windwp/nvim-autopairs",
    config = function()
        require("nvim-autopairs").setup()
        require("cmp").event:on("confirm_done", require("nvim-autopairs.completion.cmp").on_confirm_done())
    end,
    dependencies = {
        "hrsh7th/nvim-cmp",
    },
}
