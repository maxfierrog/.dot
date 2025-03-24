vim.cmd [[packadd packer.nvim]]

local packer = require('packer')
packer.init({
	profile = {
		enable = true,
	}
})

return packer.startup(function(use)
	use 'wbthomason/packer.nvim'
	use 'nvim-treesitter/playground'
	use 'kyazdani42/nvim-tree.lua'
	use 'mbbill/undotree'
	use 'nvim-tree/nvim-web-devicons'
	use 'KeitaNakamura/tex-conceal.vim'
	use 'windwp/nvim-autopairs'
	use 'lervag/vimtex'
	use 'tpope/vim-surround'
	use 'numToStr/Comment.nvim'
	use 'rebelot/kanagawa.nvim'
	use 'mrcjkb/rustaceanvim'
	use 'tpope/vim-fugitive'
	use 'junegunn/gv.vim'
	use 'myusuf3/numbers.vim'
	use 'nvim-lualine/lualine.nvim'
	use 'lewis6991/gitsigns.nvim'
	use 'stevearc/oil.nvim'
	use 'dstein64/vim-startuptime'
	use {
		'VonHeikemen/lsp-zero.nvim',
		branch = 'v3.x',
		requires = {
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
		}
	}
	use {
		'nvim-treesitter/nvim-treesitter',
		run = ':TSUpdate'
	}
	use {
		'nvim-telescope/telescope.nvim', tag = '0.1.6',
		requires = { 'nvim-lua/plenary.nvim' }
	}
	use {
		'goolord/alpha-nvim',
		requires = { 'echasnovski/mini.icons' }
	}
	use {
		'jedrzejboczar/possession.nvim',
		requires = { 'nvim-lua/plenary.nvim' },
	}
end)
