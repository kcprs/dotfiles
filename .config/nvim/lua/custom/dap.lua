local dap = require("dap")

local M = {}

function M.set_conditional_breakpoint()
    local condition = vim.fn.input("Enter condition for breakpoint: ")
    dap.set_breakpoint(condition)
end

-- Waiting for https://github.com/rcarriga/nvim-dap-ui/issues/326
-- function M.select_active_session()
--     local active_sessions = dap.sessions()
--
--     if #active_sessions == 0 then
--         print("No active debug sessions")
--         return
--     end
--
--     local session_names = {}
--     for _, session in ipairs(active_sessions) do
--         table.insert(session_names, session.config.name)
--     end
--
--     vim.ui.select(session_names, {
--         prompt = "Select active debug session:",
--     }, function(selected)
--         if selected then
--             for _, session in ipairs(active_sessions) do
--                 if session.config.name == selected then
--                     -- This function doesn't exist, ChatGPT!
--                     dap.set_session(session)
--                     print("Selected session: " .. selected)
--                     break
--                 end
--             end
--         end
--     end)
-- end

local dap_templates = {
    c = {
        request = "launch",
        cwd = "${workspaceFolder}",
        type = "codelldb",
        stoponentry = false,
    },
    cpp = {
        request = "launch",
        cwd = "${workspaceFolder}",
        type = "codelldb",
        stoponentry = false,
    },
    rust = {
        request = "launch",
        cwd = "${workspaceFolder}",
        type = "codelldb",
        stoponentry = false,
        sourceLanguages = { "rust" }, -- https://github.com/vadimcn/codelldb/blob/master/MANUAL.md#rust-language-support
    },
    python = {
        request = "launch",
        cwd = "${workspaceFolder}",
        type = "python",
    },
}

--- Methods attached to generated DAP configs
---@class DapConfig: dap.Configuration
local ConfigMethods = {} ---@type DapConfig

--- Strip interpreter from DAP config.
--- Moves interpreter from `args[1]` to `program` and removes it from `args`.
---@param self DapConfig
---@return DapConfig
function ConfigMethods:strip_interpreter()
    assert(self.program, "This method only works on program-based configs")
    self.program = self.args[1]
    table.remove(self.args, 1)
    return self
end

---Generate a DAP config from a per-language template
---
---@param lang string Language name as used in DAP
---@param config table? DAP config for extending template (see `:h dap-configuration`).
---@return DapConfig
function M.config(lang, config)
    local template = dap_templates[lang]
    if not template then
        error("No DAP config template for lang " .. lang)
    end
    local result = vim.tbl_extend("force", template, config or {})
    return setmetatable(result, { __index = ConfigMethods })
end

--- Convenience per-language wrapper of custom.dap.config
function M.c(config)
    return M.config("c", config)
end

--- Convenience per-language wrapper of custom.dap.config
function M.cpp(config)
    return M.config("cpp", config)
end

--- Convenience per-language wrapper of custom.dap.config
function M.rust(config)
    return M.config("rust", config)
end

--- Convenience per-language wrapper of custom.dap.config
function M.python(config)
    return M.config("python", config)
end

---Generate a DAP config for the last command of a given just recipe
---
---@param recipe_name string Name of the recipe
---@param config table? DAP config to extend (see `:h dap-configuration`). Keys `name`, `program` and `args` will be populated from the given just recipe if not already present.
---@return DapConfig
function M.config_from_just(recipe_name, config)
    local result = vim.fn.system("just -n " .. recipe_name)

    -- Find last command in recipe
    local last_command = nil
    for line in result:gmatch("[^\n]+") do
        -- Check if the line is not empty (contains non-whitespace characters)
        -- and does not start with '#' after optional whitespace
        if line:match("%S") and not line:match("^%s*#") then
            last_command = line
        end
    end
    if not last_command then
        error("Got no valid command for recipe " .. recipe_name)
    end

    -- Split the last command on whitespace
    -- TODO: Treat quoted strings as one element.
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

    -- Add `name` and `args` if not already in `config`
    config = vim.tbl_extend("keep", config or {}, { name = recipe_name, args = args })

    -- Special logic for `program`: `program`, `module` and `code` are mutually exclusive,
    -- so only extend if none of them are present.
    if config.program == nil and config.module == nil and config.code == nil then
        config = vim.tbl_extend("error", config, { program = exe })
    end

    return setmetatable(config, { __index = ConfigMethods })
end

return M
