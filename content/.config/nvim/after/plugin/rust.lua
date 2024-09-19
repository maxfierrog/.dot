vim.g.rustaceanvim = {
	server = {
		cmd = function()
			local mason_registry = require('mason-registry')
			local ra_binary = mason_registry.is_installed('rust-analyzer')
				and mason_registry.get_package('rust-analyzer'):get_install_path() .. "/rust-analyzer"
				or "rust-analyzer"
			return { ra_binary } -- You can add args to the list, such as '--log-file'
		end,
	},
	default_settings = {
		-- rust-analyzer language server configuration
		['rust-analyzer'] = {
		},
	},
}
