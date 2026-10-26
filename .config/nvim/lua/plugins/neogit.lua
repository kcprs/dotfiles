local M = {}

function M.setup()
    require("neogit").setup({
        disable_line_numbers = false,
        graph_style = "unicode",
    })
    vim.keymap.set("n", "<leader>G", require("neogit").open, { desc = "open [G]it GUI" })
end

return M
