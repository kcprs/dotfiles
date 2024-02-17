return {
  "Civitasv/cmake-tools.nvim",
  config = function()
    require("cmake-tools").setup {
      cmake_build_directory = "_build",
      cmake_generate_options = {
        "-G",
        "Ninja",
        "-DCMAKE_EXPORT_COMPILE_COMMANDS=1",
      },
    }
  end,
}
