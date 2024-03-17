local M = {}

function M.setup_leader()
    -- Set <space> as the leader key
    -- See `:help mapleader`
    vim.g.mapleader = " "
    vim.g.maplocalleader = " "
end

function M.setup_basic()
    -- Keymaps for better default experience
    -- See `:help vim.keymap.set()`
    vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

    vim.keymap.set("i", "jk", "<ESC>", { noremap = true })

    -- Remap for dealing with word wrap
    vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
    vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

    -- Easily exit terminal mode
    vim.keymap.set("t", [[<c-\>]], [[<c-\><c-n>]])

    -- Diagnostic keymaps
    vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "go to previous diagnostic message" })
    vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "go to next diagnostic message" })
    vim.keymap.set("n", "<leader>ld", vim.diagnostic.open_float, { desc = "open floating [d]iagnostic message" })
    vim.keymap.set("n", "<leader>lD", vim.diagnostic.setloclist, { desc = "open [D]iagnostics list" })

    -- Move selected range up and down, stolen from the Primeagen
    vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
    vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
end

function M.cmp_mapping()
    local cmp = require("cmp")
    local luasnip = require("luasnip")
    return {
        ["<C-n>"] = cmp.mapping.select_next_item(),
        ["<C-p>"] = cmp.mapping.select_prev_item(),
        ["<C-d>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete({}),
        ["<CR>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
        }),
        ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif luasnip.expand_or_locally_jumpable() then
                luasnip.expand_or_jump()
            else
                fallback()
            end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.locally_jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, { "i", "s" }),
    }
end

-- function M.set_neotree()
--   vim.keymap.set("n", "<leader>ef", ":Neotree toggle action=focus source=filesystem position=right<cr>", { desc = "Toggle Neotree - [e]xplore [f]iles" })
--   vim.keymap.set("n", "<leader>eb", ":Neotree toggle action=focus source=buffers position=right<cr>", { desc = "Toggle Neotree - [e]xplore [b]uffers" })
--   vim.keymap.set("n", "<leader>eg", ":Neotree toggle action=focus source=git_status position=right<cr>", { desc = "Toggle Neotree - [e]xplore [g]it" })
--
--   vim.keymap.set("n", "<leader>eF", ":Neotree toggle action=focus source=filesystem position=float<cr>", { desc = "Toggle Neotree float - [e]xplore [F]iles" })
--   vim.keymap.set("n", "<leader>eB", ":Neotree toggle action=focus source=buffers position=float<cr>", { desc = "Toggle Neotree float - [e]xplore [B]uffers" })
--   vim.keymap.set("n", "<leader>eG", ":Neotree toggle action=focus source=git_status position=float<cr>", { desc = "Toggle Neotree float - [e]xplore [G]it" })
-- end

function M.oil_set()
    vim.keymap.set("n", "<leader>o", require("oil").toggle_float, { desc = "Open [o]il" })
end

function M.toggleterm_get_open_mapping()
    return [[<c-\>]]
end

function M.toggleterm_set()
    -- set up dedicated command to open a terminal with lazygit
    -- local Terminal = require("toggleterm.terminal").Terminal
    -- local lazygit = Terminal:new({
    --     cmd = "lazygit",
    --     dir = "git_dir",
    --     direction = "float",
    --     float_opts = {
    --         border = "curved",
    --     },
    --     -- function to run on opening the terminal
    --     on_open = function(term)
    --         vim.cmd("startinsert!")
    --         vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
    --     end,
    --     -- function to run on closing the terminal
    --     on_close = function()
    --         vim.cmd("startinsert!")
    --     end,
    -- })
    --
    -- function LazyGitToggle()
    --     lazygit:toggle()
    -- end
    --
    -- vim.keymap.set("n", "<leader>G", "<cmd>lua LazyGitToggle()<CR>", { noremap = true, silent = true }, "[G]it")
end

return M
