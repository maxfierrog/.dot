vim.g.mapleader = " "

-- Switch to previous buffer
vim.keymap.set("n", "<bs>", '<c-^>zz', { silent = true, noremap = true })

-- Move to next tab
vim.keymap.set("n", "L", "<C-w>w", { silent = true, noremap = true })

-- Move to previous tab
vim.keymap.set("n", "H", "<C-w>h", { silent = true, noremap = true })

-- Save buffer
vim.keymap.set("n", "<leader>s", ":w<CR>", { silent = true, noremap = true })

-- Quit current buffer
vim.keymap.set("n", "<leader>q", ":q<CR>", { silent = true, noremap = true })

-- Traverse 5 lines up
vim.keymap.set("n", "K", '5k', { silent = true, noremap = true })

-- Traverse 5 lines down
vim.keymap.set("n", "J", '5j', { silent = true, noremap = true })

-- Go to end of line
vim.keymap.set({ "x", "n" }, ";", '$', { silent = true, noremap = true })

-- Restore visual selection
vim.keymap.set("n", "\\", 'gv', { silent = true, noremap = true })

-- Redo
vim.keymap.set('n', 'r', '<Cmd>redo<CR>', { noremap = true, silent = true })

-- Go backward in jump list
vim.keymap.set('n', '(', '<C-o>', { noremap = true, silent = true })

-- Go forwards  in jump list
vim.keymap.set('n', ')', '<C-i>', { noremap = true, silent = true })

-- Select all instances of word under cursor
vim.keymap.set('n', '<leader>a', function()
	local word = vim.fn.expand('<cword>')
	local escaped_word = vim.fn.escape(word, '\\')
	vim.fn.setreg('/', '\\V\\<' .. escaped_word .. '\\>')
	vim.cmd('set hlsearch')
end, { noremap = true, silent = true })

-- Toggle search highlighting
vim.keymap.set('n', '?', ':noh<CR>', { noremap = true, silent = true })

-- Save current session, map it to CWD
vim.keymap.set(
	"n",
	"<Tab>",
	":PossessionSaveCwd!<CR>",
	{ noremap = true, silent = true }
)

-- Toggle file tree
vim.keymap.set("n", "<leader>p", ":NvimTreeToggle<CR>")

-- Toggle undo tree
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)
