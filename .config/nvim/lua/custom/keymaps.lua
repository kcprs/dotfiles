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

    -- Move selected range up and down, stolen from the Primeagen
    vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
    vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
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

function M.cmp_get_mapping()
    local cmp = require("cmp")
    return {
        ["<c-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
        ["<c-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
        ["<c-y>"] = cmp.mapping(
            cmp.mapping.confirm({
                select = true,
                behavior = cmp.ConfirmBehavior.Insert,
            }),
            { "i", "c" }
        ),
    }
end

function M.completion_set()
    local ls = require("luasnip")

    vim.keymap.set("i", "<c-k>", function()
        if ls.expand_or_jumpable() then
            ls.expand_or_jump()
        end
    end)

    vim.keymap.set("i", "<c-j>", function()
        if ls.jumpable(-1) then
            ls.jump(-1)
        end
    end)

    -- TODO: set up choice keymaps like here: https://youtu.be/Dn800rlPIho?si=HdY73pwpqaHHMEwD&t=656
end

return M
