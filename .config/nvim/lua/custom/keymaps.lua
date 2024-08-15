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
    map({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

    map("i", "jk", "<ESC>", { noremap = true })

    -- Remap for dealing with word wrap
    map("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
    map("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

    -- Easily exit terminal mode
    map("t", "jk", [[<c-\><c-n>]])

    -- Move selected range up and down, stolen from the Primeagen
    map("v", "J", ":m '>+1<CR>gv=gv")
    map("v", "K", ":m '<-2<CR>gv=gv")

    -- Paste without overwriting default register
    map("v", "<leader>p", '"_dP')

    -- Copying paths
    local map_with_leader_c = bind_group(map, "<leader>c", "copy")
    map_with_leader_c("n", "a", "<cmd>CopyAbsolutePath<cr>", { desc = "[c]opy [a]bsolute path" })
    map_with_leader_c("n", "r", "<cmd>CopyRelativePath<cr>", { desc = "[c]opy [r]elative path" })
    map_with_leader_c("n", "f", "<cmd>CopyFileName<cr>", { desc = "[c]opy [f]ile name" })

    -- Sourcing files
    local map_with_leader_s = bind_group(map, "<leader>s", "source")
    map_with_leader_s("n", "s", "<cmd>source %<cr>", { desc = "source current file" })
    map_with_leader_s("n", "n", "<cmd>source .nvim.lua<cr>", { desc = "source .nvim.lua" })

    -- Close tabs easier
    map("n", "<c-w>t", "<cmd>tabc<cr>", { desc = "Close current tab" })

    -- Window management
    map("n", "<c-w>a", "<cmd>:bufdo bd<cr>", { desc = "Close all buffers" })
    map("n", "<c-w>A", "<cmd>:bufdo bd!<cr>", { desc = "Force-close all buffers" })

    -- Quickfix list
    local map_with_leader_q = bind_group(map, "<leader>q", "quickfix")
    map_with_leader_q("n", "o", function()
        local windows = vim.fn.getwininfo()
        for _, win in pairs(windows) do
            if win.quickfix == 1 then
                vim.cmd('cclose')
                return
            end
        end
        vim.cmd('copen')
    end, { desc = "[q]uickfix t[o]ggle" })
    map_with_leader_q("n", "n", "<cmd>cnext<cr>", { desc = "[q]uickfix [n]ext" })
    map_with_leader_q("n", "p", "<cmd>cprev<cr>", { desc = "[q]uickfix [p]rev" })
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
        ["<c-space>"] = cmp.mapping(
            cmp.mapping.complete({ reason = "manual" }),
            { "i" }
        )
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
    map_with_leader_f("n", "D", custom.find_all_files, { desc = "[f]in[D] ALL files" })
    map_with_leader_f("n", "g", builtin.git_files, { desc = "[f]ind [g]it files" })
    map_with_leader_f("n", "b", builtin.buffers, { desc = "[f]ind existing [b]uffers" })
    map_with_leader_f("n", "r", builtin.live_grep, { desc = "[f]ind by g[r]ep" })
    map_with_leader_f("n", "h", builtin.help_tags, { desc = "[f]ind in [h]elp" })
    map_with_leader_f("n", "o", function()
        builtin.oldfiles({ only_cwd = true })
    end, { desc = "[f]ind [o]ld opened files in cwd" })
    map_with_leader_f("n", "O", builtin.oldfiles, { desc = "[f]ind all [O]ld opened files" })
    map_with_leader_f("n", "k", builtin.keymaps, { desc = "[f]ind [k]eymaps" })
    map_with_leader_f("n", "c", builtin.commands, { desc = "[f]ind [c]ommands" })
    map_with_leader_f("n", "s", builtin.grep_string, { desc = "[f]ind [s]tring" })
    map_with_leader_f("n", "i", builtin.diagnostics, { desc = "[f]ind d[i]agnostics" })
    map_with_leader_f("n", "q", builtin.quickfix, { desc = "[f]ind in [q]uickfix" })
    map_with_leader_f("n", "f", builtin.resume, { desc = "Resume previous search" })


    map("n", "<leader>/", function()
        -- You can pass additional configuration to telescope to change theme, layout, etc.
        require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
            winblend = 10,
            previewer = false,
        }))
    end, { desc = "[/] Fuzzily search in current buffer" })
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
    local function switch_to_git_files(prompt_buffer)
        require("custom.telescope").switch_picker(prompt_buffer, require("telescope.builtin").git_files)
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
    local function switch_to_find_files(prompt_buffer)
        require("custom.telescope").switch_picker(prompt_buffer, require("custom.telescope").find_all_files)
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

function M.telescope_live_grep_mappings()
    local include_hidden = false;
    local function toggle_include_hidden(prompt_buffer)
        include_hidden = not include_hidden
        local opts = include_hidden and { additional_args = { "--hidden", "--no-ignore" } } or nil
        require("custom.telescope").switch_picker(prompt_buffer, require("telescope.builtin").live_grep, opts)
    end

    return {
        i = {
            ["<c-f>"] = toggle_include_hidden
        },
        n = {
            ["<c-f>"] = toggle_include_hidden
        },
    }
end

function M.telescope_oldfiles_mappings()
    local only_cwd = true;
    local function toggle_only_cwd(prompt_buffer)
        only_cwd = not only_cwd
        require("custom.telescope").switch_picker(prompt_buffer, require("telescope.builtin").oldfiles,
            { only_cwd = only_cwd })
    end

    return {
        i = {
            ["<c-f>"] = toggle_only_cwd
        },
        n = {
            ["<c-f>"] = toggle_only_cwd
        },
    }
end

function M.lsp_common(buffer)
    local map_with_leader_l = bind_group(map, "<leader>l", "LSP", buffer)

    map_with_leader_l("n", "r", vim.lsp.buf.rename, { desc = "LSP: [r]ename" })
    map_with_leader_l("n", "a", vim.lsp.buf.code_action, { desc = "LSP: code [a]ction" })
    map_with_leader_l("n", "f", vim.lsp.buf.format, { desc = "LSP: [f]ormat" })
    map_with_leader_l("n", "h", function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
    end, { desc = "LSP: toggle inlay [h]ints" })

    map_with_leader_l("n", "C", require("telescope.builtin").lsp_incoming_calls, { desc = "LSP: show [C]allers" })
    map_with_leader_l("n", "c", require("telescope.builtin").lsp_outgoing_calls, { desc = "LSP: show [c]allees" })

    map_with_leader_l("n", "s", require("telescope.builtin").lsp_document_symbols, { desc = "LSP: document [s]ymbols" })
    map_with_leader_l("n", "S", require("telescope.builtin").lsp_dynamic_workspace_symbols,
        { desc = "LSP: workspace [S]ymbols" })

    map_with_leader_l("n", "D", vim.diagnostic.setloclist, { desc = "LSP: open [D]iagnostics list" })
    map_with_leader_l("n", "v", require("custom.lsp").toggle_diagnostics_virtual_text,
        { desc = "LSP: toggle diagnostics [v]irtual text" })

    local map_with_buffer = bind_buffer(map, buffer)

    map_with_buffer("n", "gd", require("telescope.builtin").lsp_definitions, { desc = "LSP: [g]o to [d]efinition" })
    map_with_buffer("n", "gD", vim.lsp.buf.declaration, { desc = "LSP: [g]o to [D]eclaration" })
    map_with_buffer("n", "gr", require("telescope.builtin").lsp_references, { desc = "LSP: [g]o to [r]eferences" })
    map_with_buffer("n", "gi", require("telescope.builtin").lsp_implementations,
        { desc = "LSP: [g]o to [i]mplementation" })

    map_with_buffer({ "n", "i" }, "<c-h>", vim.lsp.buf.signature_help, { desc = "LSP: signature [h]elp" })

    -- TODO Navbuddy keymaps

    -- Lesser used LSP functionality

    -- keymap("n", '<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
    -- keymap("n", '<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
    -- keymap("n", '<leader>wl', function()
    --   print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    -- end, '[W]orkspace [L]ist Folders')
end

function M.lsp_rust(buffer)
    local map_with_leader_l = bind_group(map, "<leader>l", "LSP", buffer)
    map_with_leader_l("n", "a", function()
        vim.cmd.RustLsp("codeAction")
    end, { desc = "LSP: code [a]ction" })
    map_with_leader_l("n", "d", function()
        vim.cmd.RustLsp("openDocs")
    end, { desc = "LSP: open [d]ocs" })
    map_with_leader_l("n", "d", function()
        vim.cmd.RustLsp("openDocs")
    end, { desc = "LSP: open [d]ocs" })

    local map_with_buffer = bind_buffer(map, buffer)
    map_with_buffer("n", "<c-w>d", function()
        vim.cmd.RustLsp("renderDiagnostic")
    end, { desc = "Show diagnostics under the cursor" }) -- Note: description here matches description for default <c-w>d mapping
    map_with_buffer("n", "<s-J>", function()
        vim.cmd.RustLsp("joinLines")
    end, { desc = "[J]oin lines" })
end

function M.lsp_clangd(buffer)
    local map_with_leader_l = bind_group(map, "<leader>l", "LSP", buffer)
    map_with_leader_l("n", "o", "<cmd>ClangdSwitchSourceHeader<cr>", { desc = "LSP: switch source/header" })
end

function M.harpoon()
    local map_with_leader_h = bind_group(map, "<leader>h", "harpoon")

    local harpoon = require("harpoon")

    map_with_leader_h("n", "a", function()
        harpoon:list():add()
    end, { desc = "[h]arpoon [a]dd" })
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

function M.gitsigns(buffer)
    local map_with_leader_g = bind_group(map, "<leader>g", "git", buffer)

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
    map_with_leader_g("n", "B", function()
        gs.toggle_current_line_blame(nil)
    end, { desc = "[g]it toggle inline [B]lame" })
end

function M.diffview_global()
    local map_with_leader_g = bind_group(map, "<leader>g", "git")

    map_with_leader_g("n", "d", require("diffview").open, { desc = "[g]it [d]iff" })
    map_with_leader_g("n", "m", require("custom.diffview").open_with_merge_base_of_main,
        { desc = "[g]it diff [m]erge base" })
end

function M.diffview_conflict_prefix()
    return "<leader>x"
end

function M.diffview_view()
    local actions = require("diffview.actions")
    local prefix = M.diffview_conflict_prefix()

    return {
        { "n", "<leader>co",  nil },
        { "n", "<leader>ct",  nil },
        { "n", "<leader>cb",  nil },
        { "n", "<leader>ca",  nil },
        { "n", "<leader>cO",  nil },
        { "n", "<leader>cT",  nil },
        { "n", "<leader>cB",  nil },
        { "n", "<leader>cA",  nil },

        -- Old version with "o" for "ours", "t" for "theirs", etc.
        -- { "n", prefix .. "o",  actions.conflict_choose("ours"),        { desc = "Choose the OURS version of a conflict" } },
        -- { "n", prefix .. "t",  actions.conflict_choose("theirs"),      { desc = "Choose the THEIRS version of a conflict" } },
        -- { "n", prefix .. "b",  actions.conflict_choose("base"),        { desc = "Choose the BASE version of a conflict" } },
        -- { "n", prefix .. "a",  actions.conflict_choose("all"),         { desc = "Choose all the versions of a conflict" } },
        -- { "n", prefix .. "O",  actions.conflict_choose_all("ours"),    { desc = "Choose the OURS version of a conflict for the whole file" } },
        -- { "n", prefix .. "T",  actions.conflict_choose_all("theirs"),  { desc = "Choose the THEIRS version of a conflict for the whole file" } },
        -- { "n", prefix .. "B",  actions.conflict_choose_all("base"),    { desc = "Choose the BASE version of a conflict for the whole file" } },
        -- { "n", prefix .. "A",  actions.conflict_choose_all("all"),     { desc = "Choose all the versions of a conflict for the whole file" } },

        { "n", prefix .. "h", actions.conflict_choose("ours"),       { desc = "Conflict: choose left (OURS)" } },
        { "n", prefix .. "l", actions.conflict_choose("theirs"),     { desc = "Conflict: choose right (THEIRS)" } },
        { "n", prefix .. "b", actions.conflict_choose("base"),       { desc = "Conflict: choose BASE" } },
        { "n", prefix .. "a", actions.conflict_choose("all"),        { desc = "Conflict: choose ALL" } },
        { "n", prefix .. "H", actions.conflict_choose_all("ours"),   { desc = "Conflict: choose (file-wide) left (OURS)" } },
        { "n", prefix .. "L", actions.conflict_choose_all("theirs"), { desc = "Conflict: choose (file-wide) right (THEIRS)" } },
        { "n", prefix .. "B", actions.conflict_choose_all("base"),   { desc = "Conflict: choose (file-wide) BASE" } },
        { "n", prefix .. "A", actions.conflict_choose_all("all"),    { desc = "Conflict: choose (file-wide) ALL" } },
    }
end

function M.dap()
    local dap = require("dap")
    local dapui = require("dapui")

    map("n", "<F5>", dap.continue, { desc = "debug: continue" })
    map("n", "<F6>", dap.step_over, { desc = "debug: step over" })
    map("n", "<F7>", dap.step_into, { desc = "debug: step into" })
    map("n", "<F8>", dap.step_out, { desc = "debug: step out" })

    local map_with_leader_d = bind_group(map, "<leader>d", "debug")
    map_with_leader_d("n", "b", dap.toggle_breakpoint, { desc = "debug: toggle [b]reakpoint" })
    map_with_leader_d("n", "B", dap.clear_breakpoints, { desc = "debug: clear [B]reakpoints" })
    map_with_leader_d("n", "s", dap.continue, { desc = "debug: [s]tart/continue" })
    map_with_leader_d("n", "r", dap.restart, { desc = "debug: [r]estart" })
    map_with_leader_d("n", "t", dap.terminate, { desc = "debug: [t]erminate" })
    map_with_leader_d("n", "d", dap.run_last, { desc = "debug: re-run last" })
    map_with_leader_d("n", "l", dap.run_to_cursor, { desc = "debug: run to cursor/[l]ine" })
    map_with_leader_d("n", "o", dapui.open, { desc = "debug: [o]pen UI" })
    map_with_leader_d("n", "c", dapui.close, { desc = "debug: [c]lose UI" })

    map_with_leader_d("n", "k", dap.up, { desc = "debug: go up in current stacktrace" })
    map_with_leader_d("n", "j", dap.down, { desc = "debug: go down in current stacktrace" })

    map_with_leader_d({ "n", "v" }, "i", function()
        --- @diagnostic disable-next-line: missing-fields
        dapui.eval(nil, { enter = true })
    end, { desc = "debug: [i]nspect under cursor" })
end

function M.dap_rust()
    if vim.cmd.RustLsp == nil then
        return
    end

    local map_with_leader_d = bind_group(map, "<leader>d", "debug", vim.api.nvim_get_current_buf())

    map_with_leader_d("n", "s", function()
        vim.cmd.RustLsp("debuggables")
    end, { desc = "debug: [s]tart/continue" })
    map_with_leader_d("n", "S", function()
        vim.cmd.RustLsp("debug")
    end, { desc = "debug: [S]tart current debuggable" })
end

return M
