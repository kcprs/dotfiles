return {
    {
        "theHamsta/nvim-dap-virtual-text",
        dependencies = {
            "mfussenegger/nvim-dap",
        },
        config = function()
            ---@diagnostic disable-next-line: missing-fields
            require("nvim-dap-virtual-text").setup({})
        end
    },
    {
        "rcarriga/nvim-dap-ui",
        dependencies = {
            "mfussenegger/nvim-dap",
            "nvim-neotest/nvim-nio",
        },
        config = function()
            local dap, dapui = require("dap"), require("dapui")
            dapui.setup()

            require("custom.keymaps").dap()

            -- Create an autocommand using the Lua API for Rust filetype
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "rust",
                callback = function()
                    require("custom.keymaps").dap_rust()
                end,
            })

            dap.listeners.before.attach.dapui_config = function()
                dapui.open()
            end
            dap.listeners.before.launch.dapui_config = function()
                dapui.open()
            end

            dap.adapters.codelldb = {
                type = "executable",
                command = "codelldb",
            }
        end
    },
    {
        "mfussenegger/nvim-dap-python",
        dependencies = {
            "mfussenegger/nvim-dap",
        },
        config = function()
            local python_path = "python3"
            require("dap-python").setup(python_path)
        end
    },
}
