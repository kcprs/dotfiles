local M = {}

function M.setup()
    require("render-markdown").setup({
        heading = {
            icons = { "󰎤  ", "󰎧  ", "󰎪  ", "󰎭  ", "󰎱  ", "󰎳  " },
        },
        latex = {
            enabled = false,
        },
        code = {
            border = "thin",
        },
    })
end

return M
