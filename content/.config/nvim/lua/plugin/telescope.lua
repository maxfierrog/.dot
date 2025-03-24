return {
	{
		'nvim-telescope/telescope.nvim',

		dependencies = { 'nvim-lua/plenary.nvim' },

		opts = {
			pickers = {
				live_grep = {
					file_ignore_patterns = {
						'node_modules',
						'.git',
						'.venv'
					},
					additional_args = function()
						return { "--hidden" }
					end
				},
				find_files = {
					file_ignore_patterns = {
						'node_modules',
						'.git',
						'.venv'
					},
					hidden = true
				},
				oldfiles = {
					cwd_only = true,
				}
			},
			extensions = {
				"fzf"
			},
			defaults = {
				layout_strategy = 'vertical',
				layout_config = {
					vertical = { width = 0.8 }
				},
			},
		},

		config = function()
			local tscb = require('telescope.builtin')
			vim.keymap.set('n', '<leader>fi', tscb.find_files, {})
			vim.keymap.set('n', '<leader>fg', tscb.live_grep, {})
			vim.keymap.set('n', '<leader>fd', tscb.lsp_workspace_symbols, {})
			vim.keymap.set('n', '<leader>fb', tscb.git_branches, {})
			vim.keymap.set('n', '<leader>fc', tscb.command_history, {})
			vim.keymap.set('n', '<leader>fv', tscb.git_commits, {})
			vim.keymap.set('n', '<leader>fr', tscb.oldfiles, {})
		end
	}
}
