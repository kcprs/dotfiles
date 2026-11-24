-- Remove trailing whitespace in file
vim.api.nvim_create_user_command("RemoveAllTrailingWhitespace", [[%s/\s\+$//e]], {})

-- Copying paths
local function copy_absolute_path_to_clipboard()
    local filepath = vim.fn.expand("%:p")
    vim.fn.setreg("*", filepath)
    vim.fn.setreg('"', filepath)
    vim.notify("Copied absolute path: " .. filepath, vim.log.levels.INFO)
end
vim.api.nvim_create_user_command("CopyAbsolutePath", copy_absolute_path_to_clipboard, {})

local function copy_relative_path_to_clipboard()
    local filepath = vim.fn.expand("%:p")
    local relative_path = vim.fn.fnamemodify(filepath, ":~:.")
    vim.fn.setreg("*", relative_path)
    vim.fn.setreg('"', relative_path)
    vim.notify("Copied relative path: " .. relative_path, vim.log.levels.INFO)
end
vim.api.nvim_create_user_command("CopyRelativePath", copy_relative_path_to_clipboard, {})

local function copy_file_name_to_clipboard()
    local filename = vim.fn.expand("%:t")
    vim.fn.setreg("*", filename)
    vim.fn.setreg('"', filename)
    vim.notify("Copied file name: " .. filename, vim.log.levels.INFO)
end
vim.api.nvim_create_user_command("CopyFileName", copy_file_name_to_clipboard, {})

-- Evaluates a given string as Lua code, returns result as string.
local function evaluate_string(text)
    local func, err = load("return " .. text)
    if func then
        local ok, result = pcall(func)
        if ok then
            return tostring(result)
        else
            error("Failed to evaluate expression. Error: " .. result)
            return nil
        end
    else
        error("Failed to parse expression. Error: " .. err)
        return nil
    end
end

local function evaluate_selection(replace)
    local start_pos = vim.fn.getpos("'<")
    local end_pos = vim.fn.getpos("'>")
    local start_line, start_col = start_pos[2], start_pos[3]
    local end_line, end_col = end_pos[2], end_pos[3]

    -- If selection reaches last column, get pos returns INT32_MAX. This breaks
    -- nvim_buf_set_text below, so the column indices must be limited to line length.
    local function limit_col(line, col)
        local line_length = vim.fn.col({ line, "$" }) - 1
        return math.min(col, line_length)
    end
    start_col = limit_col(start_line, start_col)
    end_col = limit_col(end_line, end_col)

    local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
    if #lines == 1 then
        lines[1] = string.sub(lines[1], start_col, end_col)
    else
        lines[1] = string.sub(lines[1], start_col)
        lines[#lines] = string.sub(lines[#lines], 1, end_col)
    end

    local processed_text = evaluate_string(table.concat(lines, "\n"))
    if not processed_text then
        return
    end

    if replace then
        local new_lines = vim.split(processed_text, "\n")
        vim.api.nvim_buf_set_text(0, start_line - 1, start_col - 1, end_line - 1, end_col, new_lines)
    else
        vim.notify(processed_text, vim.log.levels.INFO)
    end
end
vim.api.nvim_create_user_command("EvaluateSelection", function()
    evaluate_selection(false)
end, { range = true })
vim.api.nvim_create_user_command("EvaluateSelectionAndReplace", function()
    evaluate_selection(true)
end, { range = true })
