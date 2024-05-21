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
