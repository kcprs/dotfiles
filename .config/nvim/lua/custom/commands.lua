vim.api.nvim_create_user_command("RemoveAllTrailingWhitespace", [[%s/\s\+$//e]], {})

local function copy_absolute_path_to_clipboard()
  local filepath = vim.fn.expand("%:p")
  vim.fn.setreg("*", filepath)
  vim.fn.setreg('"', filepath)
  print("Copied absolute path: " .. filepath)
end
vim.api.nvim_create_user_command("CopyAbsolutePath", copy_absolute_path_to_clipboard, {})

local function copy_relative_path_to_clipboard()
  local filepath = vim.fn.expand("%:p")
  local relative_path = vim.fn.fnamemodify(filepath, ":~:.")
  vim.fn.setreg("*", relative_path)
  vim.fn.setreg('"', relative_path)
  print("Copied relative path: " .. relative_path)
end
vim.api.nvim_create_user_command("CopyRelativePath", copy_relative_path_to_clipboard, {})

local function copy_file_name_to_clipboard()
  local filename = vim.fn.expand("%:t")
  vim.fn.setreg("*", filename)
  vim.fn.setreg('"', filename)
  print("Copied file name: " .. filename)
end
vim.api.nvim_create_user_command("CopyFileName", copy_file_name_to_clipboard, {})

