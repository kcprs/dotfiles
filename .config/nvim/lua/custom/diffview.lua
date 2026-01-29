local M = {}

local function open_with_merge_base(branch)
    local res = vim.system({ "git", "merge-base", branch, "@" }, { text = true }):wait()
    if res.code == 0 then
        require("diffview").open({ vim.trim(res.stdout) })
        return true
    end
    return false
end

function M.open_with_merge_base_of_main()
    local env_branch = vim.uv.os_getenv("DIFFVIEW_MERGE_BASE")

    if env_branch and env_branch ~= "" then
        if open_with_merge_base(env_branch) then
            return
        end
        -- fall through to default branches if env-based merge-base fails
    end

    local branches = {
        "main",
        "master",
    }

    for _, branch in ipairs(branches) do
        if open_with_merge_base(branch) then
            return
        end
    end

    vim.notify("Failed to open diffview with merge-base of main", vim.log.levels.ERROR)
end

return M
