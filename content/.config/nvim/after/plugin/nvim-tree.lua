local nvt = require("nvim-tree")

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.api.nvim_set_option('updatetime', 300)
vim.keymap.set("n", "<leader>p", ":NvimTreeToggle<CR>")

local function custom_on_attach(bufnr)
	local api = require "nvim-tree.api"

	local function opts(desc)
		return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
	end

	api.config.mappings.default_on_attach(bufnr)

	-- Already using H for switching windows
	vim.keymap.del('n', 'H', { buffer = bufnr })
	vim.keymap.del('n', 'L', { buffer = bufnr })

	-- Already using backspace for switching buffers
	vim.keymap.del('n', '<bs>', { buffer = bufnr })
end

nvt.setup({
	sort = {
		sorter = "case_sensitive",
	},
	view = {
		side = 'right',
		width = 35,
	},
	renderer = {
		group_empty = true,
	},
	filters = {
		dotfiles = false,
	},
	on_attach = custom_on_attach,
})
