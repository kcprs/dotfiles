local M = {}

function M.open_with_merge_base_of_main()
    local branches = {
        "main",
        "master",
    }

    for _, branch in ipairs(branches) do
        local res = vim.system({"git", "merge-base", branch, "@"}, { text = true }):wait()
        if res.code == 0 then
            require("diffview").open(vim.trim(res.stdout))
            return
        end
    end

    print("Failed to open diffview with merge-base of main")
end


return M
