return {
	{
		"nvim-treesitter/playground",

		cmd          = "TSPlaygroundToggle",

		dependencies = { "nvim-treesitter/nvim-treesitter" },
	},
	{
		"nvim-treesitter/nvim-treesitter",

		lazy   = false,

		build  = ":TSUpdate",

		opts   = {
			ensure_installed = {
				"rust", "c", "lua", "vim", "vimdoc", "query", "markdown",
			},
			sync_install = false,
			auto_install = true,
			highlight = {
				enable = true,
				disable = { "latex" },
			},
			indent = { enable = true },
			fold = { enable = false },
			rainbow = {
				enable         = true,
				extended_mode  = true,
				max_file_lines = nil,
			},
		},

		config = function(_, opts)
			require("nvim-treesitter.configs").setup(opts)
		end,
	},
}
