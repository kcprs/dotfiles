local M = {}

function M.setup()
    local treesitter = require("nvim-treesitter")
    treesitter.setup({})

    local available = {}
    for _, language in ipairs(treesitter.get_available()) do
        available[language] = true
    end

    local installing = {}
    local group = vim.api.nvim_create_augroup("TreeSitterHighlighting", { clear = true })

    vim.api.nvim_create_autocmd("FileType", {
        group = group,
        callback = function(args)
            local language = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
            if not language or not available[language] then
                return
            end

            -- Buffers of the same language share an asynchronous installation.
            -- Already-installed parsers are not downloaded again.
            if not installing[language] then
                installing[language] = treesitter.install({ language })
            end

            installing[language]:await(vim.schedule_wrap(function(err, success)
                installing[language] = nil

                if err or success == false then
                    vim.notify(
                        "Tree-sitter installation failed for " .. language
                            .. ": " .. tostring(err or "see :messages"),
                        vim.log.levels.WARN
                    )
                    return
                end

                -- The buffer may have been closed or changed filetype while
                -- its parser was being downloaded and compiled.
                if not vim.api.nvim_buf_is_valid(args.buf)
                    or vim.treesitter.language.get_lang(vim.bo[args.buf].filetype) ~= language
                then
                    return
                end

                local ok, start_err = pcall(vim.treesitter.start, args.buf)
                if not ok then
                    vim.notify(tostring(start_err), vim.log.levels.WARN)
                end
            end))
        end,
    })
end

return M
