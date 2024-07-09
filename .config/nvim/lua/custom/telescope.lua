local M = {}

-- We cache the results of "git rev-parse"
-- Process creation is expensive in Windows, so this reduces latency
local is_inside_work_tree = {}

function M.find_all_files(opts)
    opts = opts or {}
    opts = vim.tbl_extend("force", opts, { hidden = true, no_ignore = true, no_ignore_parent = true })
    require("telescope.builtin").find_files(opts)
end

function M.project_files()
    local cwd = vim.fn.getcwd()
    if is_inside_work_tree[cwd] == nil then
        vim.fn.system("git rev-parse --is-inside-work-tree")
        is_inside_work_tree[cwd] = vim.v.shell_error == 0
    end

    if is_inside_work_tree[cwd] then
        -- TODO this doesn't include git submodules!
        require("telescope.builtin").git_files()
    else
        require("custom.telescope").find_all_files()
    end
end

function M.switch_picker(prompt_bufnr, new_picker, opts)
    local current_picker = require('telescope.actions.state').get_current_picker(prompt_bufnr)
    local current_prompt_text = current_picker:_get_prompt()
    require('telescope.actions').close(prompt_bufnr)
    opts = opts or {}
    opts = vim.tbl_extend("force", opts, { default_text = current_prompt_text })
    new_picker(opts)
end

return M
