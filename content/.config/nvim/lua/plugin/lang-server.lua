return {
	{
		'VonHeikemen/lsp-zero.nvim',

		lazy = false,

		dependencies = {
			{ 'williamboman/mason.nvim' },
			{ 'williamboman/mason-lspconfig.nvim' },
			{ 'neovim/nvim-lspconfig' },
			{ 'hrsh7th/nvim-cmp' },
			{ 'hrsh7th/cmp-nvim-lsp' },
			{ 'L3MON4D3/LuaSnip' },
			{ 'hrsh7th/cmp-nvim-lua' },
			{ 'hrsh7th/cmp-nvim-lsp-signature-help' },
			{ 'hrsh7th/cmp-path' },
			{ 'hrsh7th/cmp-buffer' },
			{ 'saadparwaiz1/cmp_luasnip' }
		},

		config = function()
			local msn_lsp_cfg = require('mason-lspconfig')
			local cmp_action = require('lsp-zero').cmp_action()
			local lsp = require('lsp-zero')
			local msn = require('mason')
			local cmp = require('cmp')
			local ls = require('luasnip')
			local hl = vim.api.nvim_set_hl

			lsp.on_attach(function(client, bufnr)
				local opts = { buffer = bufnr, remap = false }
				lsp.default_keymaps({ buffer = bufnr })

				if client.name == 'marksman' then
					client.server_capabilities.documentFormattingProvider = false
				end

				if client.server_capabilities.documentFormattingProvider then
					local augroup = vim.api.nvim_create_augroup(
						'LspFormatOnSave',
						{ clear = false }
					)

					vim.api.nvim_clear_autocmds(
						{ group = augroup, buffer = bufnr }
					)
					vim.api.nvim_create_autocmd('BufWritePre', {
						group = augroup,
						buffer = bufnr,
						callback = function()
							if vim.bo[bufnr].filetype == "python" then
								local file = vim.api.nvim_buf_get_name(bufnr)
								vim.fn.jobstart(
									{ "uvx", "black", file },
									{
										cwd = vim.fn.getcwd(),
										on_exit = function(_, code)
											if code == 0 then
												vim.schedule(function() vim.cmd("edit!") end)
											else
												vim.schedule(function()
													vim.notify("uvx black failed (exit " .. code .. ")",
														vim.log.levels.ERROR)
												end)
											end
										end,
									}
								)
							else
								vim.lsp.buf.format({ bufnr = bufnr })
							end
						end,
					})
				end

				vim.keymap.set("n", "M", function() vim.lsp.buf.hover() end, opts)
				vim.keymap.set("n", "m", function() vim.lsp.buf.code_action() end, opts)
				vim.keymap.set("n", "<leader>d", function() vim.lsp.buf.definition() end, opts)
				vim.keymap.set("n", "<leader>e", function() vim.diagnostic.open_float() end, opts)
				vim.keymap.set("n", "<leader>r", function() vim.lsp.buf.rename() end, opts)
				vim.keymap.set("n", "<leader>i", function() vim.lsp.buf.signature_help() end, opts)
				vim.keymap.set("n", "]e", function() vim.diagnostic.goto_next() end, opts)
				vim.keymap.set("n", "[e", function() vim.diagnostic.goto_prev() end, opts)
			end)

			cmp.setup({
				sources = {
					{
						name = 'luasnip',
						priority = 60,
						max_item_count = 3,
						keyword_length = 1
					},
					{
						name = 'nvim_lsp',
						priority = 60,
						max_item_count = 3,
						keyword_length = 1
					},
					{
						name = 'nvim_lsp_signature_help',
						priority = 50,
						max_item_count = 3,
						keyword_length = 3
					},
					{
						name = 'buffer',
						priority = 10,
						max_item_count = 1,
						keyword_length = 3
					},
					{
						name = 'path',
						priority = 10,
						max_item_count = 1,
						keyword_length = 1
					},
					{
						name = 'calc',
						priority = 10,
						max_item_count = 1,
						keyword_length = 1
					},
				},
				preselect = 'item',
				completion = {
					completeopt = 'menu,menuone,noinsert'
				},
				window = {
					completion = cmp.config.window.bordered(),
					documentation = cmp.config.window.bordered(),
				},
				mapping = {
					['<CR>'] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.confirm({
								select = true,
							})
						else
							fallback()
						end
					end),

					["<Tab>"] = cmp.mapping(function(fallback)
						if ls.locally_jumpable(1) then
							ls.jump(1)
						else
							fallback()
						end
					end, { "i", "s" }),

					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif ls.locally_jumpable(-1) then
							ls.jump(-1)
						else
							fallback()
						end
					end, { "i", "s" }),

					["<Space>"] = cmp.mapping(function(fallback)
						if ls.expandable() then
							ls.expand()
						else
							fallback()
						end
					end, { "i", "s" }),
				},
				snippet = {
					expand = function(args)
						ls.lsp_expand(args.body)
					end,
				},
				formatting = {
					fields = { 'menu', 'abbr', 'kind' },
					format = function(entry, item)
						local menu_icon = {
							nvim_lsp = 'λ',
							luasnip = 'σ',
							buffer = 'β',
							path = 'π',
							calc = 'γ',
						}
						item.menu = menu_icon[entry.source.name]
						return item
					end,
				},
			})

			lsp.set_sign_icons({
				error = 'ε',
				warn = 'υ',
				hint = 'η',
				info = 'ι'
			})

			hl(0, "DiagnosticError", { fg = "#CC0303", bg = NONE })
			hl(0, "DiagnosticSignError", { fg = "#FF0303", bg = NONE })
			hl(0, "DiagnosticSignHint", { fg = "#03BB09", bg = NONE })
			hl(0, "DiagnosticSignInfo", { fg = "#0309BB", bg = NONE })
			hl(0, "DiagnosticSignWarn", { fg = "#FF9903", bg = NONE })

			msn.setup()

			msn_lsp_cfg.setup({
				handlers = {
					function(server_name)
						require("lspconfig")[server_name].setup({})
					end,
					['rust_analyzer'] = function() end,
				},
				ensure_installed = {
					'clangd',
					'pylsp',
					'marksman',
					'lua_ls',
					'texlab',
					'bashls',
					'yamlls',
					'taplo',
				},
			})

			lsp.setup()
		end
	}
}
