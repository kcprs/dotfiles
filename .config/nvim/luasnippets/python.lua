require("luasnip.session.snippet_collection").clear_snippets("python")

local ls = require("luasnip")
local parse = ls.parser.parse_snippet

ls.add_snippets("python", {
	parse("__main__", 'def main():\n    $0\n\nif __name__ == "__main__":\n    main()\n')
})
