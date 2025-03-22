local alpha = require("alpha")
local dashboard = require("alpha.themes.dashboard")

local function capture(cmd)
	local f = assert(io.popen(cmd, "r"))
	local s = assert(f:read("*a"))
	f:close()
	s = string.gsub(s, "%?7[hl]", "")        -- Remove starting ^[[?7h or ^[[?7l
	s = string.gsub(s, "\027%[[%d;]*[mK]?", "") -- General ANSI escape sequences
	s = string.gsub(s, "\027%[?%d]*[hIlr]", "") -- Escape sequences for modes like insert (e.g. ^[[?7l, ^[[?7h)
	return s
end

local function split(source, sep)
	local result, i = {}, 1
	while true do
		local a, b = source:find(sep)
		if not a then
			break
		end
		local candidat = source:sub(1, a - 1)
		if candidat ~= "" then
			result[i] = candidat
		end
		i = i + 1
		source = source:sub(b + 1)
	end
	if source ~= "" then
		result[i] = source
	end
	return result
end

dashboard.section.footer.val = "Total plugins: " .. vim.tbl_count(packer_plugins)
dashboard.section.header.opts.hl = "Question"
dashboard.section.buttons.val = {
	dashboard.button("l", "-> open directory session", ":PossessionLoadCwd<CR>"),
	dashboard.button("s", "-> see recent sessions", ":Telescope possession<CR>"),
	dashboard.button("r", "-> search recent files", ":Telescope oldfiles<CR>"),
	dashboard.button("f", "-> search all files", ":Telescope find_files<CR>"),
	dashboard.button("w", "-> write new file", ":enew<CR>"),
	dashboard.button("c", "-> neovim config", ":cd ~/.dot/content/.config/nvim<CR>"),
	dashboard.button("q", "-> quit", ":qa<CR>"),
}
alpha.setup(dashboard.config)

vim.api.nvim_create_augroup("vimrc_alpha", { clear = true })
vim.api.nvim_create_autocmd({ "User" }, {
	group = "vimrc_alpha",
	pattern = "AlphaReady",
	callback = function()
		local header = nil
		if vim.fn.executable("onefetch") == 1 and vim.fn.system("git rev-parse --is-inside-work-tree") == "true\n" then
			header = split(
				capture([[onefetch 2>/dev/null | sed -E 's/\x1B\[[0-9;]*[mK]//g']]),
				"\n"
			)
		else
			header = split(
				[[
                                         ▄▄
                                         ██
Writing with
▀████████▄   ▄▄█▀██  ▄██▀██▄▀██▀   ▀██▀▀███ ▀████████▄█████▄
  ██    ██  ▄█▀   ████▀   ▀██ ██   ▄█    ██   ██    ██    ██
  ██    ██  ██▀▀▀▀▀▀██     ██  ██ ▄█     ██   ██    ██    ██
  ██    ██  ██▄    ▄██▄   ▄██   ███      ██   ██    ██    ██
▄████  ████▄ ▀█████▀ ▀█████▀     █     ▄████▄████  ████  ████▄
				]],
				"\n"
			)
		end
		if next(header) ~= nil then
			require("alpha.themes.dashboard").section.header.val = header
			require("alpha").redraw()
		end
	end,
	once = true,
})
