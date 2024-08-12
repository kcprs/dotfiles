-- Set highlight on search
vim.opt.hlsearch = false

-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Enable mouse mode
vim.opt.mouse = "a"

-- TODO: enable in selected file types, e.g. markdown
-- Disable line wrapping
vim.opt.wrap = false

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep one signcolumn on by default
vim.opt.signcolumn = "yes"

-- Decrease update time
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300

-- NOTE: You should make sure your terminal supports this
vim.opt.termguicolors = true

-- Cursor stuff
vim.opt.cursorline = true
vim.opt.scrolloff = 8

-- Window splitting
vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.exrc = true

-- Indentation
vim.opt.tabstop = 4
vim.opt.shiftwidth = 0
vim.opt.softtabstop = 0

-- Configure status line to be global
vim.opt.laststatus = 3
vim.api.nvim_set_hl(0, 'WinSeparator', { bg = 'NONE' })

-- In diff view, fill deleted areas with '/'
vim.opt.fillchars:append { diff = "╱" }

vim.opt.diffopt:append("vertical")
