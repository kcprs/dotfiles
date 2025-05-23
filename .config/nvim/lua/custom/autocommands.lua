local augroup_ft = vim.api.nvim_create_augroup("FileTypeDetection", { clear = true })
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    group = augroup_ft,
    pattern = ".envrc",
    callback = function()
        vim.bo.filetype = "sh"
    end,
})
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    group = augroup_ft,
    pattern = ".lldbinit",
    callback = function()
        vim.bo.filetype = "config"
    end,
})
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    group = augroup_ft,
    pattern = "*.jsonl",
    callback = function()
        vim.bo.filetype = "json"
    end,
})

local augroup_cindent = vim.api.nvim_create_augroup("CIndentation", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
    group = augroup_cindent,
    pattern = "c",
    callback = function()
        vim.bo.cindent = true
    end,
})

local augroup_terminal = vim.api.nvim_create_augroup("Terminal", { clear = true })
vim.api.nvim_create_autocmd("TermOpen", {
    group = augroup_terminal,
    callback = function()
        vim.wo.number = true
        vim.wo.relativenumber = true
    end,
})

local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
    group = highlight_group,
    callback = function()
        vim.highlight.on_yank()
    end,
})


vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*.gitlab-ci*.{yml,yaml}",
  callback = function()
    vim.bo.filetype = "yaml.gitlab"
  end,
})
