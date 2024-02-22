local M = {}

-- We cache the results of "git rev-parse"
-- Process creation is expensive in Windows, so this reduces latency
local is_inside_work_tree = {}

function M.project_files()
    local cwd = vim.fn.getcwd()
    if is_inside_work_tree[cwd] == nil then
        vim.fn.system("git rev-parse --is-inside-work-tree")
        is_inside_work_tree[cwd] = vim.v.shell_error == 0
    end

    if is_inside_work_tree[cwd] then
        require("telescope.builtin").git_files()
    else
        require("telescope.builtin").find_files({ hidden = true, no_ignore = true })
    end
end

return {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        -- Fuzzy Finder Algorithm which requires local dependencies to be built.
        -- Only load if `make` is available. Make sure you have the system
        -- requirements installed.
        {
            "nvim-telescope/telescope-fzf-native.nvim",
            -- NOTE: If you are having trouble with this installation,
            --       refer to the README for telescope-fzf-native for more instructions.
            build = "make",
            cond = function()
                return vim.fn.executable("make") == 1
            end,
        },
    },
    config = function()
        require("telescope").setup({
            defaults = {
                mappings = {
                    i = {
                        -- ['<C-u>'] = false,
                        -- ['<C-d>'] = false, -- Did I set these?
                        -- ["<esc>"] = require("telescope.actions").close,
                        ["jk"] = require("telescope.actions").close,
                        ["<C-h>"] = require("telescope.actions").which_key,
                    },
                    n = {
                        ["<c-c>"] = require("telescope.actions").close,
                    }
                },

                file_ignore_patterns = { "%.git/" },
            },
        })

        -- Enable telescope fzf native, if installed
        pcall(require("telescope").load_extension, "fzf")

        -- See `:help telescope.builtin`
        vim.keymap.set("n", "<leader>fd", M.project_files, { desc = "[f]in[d] project files (git with fallback)"})
        vim.keymap.set("n", "<leader>fD", function()
            require("telescope.builtin").find_files({ hidden = true, no_ignore = true })
        end, { desc = "[f]in[D] ALL files" })
        vim.keymap.set("n", "<leader>fg", require("telescope.builtin").git_files, { desc = "[f]ind [g]it files" })
        vim.keymap.set("n", "<leader>fb", require("telescope.builtin").buffers, { desc = "[f]ind existing [b]uffers" })
        vim.keymap.set("n", "<leader>fr", require("telescope.builtin").live_grep, { desc = "[f]ind by g[r]ep" })
        vim.keymap.set("n", "<leader>fh", require("telescope.builtin").help_tags, { desc = "[f]ind in [h]elp" })
        vim.keymap.set("n", "<leader>fo", require("telescope.builtin").oldfiles, { desc = "[f]ind [o]ld opened files" })
        vim.keymap.set("n", "<leader>fk", require("telescope.builtin").keymaps, { desc = "[f]ind [k]eymaps" })
        vim.keymap.set("n", "<leader>fc", require("telescope.builtin").commands, { desc = "[f]ind [c]ommands" })
        vim.keymap.set("n", "<leader>fs", require("telescope.builtin").grep_string, { desc = "[f]ind [s]tring" })
        vim.keymap.set("n", "<leader>ff", require("telescope.builtin").resume, { desc = "Resume previous search" })

        --------------
        vim.keymap.set("n", "<leader>/", function()
            -- You can pass additional configuration to telescope to change theme, layout, etc.
            require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
                winblend = 10,
                previewer = false,
            }))
        end, { desc = "[/] Fuzzily search in current buffer" })

        vim.keymap.set(
            "n",
            "<leader>sw",
            require("telescope.builtin").grep_string,
            { desc = "[S]earch current [W]ord" }
        )
        vim.keymap.set("n", "<leader>sG", ":LiveGrepGitRoot<cr>", { desc = "[S]earch by [G]rep on Git Root" })
        vim.keymap.set("n", "<leader>sd", require("telescope.builtin").diagnostics, { desc = "[S]earch [D]iagnostics" })

        --------------
        -- From nvim kickstart, probably will not use this

        -- -- Telescope live_grep in git root
        -- -- Function to find the git root directory based on the current buffer's path
        -- local function find_git_root()
        --   -- Use the current buffer's path as the starting point for the git search
        --   local current_file = vim.api.nvim_buf_get_name(0)
        --   local current_dir
        --   local cwd = vim.fn.getcwd()
        --   -- If the buffer is not associated with a file, return nil
        --   if current_file == "" then
        --     current_dir = cwd
        --   else
        --     -- Extract the directory from the current file's path
        --     current_dir = vim.fn.fnamemodify(current_file, ":h")
        --   end
        --
        --   -- Find the Git root directory from the current file's path
        --   local git_root = vim.fn.systemlist("git -C " .. vim.fn.escape(current_dir, " ") .. " rev-parse --show-toplevel")[1]
        --   if vim.v.shell_error ~= 0 then
        --     print("Not a git repository. Searching on current working directory")
        --     return cwd
        --   end
        --   return git_root
        -- end
        --
        -- -- Custom live_grep function to search in git root
        -- local function live_grep_git_root()
        --   local git_root = find_git_root()
        --   if git_root then
        --     require('telescope.builtin').live_grep({
        --       search_dirs = { git_root },
        --     })
        --   end
        -- end
        --
        -- vim.api.nvim_create_user_command('LiveGrepGitRoot', live_grep_git_root, {})
    end,
}
