return {
	{
		"nvim-treesitter/playground",

		cmd = "TSPlaygroundToggle",

		dependencies = { "nvim-treesitter/nvim-treesitter" },
	},
	{
		"nvim-treesitter/nvim-treesitter",

		build = ":TSUpdate",

		event = { "BufReadPost", "BufNewFile" },

		opts = {
			ensure_installed = {
				"rust",
				"c",
				"lua",
				"vim",
				"vimdoc",
				"query",
				"markdown",
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
