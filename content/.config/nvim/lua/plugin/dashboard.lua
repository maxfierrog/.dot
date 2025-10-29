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

local function create_template_previewer(templates_dir)
	local previewers = require("telescope.previewers")
	local scan = require("plenary.scandir")

	return previewers.new_buffer_previewer({
		title = "Template Contents",
		define_preview = function(self, entry, status)
			local template_path = templates_dir .. "/" .. entry.value

			local items = scan.scan_dir(template_path, {
				hidden = false,
				depth = 1,
				add_dirs = true,
			})

			table.sort(items, function(a, b)
				local a_is_dir = vim.fn.isdirectory(a) == 1
				local b_is_dir = vim.fn.isdirectory(b) == 1
				if a_is_dir ~= b_is_dir then
					return a_is_dir
				end
				return a < b
			end)

			local lines = {}
			local mini_icons_ok, mini_icons = pcall(require, "mini.icons")

			for _, item in ipairs(items) do
				local name = vim.fn.fnamemodify(item, ":t")
				local is_dir = vim.fn.isdirectory(item) == 1
				local icon = ""

				if mini_icons_ok then
					if is_dir then
						icon = mini_icons.get("directory", name)
					else
						icon = mini_icons.get("file", name)
					end
				else
					icon = is_dir and "[d]" or "[f]"
				end

				table.insert(lines, icon .. " " .. name)
			end

			if #lines == 0 then
				lines = { "(empty template)" }
			end

			vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
		end,
	})
end

local function pick_template()
	local templates_dir = vim.fn.expand("$TEMPLATES")
	if templates_dir == "$TEMPLATES" or templates_dir == "" then
		vim.notify("$TEMPLATES environment variable not set", vim.log.levels.ERROR)
		return
	end

	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")

	local scan = require("plenary.scandir")
	local templates = scan.scan_dir(templates_dir, {
		only_dirs = true,
		depth = 1,
	})

	local template_names = {}
	for _, path in ipairs(templates) do
		table.insert(template_names, vim.fn.fnamemodify(path, ":t"))
	end

	pickers.new({}, {
		prompt_title = "Select Template",
		finder = finders.new_table({
			results = template_names,
		}),
		sorter = conf.generic_sorter({}),
		previewer = create_template_previewer(templates_dir),
		attach_mappings = function(prompt_bufnr, map)
			actions.select_default:replace(function()
				actions.close(prompt_bufnr)
				local selection = action_state.get_selected_entry()
				if selection then
					local template_name = selection[1]
					local source = templates_dir .. "/" .. template_name
					local dest = vim.fn.getcwd()

					local cmd = string.format("cp -r '%s'/* '%s'/", source, dest)
					local result = vim.fn.system(cmd)

					if vim.v.shell_error == 0 then
						vim.notify("Template '" .. template_name .. "' copied to current directory", vim.log.levels.INFO)
					else
						vim.notify("Error copying template: " .. result, vim.log.levels.ERROR)
					end
				end
			end)
			return true
		end,
	}):find()
end

return {
	{
		'goolord/alpha-nvim',

		lazy = false,

		dependencies = { 'echasnovski/mini.icons' },

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
					"t",
					"-> insert template",
					function() pick_template() end
				),
				dashboard.button(
					"f",
					"-> edit file tree",
					":lua require('oil').toggle_float()<CR>"
				),
				dashboard.button(
					"c",
					"-> neovim config",
					":cd ~/.dot/content/.config/nvim<CR>"
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
