-- Set highlight on search
vim.o.hlsearch = false

-- Line numbers
vim.o.number = true
vim.o.relativenumber = true

-- Enable mouse mode
vim.o.mouse = "a"

-- TODO: enable in selected file types, e.g. markdown
-- Disable line wrapping
vim.o.wrap = false

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep one signcolumn on by default
vim.wo.signcolumn = "yes"

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

-- Cursor stuff
vim.o.cursorline = true
vim.o.scrolloff = 8

-- Window splitting
vim.o.splitright = true
vim.o.splitbelow = true

vim.o.exrc = true

-- Indentation
vim.o.tabstop = 4
vim.o.shiftwidth = 0
vim.o.softtabstop = 0

-- Configure status line to be global
vim.o.laststatus = 3
vim.api.nvim_set_hl(0, 'WinSeparator', { bg = 'NONE' })

-- In diff view, fill deleted areas with '/'
vim.opt.fillchars:append { diff = "╱" }

vim.opt.diffopt:append("vertical")
