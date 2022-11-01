local opt = vim.opt

-- indentation
opt.shiftwidth = 2 -- the number of spaces inserted for each indentation
opt.tabstop = 2 -- insert 2 spaces for a tab
opt.expandtab = true -- convert tabs to spaces
opt.autoindent = true -- should be on for smartindent
opt.smartindent = true -- make indenting smarter

-- line numbers
opt.number = true -- set numbered lines
opt.relativenumber = true -- set relative line numbers
opt.signcolumn = "yes" -- keep sign column (left of number column) always enabled - this avoids layout shift when diagnostic signs appear

-- interface
opt.mouse = "a" -- allow the mouse to be used in neovim
opt.termguicolors = true -- set term gui colors (most terminals support this)
opt.scrolloff = 8 -- always keep this many lines above/below cursor
opt.sidescrolloff = 8 -- always keep this many lines before/after cursor
opt.showmode = false -- show current mode - covered by lualine plugin
opt.updatetime = 300 -- faster completion (4000ms default)
opt.cursorline = true -- highlight cursor line
opt.splitright = true -- put new window to the right when creating horizontal split
opt.splitbelow = true -- put new window below current one when creating vertical split

-- search
opt.ignorecase = true -- ignore case in search patterns
opt.smartcase = true -- ignore "ignore case" if search term has uppercase characters

-- file handling
opt.fileencoding = "utf-8" -- the encoding written to a file
opt.undofile = true -- enable persistent undo

-- completion
opt.completeopt = "menu,preview,menuone" -- also show autocomplete drop-down with one item
