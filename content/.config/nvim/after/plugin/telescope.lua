local tsc_builtin = require('telescope.builtin')
local tsc = require('telescope')

vim.keymap.set('n', '<leader>ff', tsc_builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', tsc_builtin.live_grep, {})
vim.keymap.set('n', '<leader>fi', tsc_builtin.git_files, {})
vim.keymap.set('n', '<leader>fd', tsc_builtin.lsp_workspace_symbols, {})
vim.keymap.set('n', '<leader>fb', tsc_builtin.git_branches, {})
vim.keymap.set('n', '<leader>fj', tsc_builtin.command_history, {})
vim.keymap.set('n', '<leader>fk', tsc_builtin.git_commits, {})

tsc.setup({
	pickers = {
		live_grep = {
			file_ignore_patterns = { 'node_modules', '.git', '.venv' },
			additional_args = function(_)
				return { "--hidden" }
			end
		},
		find_files = {
			file_ignore_patterns = { 'node_modules', '.git', '.venv' },
			hidden = true
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
})
