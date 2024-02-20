vim.api.nvim_create_user_command("RemoveAllTrailingWhitespace", [[%s/\s\+$//e]], {})
