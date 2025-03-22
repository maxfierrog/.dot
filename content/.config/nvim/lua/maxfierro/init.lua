require("maxfierro.remap")

vim.cmd('set tabstop=4')
vim.cmd('set softtabstop=0')
vim.cmd('set shiftwidth=0')

vim.o.scrolloff = 10
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

vim.cmd('set cc=81')
vim.cmd('highlight ColorColumn ctermbg=grey')
vim.cmd('set clipboard=unnamedplus')
