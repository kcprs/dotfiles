local status_ok, telescope = pcall(require, "telescope")
if not status_ok then
  return
end

telescope.setup {
  defaults = {
    prompt_prefix = " ",
    sorting_strategy = "ascending",
    file_ignore_patterns = { ".git/" },
    layout_config = {
      prompt_position = "top",
    },
  },
}

telescope.load_extension("fzf")
