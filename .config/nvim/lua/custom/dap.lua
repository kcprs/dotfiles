local M = {}

function M.get_task_args(task)
    local result = vim.system({ ".mise/tasks/" .. task, "-a" }, { text = true }):wait()

    if result.code ~= 0 then
        vim.notify("Failed to retrieve args for task " .. task .. "\n" .. vim.inspect(result), vim.log.levels.WARN)
        return {}
    end

    local lines = vim.split(result.stdout, "\n")
    lines = vim.tbl_filter(function(line)
        return line ~= ""
    end, lines)

    return lines
end

return M
