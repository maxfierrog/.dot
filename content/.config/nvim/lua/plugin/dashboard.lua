local neovim_banner = [[
                                         ▄▄
                                         ██
Waste time with
▀████████▄   ▄▄█▀██  ▄██▀██▄▀██▀   ▀██▀▀███ ▀████████▄█████▄
  ██    ██  ▄█▀   ████▀   ▀██ ██   ▄█    ██   ██    ██    ██
  ██    ██  ██▀▀▀▀▀▀██     ██  ██ ▄█     ██   ██    ██    ██
  ██    ██  ██▄    ▄██▄   ▄██   ███      ██   ██    ██    ██
▄████  ████▄ ▀█████▀ ▀█████▀     █     ▄████▄████  ████  ████▄
]]

local function capture(cmd)
	local f = assert(io.popen(cmd, "r"))
	local s = assert(f:read("*a"))
	f:close()
	s = string.gsub(s, "%?7[hl]", "")
	s = string.gsub(s, "\027%[[%d;]*[mK]?", "")
	s = string.gsub(s, "\027%[?%d]*[hIlr]", "")
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

return {
	{
		'goolord/alpha-nvim',
		dependencies = { 'echasnovski/mini.icons' }
		config = function()
			local plugct = require("lazy").stats().loaded
			local dashboard = require('alpha.themes.dashboard')
			local alpha = require('alpha')

			dashboard.section.footer.val = "Total plugins: " .. plugct
			dashboard.section.header.opts.hl = "Question"
			dashboard.section.buttons.val = {
				dashboard.button(
					"d",
					"-> open directory session",
					":PossessionLoadCwd<CR>"
				),
				dashboard.button(
					"l",
					"-> see latest sessions",
					":Telescope possession<CR>"
				),
				dashboard.button(
					"r",
					"-> search recent files",
					":Telescope oldfiles<CR>"
				),
				dashboard.button(
					"a",
					"-> search all files",
					":Telescope find_files<CR>"
				),
				dashboard.button(
					"f",
					"-> edit file tree",
					":lua require('oil').toggle_float()<CR>"
				),
				dashboard.button(
					"n",
					"-> write new file",
					":enew<CR>"
				),
				dashboard.button(
					"c",
					"-> neovim config",
					":cd ~/.dot/content/.config/nvim<CR>"
				),
				dashboard.button(
					"p",
					"-> run profiler",
					":StartupTime<CR>"
				),
				dashboard.button(
					"q",
					"-> quit",
					":qa<CR>"
				),
			}

			alpha.setup(dashboard.config)
			vim.api.nvim_create_augroup("vimrc_alpha", { clear = true })
			vim.api.nvim_create_autocmd({ "User" }, {
				group = "vimrc_alpha",
				pattern = "AlphaReady",
				callback = function()
					local header = nil
					if (
							vim.fn.executable("onefetch") == 1
							and vim.fn.system("git rev-parse --verify HEAD 2>/dev/null") ~= ""
						) then
						header = split(
							capture([[onefetch 2>/dev/null | sed -E 's/\x1B\[[0-9;]*[mK]//g']]),
							"\n"
						)
					else
						header = split(neovim_banner, "\n")
					end

					if next(header) ~= nil then
						local dash = require('alpha.themes.dashboard')
						local alpha = require('alpha')
						dash.section.header.val = header
						alpha.redraw()
					end
				end,
				once = true,
			})
		end
	}
}
