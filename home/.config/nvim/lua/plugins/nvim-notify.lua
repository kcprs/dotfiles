local M = {}

function M.setup()
    local notify = require("notify")
    ---@diagnostic disable-next-line missing-fields
    notify.setup({
        stages = "static",
    })
    vim.notify = notify
end

return M
