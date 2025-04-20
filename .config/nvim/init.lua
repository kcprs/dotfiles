require("custom.options")

local keymaps = require("custom.keymaps")

-- NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
keymaps.setup_leader()

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)
require("lazy").setup({
    spec = {
        { import = "plugins" },
    },
    change_detection = {
        notify = false,
    },
})

keymaps.setup_basic()

require("custom.autocommands")
require("custom.commands")
