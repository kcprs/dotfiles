local M = {}

function M.setup()
    -- Setup neovim lua configuration before completion and LSP consumers.
    require("lazydev").setup() -- TODO: Lazy load somehow? Only on ft == lua?
end

return M
