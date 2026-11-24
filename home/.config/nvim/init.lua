require("custom.options")

local keymaps = require("custom.keymaps")

-- NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
keymaps.setup_leader()

require("plugins").setup()

keymaps.setup_basic()

require("custom.autocommands")
require("custom.commands")
require("custom.builtin-plugins")
