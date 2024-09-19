require("maxfierro.remap")

vim.cmd('highlight ColorColumn guibg=red')
vim.cmd('call matchadd(\'ColorColumn\', \'\\%81v\', 100)')

vim.cmd('set tabstop=4')
vim.cmd('set softtabstop=0')
vim.cmd('set shiftwidth=0')

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
