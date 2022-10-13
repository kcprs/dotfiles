M = {}

-- Shorten function name
local keymap = vim.keymap.set
-- Silent keymap option
local opts = { noremap = true, silent = true }

--Remap space as leader key
keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "

-- Modes
--   normal_mode = "n",
--   insert_mode = "i",
--   visual_mode = "v",
--   visual_block_mode = "x",
--   term_mode = "t",
--   command_mode = "c",

-- Insert --
-- Press jk fast to return to normal mode
keymap("i", "jk", "<ESC>", opts)

-- Plugins --

-- Telescope
keymap("n", "<leader>ff", require("telescope.builtin").find_files, opts)
keymap("n", "<leader>fg", require("telescope.builtin").live_grep, opts)
keymap("n", "<leader>fb", require("telescope.builtin").current_buffer_fuzzy_find, opts)

-- LSP - function called when language server attaches
M.set_lsp_keymaps = function(bufnr)
	-- See `:help vim.lsp.*` for documentation on any of the below functions
	local bufopts = { noremap = true, silent = true, buffer = bufnr }
	keymap("n", "gD", vim.lsp.buf.declaration, bufopts)
	keymap("n", "gd", vim.lsp.buf.definition, bufopts)
	keymap("n", "gi", vim.lsp.buf.implementation, bufopts)
	keymap("n", "gr", vim.lsp.buf.references, bufopts)
	keymap("n", "gt", vim.lsp.buf.type_definition, bufopts)
	keymap("n", "K", vim.lsp.buf.hover, bufopts)
	keymap({ "n", "i" }, "<C-k>", vim.lsp.buf.signature_help, bufopts)
	keymap("n", "<space>wa", vim.lsp.buf.add_workspace_folder, bufopts)
	keymap("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, bufopts)
	keymap("n", "<space>wl", function()
		print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
	end, vim.tbl_deep_extend("error", bufopts, { desc = "List workspace folders" }))
	keymap("n", "<space>rn", vim.lsp.buf.rename, bufopts)
	keymap("n", "<space>ca", vim.lsp.buf.code_action, bufopts)
	keymap("n", "<space>bf", function()
		vim.lsp.buf.formatting({ async = true })
	end, vim.tbl_deep_extend("error", bufopts, { desc = "Format current buffer" }))
end

return M
