-- Set highlight on search
vim.opt.hlsearch = false

-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Vertical rule
vim.opt.colorcolumn = "100"

-- Enable mouse mode
vim.opt.mouse = "a"

-- TODO: enable in selected file types, e.g. markdown
-- Disable line wrapping
vim.opt.wrap = false

-- If wrapping, continue broken lines with indentation
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep one signcolumn on by default
vim.opt.signcolumn = "yes"

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- Confirm save on exit insted of throwing error
vim.opt.confirm = true

-- NOTE: You should make sure your terminal supports this
vim.opt.termguicolors = true

-- Cursor stuff
vim.opt.cursorline = true
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8

-- Window splitting
vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.exrc = true

-- Indentation
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 0
vim.opt.softtabstop = 0

-- Whitespace
vim.opt.list = true
--- @diagnostic disable-next-line: missing-fields
vim.opt.listchars = {
    tab = "→ ",
    trail = "·",
    extends = ">",
    precedes = "<",
}

-- Configure status line to be global
vim.opt.laststatus = 3
vim.api.nvim_set_hl(0, "WinSeparator", { bg = "NONE" })

-- In diff view, fill deleted areas with '/'
--- @diagnostic disable-next-line: param-type-mismatch
vim.opt.fillchars:append({ diff = "╱" })

vim.opt.diffopt:append("vertical")
vim.opt.diffopt:append("algorithm:patience")

-- Disable styling set by the rust_ft plugin
vim.g.rust_recommended_style = 0
