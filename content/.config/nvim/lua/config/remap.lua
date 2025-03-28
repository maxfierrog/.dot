
-- DEFINITIONS

-- Local table to track tex bindings per filetype
local tex_in_filetypes = {}

-- Function to toggle tex bindings for current filetype 
function toggle_tex_bindings()
  local filetype = vim.bo.filetype

  if tex_in_filetypes[filetype] == nil then
    tex_in_filetypes[filetype] = false
  end

  if tex_in_filetypes[filetype] then
    tex_in_filetypes[filetype] = false
    require("luasnip").filetype_set(filetype, { filetype })
    vim.notify("Tex bindings removed from " .. filetype, vim.log.levels.INFO)
  else
    tex_in_filetypes[filetype] = true
    require("luasnip").filetype_set(filetype, { filetype, "tex" })
    vim.notify("Tex bindings added to " .. filetype, vim.log.levels.INFO)
  end
end


-- LEADER

vim.g.mapleader = " "


-- NAVIGATION

-- Switch to previous buffer
vim.keymap.set("n", "<bs>", '<c-^>zz', { silent = true, noremap = true })

-- Go 6 lines up 
vim.keymap.set({"x", "n"}, "K", "6k", { silent = true, noremap = true })

-- Go 6 lines down 
vim.keymap.set({"x", "n"}, "J", "6j", { silent = true, noremap = true })

-- Open a split right
vim.keymap.set("n", ">", ":vs<CR>", { silent = true, noremap = true })

-- Open a split left
vim.keymap.set("n", "<", ":leftabove vs<CR>", { silent = true, noremap = true })

-- Move to next split 
vim.keymap.set("n", "L", "<C-w>w", { silent = true, noremap = true })

-- Move to previous split
vim.keymap.set("n", "H", "<C-w>W", { silent = true, noremap = true })

-- Switch with right split
vim.keymap.set("n", "<leader>L", "<C-w>L", { silent = true, noremap = true })

-- Switch with left split
vim.keymap.set("n", "<leader>H", "<C-w>H", { silent = true, noremap = true })


-- MANIPULATION

-- Save buffer
vim.keymap.set("n", "<leader>s", ":w<CR>", { silent = true, noremap = true })

-- Quit current buffer
vim.keymap.set("n", "<leader>q", ":q<CR>", { silent = true, noremap = true })

-- Quit all buffers 
vim.keymap.set("n", "<leader>Q", ":qa<CR>", { silent = true, noremap = true })

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

-- Toggle file tree
vim.keymap.set("n", "<leader>p", ":NvimTreeToggle<CR>")

-- Toggle undo tree
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)



-- SPECIAL

-- Toggle tex bindings for current filetype
vim.keymap.set("n", "<leader>T", [[:lua toggle_tex_bindings()<CR>]], { noremap = true, silent = true })


-- AUTOCOMMANDS

-- Save session before closing
vim.api.nvim_create_autocmd("VimLeavePre", {
    callback = function()
        vim.cmd("PossessionSaveCwd!")
    end,
})

