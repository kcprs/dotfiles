return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function ()
    local harpoon = require("harpoon")
    harpoon:setup()

    vim.keymap.set("n", "<leader>ha", function() harpoon:list():append() end, { desc = "[h]arpoon [a]ppend" })
    vim.keymap.set("n", "<leader>ht", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "[h]arpoon [t]oggle" })

    vim.keymap.set("n", "<leader>hh", function() harpoon:list():select(1) end, { desc = "[h]arpoon file 1" })
    vim.keymap.set("n", "<leader>hj", function() harpoon:list():select(2) end, { desc = "[h]arpoon file 2" })
    vim.keymap.set("n", "<leader>hk", function() harpoon:list():select(3) end, { desc = "[h]arpoon file 3" })
    vim.keymap.set("n", "<leader>hl", function() harpoon:list():select(4) end, { desc = "[h]arpoon file 4" })

    -- Toggle previous & next buffers stored within Harpoon list
    vim.keymap.set("n", "<leader>hp", function() harpoon:list():prev() end, { desc = "[h]arpoon [p]revious" })
    vim.keymap.set("n", "<leader>hn", function() harpoon:list():next() end, { desc = "[h]arpoon [n]ext" })
  end
}
