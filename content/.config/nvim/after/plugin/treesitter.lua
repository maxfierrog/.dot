local tsr = require('nvim-treesitter.configs')

tsr.setup({
	ensure_installed = { "rust", "c", "lua", "vim", "vimdoc", "query" },
	sync_install = false,
	auto_install = true,
	highlight = {
		enable = true,
		disable = { "latex" },
	},
	ident = { enable = true },
	rainbow = {
		enable = true,
		extended_mode = true,
		max_file_lines = nil,
	}
})
