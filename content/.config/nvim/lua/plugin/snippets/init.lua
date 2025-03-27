return {
	"L3MON4D3/LuaSnip",

	lazy = false,

	build = "make install_jsregexp",

	opts = {
		link_children = true,
		keep_roots = true,
		exit_roots = true,
		link_roots = false,
	},

	config = function(plugin, opts)
		local ls = require("luasnip")
		local languages = { "tex" }
		for _, lang in ipairs(languages) do
			local ok, snippets = pcall(require, "plugin.snippets." .. lang)
			if ok then
				ls.add_snippets(lang, snippets)
			else
				vim.notify("Failed to load snippets for " .. lang, vim.log.levels.WARN)
			end
		end
		ls.filetype_extend("markdown", { "tex" })
		ls.setup(opts)
	end,
}
