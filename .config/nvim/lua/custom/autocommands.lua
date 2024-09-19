local augroup = vim.api.nvim_create_augroup("FileTypeDetection", { clear = true })
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
  group = augroup,
  pattern = ".envrc",
  command = "setfiletype sh"
})
