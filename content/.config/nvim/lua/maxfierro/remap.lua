local function spell_correct()
	vim.cmd('normal! <C-g>u<Esc>[s1z=`]a<C-g>u')
end

vim.g.mapleader = " "
vim.keymap.set("n", "<bs>", '<c-^>zz', { silent = true, noremap = true })
vim.keymap.set("n", "<Tab>", "<C-w>w")
vim.keymap.set("n", "<Space>s", ":w<CR>")
vim.keymap.set("n", "<Space>q", ":q<CR>")
vim.keymap.set("n", "<Space>Q", ":wa<CR>:qa<CR>")
vim.keymap.set("n", "<Space>S", ":wa<CR>")

vim.keymap.set("i", "<C-s>", "<Cmd>lua spell_correct()<CR>", { noremap = true, silent = true })
