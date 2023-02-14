local M = {}

local keymap = vim.keymap.set
local common_opts = { noremap = true, silent = true }

local function keymap_with_desc(mode, lhs, rhs, desc, opts)
    keymap(mode, lhs, rhs, vim.tbl_deep_extend("error", opts, { desc = desc }))
end

--Remap space as leader key
keymap("", "<Space>", "<Nop>", common_opts)
vim.g.mapleader = " "

-- Modes
--   normal_mode = "n",
--   insert_mode = "i",
--   visual_mode = "v",
--   visual_block_mode = "x",
--   term_mode = "t",
--   command_mode = "c",

-- Normal --
keymap("n", "<leader>/", "<cmd>nohlsearch<cr>")
keymap("n", "x", '"_x') -- do not put deleted character in a register when replacing with "x"

-- Insert --
-- Press jk fast to return to normal mode
keymap("i", "jk", "<ESC>", common_opts)

-- Plugins --

-- Telescope
M.setup_telescope = function()
    keymap("n", "<leader>ff", require("telescope.builtin").find_files, common_opts)
    keymap("n", "<c-p>", require("telescope.builtin").git_files, common_opts)
    keymap("n", "<leader>fs", require("telescope.builtin").lsp_document_symbols, common_opts)
    keymap("n", "<leader>fg", require("telescope.builtin").live_grep, common_opts)
    keymap("n", "<leader>fb", require("telescope.builtin").buffers, common_opts)
    -- keymap("n", "<leader>fb", require("telescope.builtin").current_buffer_fuzzy_find, opts)
    keymap("n", "<leader>fc", require("telescope.builtin").commands, common_opts)
    keymap("n", "<leader>fk", require("telescope.builtin").keymaps, common_opts)
    keymap("n", "<leader>fd", require("telescope.builtin").diagnostics, common_opts)
end

-- Nvim Tree
-- keymap("n", "<leader>t", "<cmd>NvimTreeToggle<CR>", opts)

-- ToggleTerm
-- keymap("n", "<c-\\>", "<cmd>ToggleTerm<CR>", opts)

-- function _G.set_terminal_keymaps()
--   local ttopts = { buffer = 0 }
--   vim.keymap.set("t", "<esc>", [[<c-\><c-n>]], ttopts)
--   vim.keymap.set("t", "jk", [[<c-\><c-n>]], ttopts)
-- end
--
-- vim.cmd("autocmd! TermOpen term://*toggleterm#* lua set_terminal_keymaps()")

-- LSP - function called when language server attaches
M.setup_lsp = function(_, bufnr)
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local opts = { noremap = true, silent = true, buffer = bufnr }

    keymap("n", "K", vim.lsp.buf.hover, opts)
    keymap("n", "gd", vim.lsp.buf.definition, opts)
    keymap("n", "gD", vim.lsp.buf.declaration, opts)
    keymap("n", "gi", vim.lsp.buf.implementation, opts)
    keymap("n", "gt", vim.lsp.buf.type_definition, opts)
    keymap("n", "gr", vim.lsp.buf.references, opts)
    keymap("n", "<leader>rn", vim.lsp.buf.rename, opts)
    keymap("n", "<leader>ca", vim.lsp.buf.code_action, opts)
    keymap("x", "<leader>ca", vim.lsp.buf.range_code_action, opts)

    -- TODO: switch source/header in clangd

    keymap({ "n", "i" }, "<C-k>", vim.lsp.buf.signature_help, opts)

    keymap("n", "<leader>d", vim.diagnostic.open_float, opts)
    keymap("n", "[d", vim.diagnostic.goto_prev, opts)
    keymap("n", "]d", vim.diagnostic.goto_next, opts)

    keymap("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts)
    keymap("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts)
    keymap("n", "<leader>wl", vim.lsp.buf.list_workspace_folders)

    keymap_with_desc("n", "<leader>t", function()
        vim.lsp.buf.format { async = true }
    end, "Format current buffer", common_opts)
end

return M
