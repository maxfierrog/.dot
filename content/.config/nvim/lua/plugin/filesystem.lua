return {
	{ 'nvim-tree/nvim-web-devicons' },
	{
		'jedrzejboczar/possession.nvim',

		lazy = false,

		dependencies = { 'nvim-lua/plenary.nvim' },

		config = function(plugin, opts)
			require('possession').setup(opts)
		end
	},
	{
		'kyazdani42/nvim-tree.lua',

		lazy = false,

		init = function(plugin)
			vim.g.loaded_netrw = 1
			vim.g.loaded_netrwPlugin = 1
			vim.api.nvim_set_option('updatetime', 300)
		end,

		opts = {
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
		},

		config = function(plugin, opts)
			opts.on_attach = function(bufnr)
				local api = require('nvim-tree.api')
				local function opts(desc)
					return {
						desc = "nvim-tree: " .. desc,
						buffer = bufnr,
						noremap = true,
						silent = true,
						nowait = true
					}
				end

				api.config.mappings.default_on_attach(bufnr)
				vim.keymap.del('n', 'H', { buffer = bufnr })
				vim.keymap.del('n', 'L', { buffer = bufnr })
				vim.keymap.del('n', '<bs>', { buffer = bufnr })
			end
			require('nvim-tree').setup(opts)
		end
	},
	{
		'stevearc/oil.nvim',

		lazy = false,

		opts = {
			watch_for_changes = true,
			keymaps = {
				["<CR>"] = "actions.select",
				["-"] = { "actions.parent", mode = "n" },
				["_"] = { "actions.open_cwd", mode = "n" },
				["g."] = { "actions.toggle_hidden", mode = "n" },
			},
			use_default_keymaps = true,
			view_options = {
				show_hidden = true,
				is_hidden_file = function(name, bufnr)
					local m = name:match("^%.")
					return m ~= nil
				end,
				is_always_hidden = function(name, bufnr)
					return false
				end,
				natural_order = "fast",
				case_insensitive = false,
				sort = {
					{ "type", "asc" },
					{ "name", "asc" },
				},
				highlight_filename = function(
					entry,
					is_hidden,
					is_link_target,
					is_link_orphan
				)
					return nil
				end,
			},
			float = {
				padding = 0,
				max_width = 0.8,
				max_height = 0.8,
				border = "rounded",
				win_options = {
					winblend = 0,
				},
				get_win_title = nil,
				preview_split = "auto",
				override = function(conf)
					return conf
				end,
			},
		},

		config = function(plugin, opts)
			local oil = require('oil')
			oil.setup(opts)
			vim.keymap.set('n', '<leader>o', function() oil.toggle_float() end)
		end

	}
}
