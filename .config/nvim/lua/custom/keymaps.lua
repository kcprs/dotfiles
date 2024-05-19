local M = {}

-----------------------------
-- LOCAL UTILITY FUNCTIONS --
-----------------------------

local map = vim.keymap.set

 local function bind_buffer(fn, buffer)
     return function(modes, lhs, rhs, opts)
        opts = opts or {}
        opts.buffer = buffer
        fn(modes, lhs, rhs, opts)
     end
 end

local function bind_group(fn, prefix, group_name, buffer)
    return function(modes, lhs, rhs, opts)
        local ok, wk = pcall(require, "which-key")
        if ok then
            wk.register(
                {
                    [prefix] = { name = group_name },
                },
                {
                    mode = modes,
                    buffer = buffer,
                }
            )
        end

        bind_buffer(fn, buffer)(modes, prefix .. lhs, rhs, opts)
    end
end

-----------------------
-- MAPPING FUNCTIONS --
-----------------------

function M.setup_leader()
    -- Set <space> as the leader key
    -- See `:help mapleader`
    vim.g.mapleader = " "
    vim.g.maplocalleader = " "
end

function M.setup_basic()
    -- Keymaps for better default experience
    -- See `:help vim.keymap.set()`
    map({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

    map("i", "jk", "<ESC>", { noremap = true })

    -- Remap for dealing with word wrap
    map("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
    map("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

    -- Easily exit terminal mode
    map("t", [[<c-\>]], [[<c-\><c-n>]])

    -- Move selected range up and down, stolen from the Primeagen
    map("v", "J", ":m '>+1<CR>gv=gv")
    map("v", "K", ":m '<-2<CR>gv=gv")
end

function M.oil_set()
    map("n", "<leader>o", require("oil").toggle_float, { desc = "Open [o]il" })
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
            { "i" }
        ),
    }
end

function M.completion_set()
    local ls = require("luasnip")

    map("i", "<c-k>", function()
        if ls.expand_or_jumpable() then
            ls.expand_or_jump()
        end
    end)

    map("i", "<c-j>", function()
        if ls.jumpable(-1) then
            ls.jump(-1)
        end
    end)

    -- TODO: set up choice keymaps like here: https://youtu.be/Dn800rlPIho?si=HdY73pwpqaHHMEwD&t=656
end

--- NEW ---

function M.telescope()
    local custom = require("custom.telescope")
    local builtin = require("telescope.builtin")
    local map_with_leader_f = bind_group(map, "<leader>f", "find")

    map_with_leader_f("n", "d", custom.project_files, { desc = "[f]in[d] project files (git with fallback)" })
    map_with_leader_f("n", "D", function()
        builtin.find_files({ hidden = true, no_ignore = true })
    end, { desc = "[f]in[D] ALL files" })
    map_with_leader_f("n", "g", builtin.git_files, { desc = "[f]ind [g]it files" })
    map_with_leader_f("n", "b", builtin.buffers, { desc = "[f]ind existing [b]uffers" })
    map_with_leader_f("n", "r", builtin.live_grep, { desc = "[f]ind by g[r]ep" })
    map_with_leader_f("n", "h", builtin.help_tags, { desc = "[f]ind in [h]elp" })
    map_with_leader_f("n", "o", builtin.oldfiles, { desc = "[f]ind [o]ld opened files" })
    map_with_leader_f("n", "k", builtin.keymaps, { desc = "[f]ind [k]eymaps" })
    map_with_leader_f("n", "c", builtin.commands, { desc = "[f]ind [c]ommands" })
    map_with_leader_f("n", "s", builtin.grep_string, { desc = "[f]ind [s]tring" })
    map_with_leader_f("n", "f", builtin.resume, { desc = "Resume previous search" })


    map("n", "<leader>/", function()
        -- You can pass additional configuration to telescope to change theme, layout, etc.
        require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
            winblend = 10,
            previewer = false,
        }))
    end, { desc = "[/] Fuzzily search in current buffer" })

    -- TODO: change this
    map("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
end

function M.telescope_defaults_mappings()
    local actions = require("telescope.actions")
    return {
        i = {
            ["<c-c>"] = actions.close,
            ["<c-x>"] = false, -- select_horizontal by default, remapped to delete_buffer below
            ["<c-h>"] = actions.select_horizontal,
        },
        n = {
            ["<c-c>"] = actions.close,
            ["<c-x>"] = false, -- select_horizontal by default, remapped to delete_buffer below
            ["<c-h>"] = actions.select_horizontal,
        },
    }
end

function M.telescope_find_files_mappings()
    local function switch_to_git_files(prompt_bufnr)
        require("custom.telescope").switch_picker(prompt_bufnr, require("telescope.builtin").git_files)
    end

    return {
        i = {
            ["<c-f>"] = switch_to_git_files
        },
        n = {
            ["<c-f>"] = switch_to_git_files
        },
    }
end

function M.telescope_git_files_mappings()
    local function switch_to_find_files(prompt_bufnr)
        require("custom.telescope").switch_picker(prompt_bufnr, require("telescope.builtin").find_files)
    end

    return {
        i = {
            ["<c-f>"] = switch_to_find_files
        },
        n = {
            ["<c-f>"] = switch_to_find_files
        },
    }
end

function M.telescope_buffers_mappings()
    local actions = require("telescope.actions")
    return {
        i = {
            ["<c-x>"] = actions.delete_buffer
        },
        n = {
            ["d"] = actions.delete_buffer
        },
    }
end

function M.lsp_common(bufnr)
    local map_with_leader_l = bind_group(map, "<leader>l", "LSP", bufnr)

    map_with_leader_l("n", "r", vim.lsp.buf.rename, { desc = "LSP: [r]ename" })
    map_with_leader_l("n", "a", vim.lsp.buf.code_action, { desc = "LSP: code [a]ction" })

    map_with_leader_l("n", "C", require("telescope.builtin").lsp_incoming_calls, { desc = "LSP: show [C]allers" })
    map_with_leader_l("n", "c", require("telescope.builtin").lsp_outgoing_calls, { desc = "LSP: show [c]allees" })

    map_with_leader_l("n", "s", require("telescope.builtin").lsp_document_symbols, { desc = "LSP: document [s]ymbols" })
    map_with_leader_l("n", "S", require("telescope.builtin").lsp_dynamic_workspace_symbols, { desc = "LSP: workspace [S]ymbols" })

    map_with_leader_l("n", "f", vim.lsp.buf.format, { desc = "LSP: [f]ormat" })

    map_with_leader_l("n", "d", vim.diagnostic.open_float, { desc = "LSP: open floating [d]iagnostic message" })
    map_with_leader_l("n", "D", vim.diagnostic.setloclist, { desc = "LSP: open [D]iagnostics list" })

    local map_with_buffer = bind_buffer(map, bufnr)

    map_with_buffer("n", "gd", require("telescope.builtin").lsp_definitions, { desc = "LSP: [g]o to [d]efinition" })
    map_with_buffer("n", "gD", vim.lsp.buf.declaration, { desc = "LSP: [g]o to [D]eclaration" })
    map_with_buffer("n", "gr", require("telescope.builtin").lsp_references, { desc = "LSP: [g]o to [r]eferences" })
    map_with_buffer("n", "gi", require("telescope.builtin").lsp_implementations, { desc = "LSP: [g]o to [i]mplementation" })

    -- See `:help K` for why this keymap
    map_with_buffer("n", "K", vim.lsp.buf.hover, { desc = "LSP: hover documentation" })
    map_with_buffer({ "n", "i" }, "<c-h>", vim.lsp.buf.signature_help, { desc = "LSP: signature [h]elp" })

    -- TODO Navbuddy keymaps

    -- Lesser used LSP functionality

    -- keymap("n", '<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
    -- keymap("n", '<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
    -- keymap("n", '<leader>wl', function()
    --   print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    -- end, '[W]orkspace [L]ist Folders')
end

function M.lsp_rust(bufnr)
    local map_with_leader_l = bind_group(map, "<leader>l", "LSP", bufnr)
    map_with_leader_l("n", "a", function()
        vim.cmd.RustLsp("codeAction")
    end, { desc = "LSP: code [a]ction" })
    map_with_leader_l("n", "d", function()
        vim.cmd.RustLsp("renderDiagnostic")
    end, { desc = "LSP: open floating [d]iagnostic message" })

    local map_with_buffer = bind_buffer(map, bufnr)
    map_with_buffer("n", "<s-J>", function()
        vim.cmd.RustLsp("joinLines")
    end, { desc = "LSP: open floating [d]iagnostic message" })
end

function M.harpoon()
    local map_with_leader_h = bind_group(map, "<leader>h", "harpoon")

    local harpoon = require("harpoon")

    map_with_leader_h("n", "a", function()
        harpoon:list():append()
    end, { desc = "[h]arpoon [a]ppend" })
    map_with_leader_h("n", "s", function()
        harpoon.ui:toggle_quick_menu(harpoon:list())
    end, { desc = "[h]arpoon [s]how" })

    map_with_leader_h("n", "h", function()
        harpoon:list():select(1)
    end, { desc = "[h]arpoon file 1" })
    map_with_leader_h("n", "j", function()
        harpoon:list():select(2)
    end, { desc = "[h]arpoon file 2" })
    map_with_leader_h("n", "k", function()
        harpoon:list():select(3)
    end, { desc = "[h]arpoon file 3" })
    map_with_leader_h("n", "l", function()
        harpoon:list():select(4)
    end, { desc = "[h]arpoon file 4" })

    -- Toggle previous & next buffers stored within Harpoon list
    map_with_leader_h("n", "p", function()
        harpoon:list():prev()
    end, { desc = "[h]arpoon [p]revious" })
    map_with_leader_h("n", "n", function()
        harpoon:list():next()
    end, { desc = "[h]arpoon [n]ext" })
end

function M.gitsigns(bufnr)
    local map_with_leader_g = bind_group(map, "<leader>g", "git", bufnr)

    local gs = package.loaded.gitsigns

    -- Navigation (don't override the built-in keymaps)
    map({ "n", "v" }, "]c", function()
        if vim.wo.diff then
            return "]c"
        end
        vim.schedule(function()
            gs.next_hunk()
        end)
        return "<Ignore>"
    end, { expr = true, desc = "Jump to next hunk" })
    map({ "n", "v" }, "[c", function()
        if vim.wo.diff then
            return "[c"
        end
        vim.schedule(function()
            gs.prev_hunk()
        end)
        return "<Ignore>"
    end, { expr = true, desc = "Jump to previous hunk" })

    map_with_leader_g("n", "p", gs.preview_hunk, { desc = "[g]it [p]review hunk" })
    map_with_leader_g("n", "s", gs.stage_hunk, { desc = "[g]it [s]tage hunk" })
    map_with_leader_g("n", "r", gs.reset_hunk, { desc = "[g]it [r]eset hunk" })
    map_with_leader_g("v", "s", function()
        gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
    end, { desc = "[g]it [s]tage hunk" })
    map_with_leader_g("v", "r", function()
        gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
    end, { desc = "[g]it [r]eset hunk" })

    map_with_leader_g("n", "b", function()
        gs.blame_line({ full = true })
    end, { desc = "[g]it show [b]lame" })
end

return M
