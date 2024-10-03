return {
   "rcarriga/nvim-notify",
   config = function()
      local notify = require("notify")
      ---@diagnostic disable-next-line missing-fields
      notify.setup({
         stages = "static"
      })
      vim.notify = notify
   end
}
