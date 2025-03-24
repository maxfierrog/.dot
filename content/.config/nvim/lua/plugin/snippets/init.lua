local ls = require("luasnip")
local languages = { "tex" }
for _, lang in ipairs(languages) do
	local ok, snippets = pcall(require, "snippets." .. lang)
	if ok then
		ls.add_snippets(lang, snippets)
	else
		vim.notify("Failed to load snippets for " .. lang, vim.log.levels.WARN)
	end
end
