return {
    "zbirenbaum/copilot.lua",
    -- requires = {
    --     "copilotlsp-nvim/copilot-lsp", -- for next edit suggestion (NES) functionality, experimental
    -- },
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
        require("copilot").setup({
            suggestion = {
                suggestion = { enabled = false },
                panel = { enabled = false },
            }
        })
    end,

    -- Enable on a per-project basis via env var
    enabled = os.getenv("GH_COPILOT_ON") == "1",
}
