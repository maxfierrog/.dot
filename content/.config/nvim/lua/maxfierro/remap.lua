vim.g.mapleader = " "
vim.keymap.set("n", "<bs>", '<c-^>zz', { silent = true, noremap = true })
vim.keymap.set("n", "<Tab>", "<C-w>w")
vim.keymap.set("n", "<S-Tab>", "<C-w>W")
vim.keymap.set("n", "<Space>s", ":w<CR>")
vim.keymap.set("n", "<Space>q", ":q<CR>")
vim.keymap.set("n", "<Space>Q", ":wa<CR>:qa<CR>")
vim.keymap.set("n", "<Space>S", ":wa<CR>")
