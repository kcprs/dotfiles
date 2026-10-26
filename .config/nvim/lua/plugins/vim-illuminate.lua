local M = {}

function M.setup()
    require("illuminate").configure({
        large_file_cutoff = 10000,
    })
end

return M
