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
    local ok, wk = pcall(require, "which-key")
    if ok then
        wk.add({ prefix, group = group_name, buffer = buffer })
    end
    return function(modes, lhs, rhs, opts)
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

    -- Paste without overwriting default register. Changing into space instead of just deleting
    -- properly handles pasting onto ends of lines, otherwise the cursor moves one column to the left.
    map("v", "<leader>p", '"_c <ESC>vP')

    -- Copying paths
    local map_with_leader_c = bind_group(map, "<leader>c", "copy")
    map_with_leader_c("n", "a", "<cmd>CopyAbsolutePath<cr>", { desc = "[c]opy [a]bsolute path" })
    map_with_leader_c("n", "r", "<cmd>CopyRelativePath<cr>", { desc = "[c]opy [r]elative path" })
    map_with_leader_c("n", "f", "<cmd>CopyFileName<cr>", { desc = "[c]opy [f]ile name" })
    map_with_leader_c("n", "x", "<cmd>let @+ = @0<cr>", { desc = "Copy 0 register into system clipboard" })

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
    map("n", "<leader>q", function()
        local windows = vim.fn.getwininfo()
        for _, win in pairs(windows) do
            if win.quickfix == 1 then
                vim.cmd("cclose")
                return
            end
        end
        vim.cmd("copen")
    end, { desc = "Toggle [q]uickfix list" })
    -- map_with_leader_q("n", "n", "<cmd>cnext<cr>", { desc = "[q]uickfix [n]ext" })
    -- map_with_leader_q("n", "p", "<cmd>cprev<cr>", { desc = "[q]uickfix [p]rev" })

    -- Evaluate selection and replace
    -- Using ":" instead of "<cmd>" here is important for passing visual
    -- selection to the command. Details are beyond my understanding.
    map("v", "<leader>=", ":EvaluateSelectionAndReplace<cr>", { noremap = true, silent = true })

    -- Formatting with conform.nvim - doesn't necessarily require an LSP
    local ok, conform = pcall(require, "conform")
    if ok then
        map("n", "<leader>lf", conform.format, { desc = "LSP: [f]ormat" })
    end

    local map_with_leader_semi = bind_group(map, "<leader>;", "dotfiles in workspace")
    map_with_leader_semi("n", "j", "<cmd>e .justfile<cr>", { desc = "Edit .justfile in current workspace" })
    map_with_leader_semi("n", "e", "<cmd>e .envrc<cr>", { desc = "Edit .envrc in current workspace" })
    map_with_leader_semi("n", "n", "<cmd>e .nvim.lua<cr>", { desc = "Edit .nvim.lua in current workspace" })
    map_with_leader_semi("n", "s", function()
        vim.cmd("mks! .session.vim")
        vim.notify("Session saved to .session.vim", vim.log.levels.INFO)
    end, { desc = "Save current session to .session.vim" })
end

function M.oil_set()
    map("n", "<leader>o", function()
        require("oil").toggle_float(vim.fn.getcwd())
    end, { desc = "Open [o]il in cwd" })
    map("n", "<leader>O", require("oil").toggle_float, { desc = "Open [O]il in current file's dir" })
end

function M.fzf_lua()
    local fzf_lua = require("fzf-lua")
    local map_with_leader_f = bind_group(map, "<leader>f", "find")

    map_with_leader_f("n", "d", fzf_lua.files, { desc = "[f]in[d] files" })
    map_with_leader_f("n", "b", fzf_lua.buffers, { desc = "[f]ind existing [b]uffers" })
    map_with_leader_f("n", "r", fzf_lua.live_grep_native, { desc = "[f]ind by g[r]ep" })
    map_with_leader_f("n", "h", fzf_lua.helptags, { desc = "[f]ind in [h]elp" })
    map_with_leader_f("n", "o", function()
        fzf_lua.oldfiles({ cwd_only = true })
    end, { desc = "[f]ind [o]ld opened files in cwd" })
    map_with_leader_f("n", "O", fzf_lua.oldfiles, { desc = "[f]ind all [O]ld opened files" })
    map_with_leader_f("n", "k", fzf_lua.keymaps, { desc = "[f]ind [k]eymaps" })
    map_with_leader_f("n", "c", fzf_lua.commands, { desc = "[f]ind [c]ommands" })
    map_with_leader_f("v", "v", fzf_lua.grep_visual, { desc = "[f]ind [v]isual selection" })
    map_with_leader_f("n", "w", fzf_lua.grep_cword, { desc = "[f]ind [w]ord" })
    map_with_leader_f("n", "W", fzf_lua.grep_cWORD, { desc = "[f]ind [W]ORD" })
    map_with_leader_f("n", "<space>", fzf_lua.builtin, { desc = "[f]ind builtin fzf-lua finders" })
    map_with_leader_f("n", "f", fzf_lua.resume, { desc = "Resume previous search" })

    map("n", "<leader>/", fzf_lua.grep_curbuf, { desc = "[/] Fuzzily search in current buffer" })
end

function M.lsp_common(buffer)
    local map_with_leader_l = bind_group(map, "<leader>l", "LSP", buffer)
    local map_with_buffer = bind_buffer(map, buffer)

    -- map_with_leader_l("n", "n", vim.lsp.buf.rename, { desc = "LSP: re[n]ame" })
    -- map_with_leader_l("n", "a", vim.lsp.buf.code_action, { desc = "LSP: code [a]ction" })
    local ok, conform = pcall(require, "conform")
    if ok then
        map_with_leader_l("n", "f", function()
            conform.format({
                bufnr = buffer,
            })
        end, { desc = "LSP: [f]ormat" })
    else
        map_with_leader_l("n", "f", vim.lsp.buf.format, { desc = "LSP: [f]ormat" })
    end
    map_with_leader_l("n", "h", function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
    end, { desc = "LSP: toggle inlay [h]ints" })

    map_with_leader_l("n", "D", vim.diagnostic.setloclist, { desc = "LSP: open [D]iagnostics list" })
    map_with_leader_l("n", "v", require("custom.lsp").toggle_diagnostics_virtual_text, { desc = "LSP: toggle diagnostics [v]irtual text" })
    map_with_leader_l("n", "x", require("custom.lsp").next_diagnostics_preset, { desc = "LSP: ne[x]t diagnostics preset" })
    map_with_buffer("n", "]D", function()
        vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR })
    end, { desc = "LSP: go to next error" })
    map_with_buffer("n", "[D", function()
        vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR })
    end, { desc = "LSP: go to previous error" })

    map_with_buffer("n", "gD", vim.lsp.buf.declaration, { desc = "LSP: [g]o to [D]eclaration" })
    map_with_leader_l("n", "t", vim.lsp.buf.type_definition, { desc = "LSP: go to [t]ype definition" })

    ---@diagnostic disable-next-line: redefined-local
    local ok, fzf_lua = pcall(require, "fzf-lua")
    if ok then
        map_with_leader_l("n", "C", fzf_lua.lsp_incoming_calls, { desc = "LSP: show [C]allers" })
        map_with_leader_l("n", "c", fzf_lua.lsp_outgoing_calls, { desc = "LSP: show [c]allees" })
        map_with_buffer("n", "gO", fzf_lua.lsp_document_symbols, { desc = "LSP: document symbols" })
        map_with_leader_l("n", "S", fzf_lua.lsp_live_workspace_symbols, { desc = "LSP: workspace [S]ymbols" })
        map_with_buffer("n", "gd", fzf_lua.lsp_definitions, { desc = "LSP: [g]o to [d]efinition" })
    end

    ---@diagnostic disable-next-line: redefined-local
    local ok, navbuddy = pcall(require, "nvim-navbuddy")
    if ok then
        map_with_leader_l("n", "n", function()
            navbuddy.open(buffer)
        end, { desc = "LSP: [n]avigate symbols" })
    end

    --------------------------
    -- Lesser used LSP functionality

    -- keymap("n", '<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
    -- keymap("n", '<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
    -- keymap("n", '<leader>wl', function()
    --   print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    -- end, '[W]orkspace [L]ist Folders')
end

function M.lsp_rust(buffer)
    local map_with_leader_l = bind_group(map, "<leader>l", "LSP", buffer)
    -- map_with_leader_l("n", "a", function()
    --     vim.cmd.RustLsp("codeAction")
    -- end, { desc = "LSP: code [a]ction" })
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
    map_with_leader_l("n", "o", "<cmd>LspClangdSwitchSourceHeader<cr>", { desc = "LSP: switch source/header" })
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
    map_with_leader_g("n", "m", require("custom.diffview").open_with_merge_base_of_main, { desc = "[g]it diff [m]erge base" })
end

function M.diffview_conflict_prefix()
    return "<leader>x"
end

function M.diffview_view()
    local actions = require("diffview.actions")
    local prefix = M.diffview_conflict_prefix()

    return {
        { "n", "<leader>co", nil },
        { "n", "<leader>ct", nil },
        { "n", "<leader>cb", nil },
        { "n", "<leader>ca", nil },
        { "n", "<leader>cO", nil },
        { "n", "<leader>cT", nil },
        { "n", "<leader>cB", nil },
        { "n", "<leader>cA", nil },

        -- Old version with "o" for "ours", "t" for "theirs", etc.
        -- { "n", prefix .. "o",  actions.conflict_choose("ours"),        { desc = "Choose the OURS version of a conflict" } },
        -- { "n", prefix .. "t",  actions.conflict_choose("theirs"),      { desc = "Choose the THEIRS version of a conflict" } },
        -- { "n", prefix .. "b",  actions.conflict_choose("base"),        { desc = "Choose the BASE version of a conflict" } },
        -- { "n", prefix .. "a",  actions.conflict_choose("all"),         { desc = "Choose all the versions of a conflict" } },
        -- { "n", prefix .. "O",  actions.conflict_choose_all("ours"),    { desc = "Choose the OURS version of a conflict for the whole file" } },
        -- { "n", prefix .. "T",  actions.conflict_choose_all("theirs"),  { desc = "Choose the THEIRS version of a conflict for the whole file" } },
        -- { "n", prefix .. "B",  actions.conflict_choose_all("base"),    { desc = "Choose the BASE version of a conflict for the whole file" } },
        -- { "n", prefix .. "A",  actions.conflict_choose_all("all"),     { desc = "Choose all the versions of a conflict for the whole file" } },

        { "n", prefix .. "h", actions.conflict_choose("ours"), { desc = "Conflict: choose left (OURS)" } },
        { "n", prefix .. "l", actions.conflict_choose("theirs"), { desc = "Conflict: choose right (THEIRS)" } },
        { "n", prefix .. "b", actions.conflict_choose("base"), { desc = "Conflict: choose BASE" } },
        { "n", prefix .. "a", actions.conflict_choose("all"), { desc = "Conflict: choose ALL" } },
        { "n", prefix .. "H", actions.conflict_choose_all("ours"), { desc = "Conflict: choose (file-wide) left (OURS)" } },
        { "n", prefix .. "L", actions.conflict_choose_all("theirs"), { desc = "Conflict: choose (file-wide) right (THEIRS)" } },
        { "n", prefix .. "B", actions.conflict_choose_all("base"), { desc = "Conflict: choose (file-wide) BASE" } },
        { "n", prefix .. "A", actions.conflict_choose_all("all"), { desc = "Conflict: choose (file-wide) ALL" } },
    }
end

function M.dap()
    local dap = require("dap")
    local dapui = require("dapui")
    local dapui_util = require("dapui.util")
    local custom = require("custom.dap")

    map("n", "<F8>", dap.continue, { desc = "debug: continue" })
    map("n", "<F9>", dap.step_over, { desc = "debug: step over" })
    map("n", "<F10>", dap.step_into, { desc = "debug: step into" })
    map("n", "<F11>", dap.step_out, { desc = "debug: step out" })

    local map_with_leader_d = bind_group(map, "<leader>d", "debug")
    map_with_leader_d("n", "b", dap.toggle_breakpoint, { desc = "debug: toggle [b]reakpoint" })
    map_with_leader_d("n", "f", custom.set_conditional_breakpoint, { desc = "debug: toggle conditional breakpoint" })
    map_with_leader_d("n", "B", dap.clear_breakpoints, { desc = "debug: clear [B]reakpoints" })
    map_with_leader_d("n", "s", dap.continue, { desc = "debug: [s]tart/continue" })
    map_with_leader_d("n", "r", dap.restart, { desc = "debug: [r]estart" })
    map_with_leader_d("n", "t", dap.terminate, { desc = "debug: [t]erminate" })
    map_with_leader_d("n", "d", dap.run_last, { desc = "debug: re-run last" })
    map_with_leader_d("n", "l", dap.run_to_cursor, { desc = "debug: run to cursor/[l]ine" })
    map_with_leader_d("n", "o", dapui.toggle, { desc = "debug: t[o]ggle UI" })
    -- map_with_leader_d("n", "a", custom.select_active_session, { desc = "debug: select [a]ctive session" })

    map_with_leader_d("n", "k", dap.up, { desc = "debug: go up in current stacktrace" })
    map_with_leader_d("n", "j", dap.down, { desc = "debug: go down in current stacktrace" })

    map_with_leader_d({ "n", "v" }, "i", function()
        -- Hack to fix C pointers
        local expr = dapui_util.get_current_expr()
        expr = expr:gsub("->", ".")

        --- @diagnostic disable-next-line: missing-fields
        dapui.eval(expr, { enter = true })
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

function M.undotree()
    map("n", "<leader>u", "<cmd>UndotreeToggle<cr><cmd>UndotreeFocus<cr>", { desc = "[u]ndotree toggle" })
end

function M.treesitter_incremental_selection()
    return {
        init_selection = "<Enter>",
        node_incremental = "<Enter>",
        scope_incremental = false,
        node_decremental = "<Backspace>",
    }
end

function M.treesitter_textobjects_select()
    return {
        -- You can use the capture groups defined in textobjects.scm
        ["aa"] = "@parameter.outer",
        ["ia"] = "@parameter.inner",
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
    }
end

function M.treesitter_textobjects_move()
    return {
        goto_next_start = {
            ["]m"] = "@function.outer",
            ["]]"] = "@class.outer",
            ["]a"] = "@parameter.outer",
        },
        goto_next_end = {
            ["]M"] = "@function.outer",
            ["]["] = "@class.outer",
            ["]A"] = "@parameter.outer",
        },
        goto_previous_start = {
            ["[m"] = "@function.outer",
            ["[["] = "@class.outer",
            ["[a"] = "@parameter.outer",
        },
        goto_previous_end = {
            ["[M"] = "@function.outer",
            ["[]"] = "@class.outer",
            ["[A"] = "@parameter.outer",
        },
    }
end

function M.treesitter_textobjects_swap()
    return {
        swap_next = {
            ["<leader>ta"] = "@parameter.inner",
        },
        swap_previous = {
            ["<leader>tA"] = "@parameter.inner",
        },
    }
end

return M
