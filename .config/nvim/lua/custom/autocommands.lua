local augroup_ft = vim.api.nvim_create_augroup("FileTypeDetection", { clear = true })
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    group = augroup_ft,
    pattern = ".envrc",
    command = "setfiletype sh"
})
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    group = augroup_ft,
    pattern = ".lldbinit",
    command = "setfiletype config"
})

local augroup_cindent = vim.api.nvim_create_augroup("CIndentation", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
    group = augroup_cindent,
    pattern = "c",
    callback = function()
        vim.bo.cindent = true
    end,
})
