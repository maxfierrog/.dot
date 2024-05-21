require("maxfierro.remap")

vim.cmd('highlight ColorColumn guibg=red')
vim.cmd('call matchadd(\'ColorColumn\', \'\\%81v\', 100)')
vim.diagnostic.config({
	virtual_text = false,
	signs = true,
	update_in_insert = true,
	underline = false,
	severity_sort = true,
	float = {
		border = 'rounded',
		source = 'always',
		header = '',
		prefix = '',
	},
})
