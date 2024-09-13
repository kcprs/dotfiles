local M = {}

function M.set_conditional_breakpoint()
    local condition = vim.fn.input("Enter condition for breakpoint: ")
    require("dap").set_breakpoint(condition)
end

return M
