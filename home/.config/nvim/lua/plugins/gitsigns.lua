return {
    "lewis6991/gitsigns.nvim",
    opts = {
        -- See `:help gitsigns.txt`
        signs = {
            -- add = { text = "+" },
            -- change = { text = "~" },
            -- delete = { text = "_" },
            -- topdelete = { text = "‾" },
            -- changedelete = { text = "~" },
        },
        on_attach = function(bufnr)
            local gs = package.loaded.gitsigns

            local function map(mode, l, r, opts)
                opts = opts or {}
                opts.buffer = bufnr
                vim.keymap.set(mode, l, r, opts)
            end

            -- Navigation (don't override the built-in keymaps)
            vim.keymap.set({ "n", "v" }, "]c", function()
                if vim.wo.diff then
                    return "]c"
                end
                vim.schedule(function()
                    gs.next_hunk()
                end)
                return "<Ignore>"
            end, { expr = true, desc = "Jump to next hunk" })
            vim.keymap.set({ "n", "v" }, "[c", function()
                if vim.wo.diff then
                    return "[c"
                end
                vim.schedule(function()
                    gs.prev_hunk()
                end)
                return "<Ignore>"
            end, { expr = true, desc = "Jump to previous hunk" })


            map("n", "<leader>gp", gs.preview_hunk, { desc = "[g]it [p]review hunk" })
            map("n", "<leader>gs", gs.stage_hunk, { desc = "[g]it [s]tage hunk" })
            map("n", "<leader>gr", gs.reset_hunk, { desc = "[g]it [r]eset hunk" })
            map('v', '<leader>gs', function() gs.stage_hunk { vim.fn.line('.'), vim.fn.line('v') } end,
                { desc = "[g]it [s]tage hunk" })
            map('v', '<leader>gr', function() gs.reset_hunk { vim.fn.line('.'), vim.fn.line('v') } end,
                { desc = "[g]it [r]eset hunk" })

            map("n", "<leader>gb", function() gs.blame_line { full = true } end, { desc = "[g]it show [b]lame" })
        end,
    },
}
