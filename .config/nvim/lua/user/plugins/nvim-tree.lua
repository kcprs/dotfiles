local status_ok, nvim_tree = pcall(require, "nvim-tree")
if not status_ok then
  return
end

-- Recommended settings from nvim-tree documentation
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

nvim_tree.setup {
  renderer = {
    icons = {
      glyphs = {
        git = {
          unstaged = "",
          staged = "S",
          unmerged = "M",
          renamed = "R",
          untracked = "U",
          deleted = "D",
          ignored = "◌",
        },
      },
    },
  },
  diagnostics = {
    enable = true,
    show_on_dirs = true,
    icons = {
      hint = "",
      info = "",
      warning = "",
      error = "",
    },
  },
  view = {
    side = "right",
  },
}
