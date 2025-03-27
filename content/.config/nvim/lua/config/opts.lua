vim.cmd('set cc=81')
vim.cmd('set tabstop=4')
vim.cmd('set softtabstop=0')
vim.cmd('set shiftwidth=0')
vim.cmd('set conceallevel=1')
vim.cmd('set clipboard=unnamedplus')
vim.cmd('highlight ColorColumn ctermbg=grey')
vim.cmd('hi LineNr guibg=NONE')
vim.cmd('hi SignColumn guibg=NONE')

vim.o.scrolloff = 10
vim.diagnostic.config({
	virtual_text = false,
	signs = false,
	update_in_insert = false,
	underline = true,
	severity_sort = true,
})

vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
vim.opt.completeopt = { 'menuone', 'noselect', 'noinsert' }
vim.opt.shortmess = vim.opt.shortmess + { c = true }
vim.opt.termguicolors = true;
vim.opt.signcolumn = "yes"
