local M = {}

function M.setup()
    require("gitsigns").setup({
        -- See `:help gitsigns.txt`
        signs = {
            -- add = { text = "+" },
            -- change = { text = "~" },
            -- delete = { text = "_" },
            -- topdelete = { text = "‾" },
            -- changedelete = { text = "~" },
        },
        sign_priority = 10,
        current_line_blame = true,
        on_attach = require("custom.keymaps").gitsigns,
    })
end

return M
