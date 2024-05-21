local gsn = require('gitsigns')

gsn.setup({
	signs                             = {
		add          = { text = '┃' },
		change       = { text = '┃' },
		delete       = { text = '_' },
		topdelete    = { text = '‾' },
		changedelete = { text = '~' },
		untracked    = { text = '┆' },
	},
	signcolumn                        = true,
	numhl                             = false,
	linehl                            = false,
	word_diff                         = false,
	watch_gitdir                      = {
		follow_files = true
	},
	auto_attach                       = true,
	attach_to_untracked               = false,
	current_line_blame                = false,
	current_line_blame_opts           = {
		virt_text = true,
		virt_text_pos = 'eol',
		delay = 1000,
		ignore_whitespace = false,
		virt_text_priority = 100,
	},
	current_line_blame_formatter      =
	'<author>, <author_time:%Y-%m-%d> - <summary>',
	current_line_blame_formatter_opts = {
		relative_time = false,
	},
	sign_priority                     = 6,
	update_debounce                   = 100,
	status_formatter                  = nil,
	max_file_length                   = 40000,
	preview_config                    = {
		-- Options passed to nvim_open_win
		border = 'single',
		style = 'minimal',
		relative = 'cursor',
		row = 0,
		col = 1
	},
	on_attach                         = function(bufnr)
		local function map(mode, l, r, opts)
			opts = opts or {}
			opts.buffer = bufnr
			vim.keymap.set(mode, l, r, opts)
		end

		-- Navigation
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
		map('v', '<leader>hs', function() gsn.stage_hunk { vim.fn.line('.'), vim.fn.line('v') } end)
		map('v', '<leader>hr', function() gsn.reset_hunk { vim.fn.line('.'), vim.fn.line('v') } end)
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
})
