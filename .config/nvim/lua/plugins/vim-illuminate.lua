return {
    "RRethy/vim-illuminate",
    config = function()
        require("illuminate").configure({
            large_file_cutoff = 10000,
        })
    end,
}
