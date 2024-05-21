local msn_lsp_cfg = require('mason-lspconfig')
local cmp_action = require('lsp-zero').cmp_action()
local lsp = require('lsp-zero')
local msn = require('mason')
local cmp = require('cmp')
local hl = vim.api.nvim_set_hl

lsp.on_attach(function(client, bufnr)
	local opts = { buffer = bufnr, remap = false }
	lsp.default_keymaps({ buffer = bufnr })
	lsp.buffer_autoformat()
	vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
	vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
	vim.keymap.set("n", "<leader>vs", function() vim.lsp.buf.workspace_symbol() end, opts)
	vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
	vim.keymap.set("n", "<leader>va", function() vim.lsp.buf.code_action() end, opts)
	vim.keymap.set("n", "<leader>vrf", function() vim.lsp.buf.references() end, opts)
	vim.keymap.set("n", "<leader>vre", function() vim.lsp.buf.rename() end, opts)
	vim.keymap.set("n", "<leader>vsi", function() vim.lsp.buf.signature_help() end, opts)
	vim.keymap.set("n", "]d", function() vim.diagnostic.goto_next() end, opts)
	vim.keymap.set("n", "[d", function() vim.diagnostic.goto_prev() end, opts)
end)

cmp.setup({
	sources = {
		{ name = 'vsnip',                   priority = 60, max_item_count = 1, keyword_length = 1 },
		{ name = 'nvim_lsp',                priority = 60, max_item_count = 3, keyword_length = 1 },
		{ name = 'nvim_lsp_signature_help', priority = 50, max_item_count = 3, keyword_length = 3 },
		{ name = 'buffer',                  priority = 40, max_item_count = 1, keyword_length = 3 },
		{ name = 'path',                    priority = 10, max_item_count = 1, keyword_length = 1 },
		{ name = 'calc',                    priority = 10, max_item_count = 1, keyword_length = 1 },
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
		['<Tab>'] = cmp_action.luasnip_supertab(),
		['<S-Tab>'] = cmp_action.luasnip_shift_supertab(),
		['<CR>'] = cmp.mapping.confirm({ select = false }),
	},
	snippet = {
		expand = function(args)
			require('luasnip').lsp_expand(args.body)
		end,
	},
	formatting = {
		fields = { 'menu', 'abbr', 'kind' },
		format = function(entry, item)
			local menu_icon = {
				nvim_lsp = 'λ',
				vsnip = 'σ',
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
	automatic_installation = { exclude = { 'rust_analyzer' } },
	handlers = {
		function(server_name)
			require('lspconfig')[server_name].setup({})
		end,
	}
})

lsp.setup()
