local tsc_builtin = require('telescope.builtin')
local tsc = require('telescope')

vim.keymap.set('n', '<leader>ff', tsc_builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', tsc_builtin.live_grep, {})
vim.keymap.set('n', '<leader>fi', tsc_builtin.git_files, {})
vim.keymap.set('n', '<leader>fd', tsc_builtin.lsp_workspace_symbols, {})
vim.keymap.set('n', '<leader>fb', tsc_builtin.git_branches, {})

tsc.setup({
	defaults = {
		layout_strategy = 'vertical',
		layout_config = {
			vertical = { width = 0.8 }
		},
	},
})
