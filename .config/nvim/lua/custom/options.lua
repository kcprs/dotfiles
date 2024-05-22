-- Set highlight on search
vim.o.hlsearch = false

vim.o.number = true
vim.o.relativenumber = true

-- Enable mouse mode
vim.o.mouse = "a"

-- Disable line wrapping
vim.o.wrap = false

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = "yes"

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

vim.o.cursorline = true

vim.o.scrolloff = 8

vim.o.splitright = true
vim.o.splitbelow = true

vim.o.exrc = true

-- Indentation
vim.o.tabstop = 4
vim.o.shiftwidth = 0
vim.o.softtabstop = 0
