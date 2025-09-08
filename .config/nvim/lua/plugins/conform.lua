return {
    "stevearc/conform.nvim",
    config = function()
        require("conform").setup({
            formatters_by_ft = {
                c = { "clang-format", lsp_format = "fallback" },
                cpp = { "clang-format", lsp_format = "fallback" },
                cmake = { "cmake-format" },
                javascript = { "prettier" },
                lua = { "stylua" },
                python = { "ruff_organize_imports", "ruff_format" },
                rust = { "rustfmt", lsp_format = "fallback" },
                sh = { "shfmt" },
                -- Use the "_" filetype to run formatters on filetypes that don't
                -- have other formatters configured.
                ["_"] = { "trim_whitespace" },
            },
        })
    end,
}
