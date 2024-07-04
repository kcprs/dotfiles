require("custom.options")

local keymaps = require("custom.keymaps")

--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
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

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function()
        vim.highlight.on_yank()
    end,
    group = highlight_group,
    pattern = "*",
})

require("custom.treesitter")
require("custom.commands")

-- local cmp_autopairs = require "nvim-autopairs.completion.cmp"
-- cmp.event:on(
--   "confirm_done",
--   cmp_autopairs.on_confirm_done()
-- )
