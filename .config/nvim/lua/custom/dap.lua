local M = {}

function M.set_conditional_breakpoint()
    local condition = vim.fn.input("Enter condition for breakpoint: ")
    require("dap").set_breakpoint(condition)
end

local dap_templates = {
    c = {
        request = "launch",
        cwd = "${workspaceFolder}",
        type = "codelldb",
        stoponentry = false,
    },
    python = {
        request = "launch",
        cwd = "${workspaceFolder}",
        type = "python",
    }
}

---Generate a DAP config from a per-language template
---
---@param lang string Language name as used in DAP
---@param config table? DAP config for extending template (see `:h dap-configuration`).
---@return table # Resulting DAP config
function M.config(lang, config)
    local template = dap_templates[lang]
    if not template then
        error("No DAP config template for lang " .. lang)
    end
    return vim.tbl_extend("force", template, config or {})
end

---Generate a DAP config for the last command of a given just recipe
---
---@param recipe_name string Name of the recipe
---@param config table? DAP config to extend (see `:h dap-configuration`). Keys `name`, `program` and `args` will be populated from the given just recipe.
---@return table # Resulting DAP config
function M.config_from_just(recipe_name, config)
    local result = vim.fn.system("just -n " .. recipe_name)

    -- Find last command in recipe
    local last_command = nil
    for line in result:gmatch("[^\n]+") do
        if line:match("%S") then -- Check if the line is not empty (contains non-whitespace characters)
            last_command = line
        else
        end
    end
    if not last_command then
        error("Got no valid command for recipe " .. recipe_name)
    end

    -- Split the last command on whitespace
    local exe = nil
    local args = {}
    if last_command then
        for word in last_command:gmatch("%S+") do
            if exe == nil then
                exe = word
            else
                table.insert(args, word)
            end
        end
    end

    return vim.tbl_extend("force", config or {}, { name = recipe_name, program = exe, args = args })
end

return M
