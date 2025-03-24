return {
	{ 'nvim-treesitter/playground' },
	{
		'nvim-treesitter/nvim-treesitter',

		opts = {
			ensure_installed = {
				"rust",
				"c",
				"lua",
				"vim",
				"vimdoc",
				"query"
			},
			sync_install = false,
			auto_install = true,
			highlight = {
				enable = true,
				disable = { "latex" },
			},
			indent = false,
			ident = { enable = true },
			rainbow = {
				enable = true,
				extended_mode = true,
				max_file_lines = nil,
			}
		},
	}
}
