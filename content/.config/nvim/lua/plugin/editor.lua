return {
	{ 'mbbill/undotree' },
	{ 'tpope/vim-surround' },
	{ 'tpope/vim-fugitive' },
	{ 'numToStr/Comment.nvim' },
	{ 'KeitaNakamura/tex-conceal.vim' },
	{
		"greggh/claude-code.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		config = function()
			require("claude-code").setup({
				window = {
					position = "float",
					float = {
						width = "80%",
						height = "80%",
					},
				},
				refresh = {
					enable = true,
					updatetime = 100,
					timer_interval = 500,
					show_notifications = true,
				},
				git = {
					use_git_root = true,
				},
				shell = {
					separator = '&&',
					pushd_cmd = 'pushd',
					popd_cmd = 'popd',
				},
				command = "claude",
				command_variants = {
					continue = "--continue",
					resume = "--resume",
					verbose = "--verbose",
				},
				keymaps = {
					toggle = {
						normal = "<leader>c",
						variants = {
							continue = "<leader>CC",
							verbose = "<leader>CV",
						},
					},
				}
			})
		end
	},
	{
		"iamcco/markdown-preview.nvim",
		ft = { "markdown" },
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		build = function() vim.fn["mkdp#util#install"]() end,
		config = function()
			vim.g.mkdp_auto_start = 0
			vim.g.mkdp_refresh_slow = 1
			vim.api.nvim_create_autocmd({
				"InsertEnter",
				"InsertLeave",
				"TextChangedI"
			}, {
				pattern = "*.md",
				callback = function()
					-- noop
				end,
			})
		end,
		keys = {
			{
				"<leader>mp",
				"<cmd>MarkdownPreviewToggle<CR>",
				desc = "Toggle Markdown Preview",
			},
		},
	},
	{
		'rcarriga/nvim-notify',

		lazy = false,

		opts = {
			background_colour = "NotifyBackground",
			fps = 1,
			icons = {
				DEBUG = "[d]",
				ERROR = "[e]",
				INFO = "[i]",
				TRACE = "[t]",
				WARN = "[w]"
			},
			level = 2,
			minimum_width = 50,
			render = "default",
			stages = "static",
			time_formats = {
				notification = "%T",
				notification_history = "%FT%T"
			},
			timeout = 3500,
			top_down = true
		},

		config = function(plugin, opts)
			local notify = require('notify')
			vim.notify = notify
			notify.setup(opts)
		end
	},
	{
		'rebelot/kanagawa.nvim',

		lazy = false,

		opts = {
			compile = false,
			undercurl = true,
			commentStyle = { italic = true },
			functionStyle = {},
			keywordStyle = { italic = true },
			statementStyle = { bold = true },
			typeStyle = {},
			transparent = true,
			dimInactive = false,
			terminalColors = false,
			colors = {
				palette = {},
				theme = { wave = {}, lotus = {}, dragon = {}, all = {} },
			},
			overrides = function(colors)
				return {}
			end,
			theme = "dark",
			background = {
				dark = "dragon",
				light = "lotus"
			},
		},

		config = function(plugin, opts)
			require('kanagawa').setup(opts)
			vim.cmd("colorscheme kanagawa")
		end
	},
	{
		'windwp/nvim-autopairs',

		config = function()
			local conds = require('nvim-autopairs.ts-conds')
			local rule = require('nvim-autopairs.rule')
			local atp = require('nvim-autopairs')

			atp.setup({
				check_ts = true,
			})

			atp.add_rules({
				rule("%", "%", "lua")
					:with_pair(conds.is_ts_node({ 'string', 'comment' })),
				rule("$", "$", "lua")
					:with_pair(conds.is_not_ts_node({ 'function' }))
			})

			atp.setup({
				disable_filetype = { "TelescopePrompt", "vim" },
				disable_in_macro = true,
				disable_in_visualblock = false,
				disable_in_replace_mode = true,
				ignored_next_char = [=[[%w%%%'%[%"%.%`%$]]=],
				enable_moveright = true,
				enable_afterquote = true,
				enable_check_bracket_line = true,
				enable_bracket_in_quote = true,
				enable_abbr = false,
				break_undo = true,
				check_ts = false,
				map_cr = true,
				map_bs = true,
				map_c_h = false,
				map_c_w = false,
			})
		end
	},
	{
		'myusuf3/numbers.vim',

		lazy = false,

		init = function()
			vim.g.numbers_exclude = {
				'unite',
				'tagbar',
				'startify',
				'gundo',
				'vimshell',
				'w3m',
				'NvimTree',
				'alpha'
			}
		end
	},
	{
		'lervag/vimtex',

		init = function()
			vim.g.vimtex_quickfix_mode = 0
			vim.g.vimtex_view_method = 'skim'
			vim.g.tex_conceal = 'abdmg'
			vim.g.tex_flavor = 'latex'
		end
	},
	{
		'nvim-lualine/lualine.nvim',

		lazy = false,

		opts = {
			options = {
				icons_enabled = false,
				theme = 'auto',
				component_separators = { left = '', right = '' },
				section_separators = { left = '', right = '' },
				disabled_filetypes = {
					'NvimTree',
					'alpha'
				},
				ignore_focus = {},
				always_divide_middle = true,
				globalstatus = false,
				refresh = {
					statusline = 100,
					tabline = 100,
					winbar = 100,
				}
			},
			sections = {
				lualine_a = { 'mode' },
				lualine_b = { 'branch', 'diff', 'diagnostics' },
				lualine_c = { 'filename' },
				lualine_x = { 'encoding', 'fileformat', 'filetype' },
				lualine_y = { 'progress' },
				lualine_z = { 'location' }
			},
			inactive_sections = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = { 'filename' },
				lualine_x = { 'location' },
				lualine_y = {},
				lualine_z = {}
			},
			tabline = {},
			winbar = {},
			inactive_winbar = {},
			extensions = {}
		},

		config = function(plugin, opts)
			require('lualine').setup(opts)
		end
	},
	{
		'lewis6991/gitsigns.nvim',

		lazy = false,

		config = function(plugin, opts)
			local gsn = require('gitsigns')
			opts.on_attach = function(bufnr)
				local function map(mode, l, r, opts)
					opts = opts or {}
					opts.buffer = bufnr
					vim.keymap.set(mode, l, r, opts)
				end

				map('n', ']h', function()
					if vim.wo.diff then
						vim.cmd.normal({ ']h', bang = true })
					else
						gsn.nav_hunk('next')
					end
				end)

				map('n', '[h', function()
					if vim.wo.diff then
						vim.cmd.normal({ '[h', bang = true })
					else
						gsn.nav_hunk('prev')
					end
				end)

				-- Actions
				map('n', '<leader>hs', gsn.stage_hunk)
				map('n', '<leader>hr', gsn.reset_hunk)
				map('v', '<leader>hs', function()
					gsn.stage_hunk { vim.fn.line('.'), vim.fn.line('v') }
				end)

				map('v', '<leader>hr', function()
					gsn.reset_hunk { vim.fn.line('.'), vim.fn.line('v') }
				end)

				map('n', '<leader>hS', gsn.stage_buffer)
				map('n', '<leader>hu', gsn.undo_stage_hunk)
				map('n', '<leader>hR', gsn.reset_buffer)
				map('n', '<leader>hp', gsn.preview_hunk)
				map('n', '<leader>hb', function() gsn.blame_line { full = true } end)
				map('n', '<leader>tb', gsn.toggle_current_line_blame)
				map('n', '<leader>hd', gsn.diffthis)
				map('n', '<leader>hD', function() gsn.diffthis('~') end)
				map('n', '<leader>td', gsn.toggle_deleted)

				-- Text object
				map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>')

				vim.cmd('highlight GitSignsAdd guibg=NONE')
				vim.cmd('highlight GitSignsChange guibg=NONE')
				vim.cmd('highlight GitSignsDelete guibg=NONE')
				vim.cmd('highlight GitSignsChangeDelete guibg=NONE')
				vim.cmd('highlight GitSignsUntracked guibg=NONE')
				vim.cmd('highlight GitSignsTopDelete guibg=NONE')
			end
			gsn.setup(opts)
		end,

		opts = {
			signs                        = {
				add          = { text = '┃' },
				change       = { text = '┃' },
				delete       = { text = '_' },
				topdelete    = { text = '‾' },
				changedelete = { text = '~' },
				untracked    = { text = '┆' },
			},
			signcolumn                   = true,
			numhl                        = false,
			linehl                       = false,
			word_diff                    = false,
			watch_gitdir                 = {
				follow_files = true
			},
			auto_attach                  = true,
			attach_to_untracked          = false,
			current_line_blame           = true,
			current_line_blame_opts      = {
				virt_text = true,
				virt_text_pos = 'eol',
				delay = 1200,
				ignore_whitespace = true,
				virt_text_priority = 100,
			},
			current_line_blame_formatter =
			'<author>, <author_time:%Y-%m-%d> - <summary>',
			sign_priority                = 6,
			update_debounce              = 100,
			status_formatter             = nil,
			max_file_length              = 40000,
			preview_config               = {
				border = 'single',
				style = 'minimal',
				relative = 'cursor',
				row = 0,
				col = 1
			},
		}
	}
}
