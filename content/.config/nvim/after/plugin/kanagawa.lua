local kgw = require('kanagawa')

kgw.setup({
	compile = false,
	undercurl = true,
	commentStyle = { italic = true },
	functionStyle = {},
	keywordStyle = { italic = true },
	statementStyle = { bold = true },
	typeStyle = {},
	transparent = true,
	dimInactive = false,
	terminalColors = false,
	colors = {
		palette = {},
		theme = { wave = {}, lotus = {}, dragon = {}, all = {} },
	},
	overrides = function(colors)
		return {}
	end,
	theme = "dark",
	background = {
		dark = "dragon",
		light = "lotus"
	},
})

vim.cmd("colorscheme kanagawa")
