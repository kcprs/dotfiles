local M = {}

-- We cache the results of "git rev-parse"
-- Process creation is expensive in Windows, so this reduces latency
local is_inside_work_tree = {}

function M.find_all_files(opts)
    opts = vim.tbl_extend("force", opts or {}, { hidden = true, no_ignore = true, no_ignore_parent = true })
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
    opts = vim.tbl_extend("force", opts or {}, { default_text = current_prompt_text })
    new_picker(opts)
end

--- @class GrepIncludeArgs
--- @field hidden? boolean Whether to include hidden files in grep searches (default is false)
--- @field ignored? boolean Whether to include ignored files in grep searches (default is false)

--- @param args GrepIncludeArgs
function M.set_grep_include(args)
    local ok, telescope = pcall(require, "telescope")
    if ok then
        local vimgrep_arguments = require("telescope.config").values.vimgrep_arguments or {}

        if args.hidden then
            table.insert(vimgrep_arguments, "--hidden")
        end
        if args.ignored then
            table.insert(vimgrep_arguments, "--no-ignore")
        end

        telescope.setup {
            defaults = {
                vimgrep_arguments = vimgrep_arguments
            }
        }
    end
end

--- @param ... string Lua regex patterns to ignore
function M.add_file_ignore_patterns(...)
    local ok, telescope = pcall(require, "telescope")
    if ok then
        local file_ignore_patterns = require("telescope.config").values.file_ignore_patterns or {}
        vim.list_extend(file_ignore_patterns, {...})
        telescope.setup {
            defaults = {
                file_ignore_patterns = file_ignore_patterns
            }
        }
    end
end

return M
