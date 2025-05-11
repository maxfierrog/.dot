-- DEFINITIONS

local image_name = function()
	return string.format("%s", os.date "%Y%m%d%H%M%S")
end

local image_text = function(client, path)
	path = client:vault_relative_path(path) or path
	return string.format("![%s](images/%s)", path.name, path.name)
end

local note_id_function = function(title)
	local suffix = ""
	if title ~= nil then
		suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
	end
	return tostring(os.time()) .. "-" .. suffix
end


-- HELPERS

local vaults = {
	"creative",
	"notes",
	"todo",
}

local vaults_directory = vim.fn.expand "~" .. "/vaults"
local shared_overrides = {
	templates = {
		folder = "templates",
	},
	attachments = {
		img_folder = "images/",
		img_name_func = image_name,
		img_text_func = image_text,
	},
}

local workspaces = function()
	local ws = {}
	for _, name in ipairs(vaults) do
		table.insert(ws, {
			name = name,
			path = vaults_directory .. "/" .. name,
			overrides = shared_overrides,
		})
	end
	return ws
end


-- PLUGIN

return {
	"obsidian-nvim/obsidian.nvim",
	version = "*",
	lazy = true,
	event = {
		"BufReadPre " .. vaults_directory .. "/**/*.md",
		"BufNewFile " .. vaults_directory .. "/**/*.md",
	},

	dependencies = {
		"nvim-lua/plenary.nvim",
	},

	opts = {
		workspaces = workspaces(),
		preferred_link_style = "markdown",
		wiki_link_func = "use_alias_only",
		new_notes_location = "current_dir",
		note_id_func = note_id_function,
		should_confirm = false,
		statusline = {
			enabled = true,
			format = "{{properties}} properties, {{backlinks}} backlinks, {{words}} words",
		},
	},

	config = function(plugin, opts)
		require("obsidian").setup(opts)

		-- Create a new note; see opts.new_notes_location
		vim.keymap.set("n", "<leader>nn", ":ObsidianNew<CR>")

		-- Pops up a picker of references in the current buffer
		vim.keymap.set("n", "<leader>no", ":ObsidianLinks<CR>")

		-- Pops up a picker of references to the current buffer
		vim.keymap.set("n", "<leader>ni", ":ObsidianBacklinks<CR>")

		-- Pops up a picker of templates, choosing one makes new note
		vim.keymap.set("n", "<leader>nt", ":ObsidianNewFromTemplate<CR>")

		-- Pops up a picker of templates, choosing one inserts to current note
		vim.keymap.set("n", "<leader>nh", ":ObsidianTemplate<CR>")

		-- Pops up a picker of templates, choosing one inserts to current note
		vim.keymap.set("n", "<leader>nh", ":ObsidianTemplate<CR>")

		-- Opens excalidraw desktop for quick sketches
		vim.keymap.set("n", "<leader>nd", function()
			vim.fn.jobstart(
				{ "open", "https://excalidraw.com" },
				{ detach = true }
			)
		end)

		-- Paste an image from the clipboard
		vim.keymap.set("n", "<leader>np", function()
			local buffer_dir = vim.fn.fnamemodify(
				vim.api.nvim_buf_get_name(0),
				":p:h"
			)

			local name = image_name()
			local full_path = string.format(
				"%s/images/%s",
				buffer_dir,
				name
			)

			vim.cmd(":ObsidianPasteImg " .. full_path)
			if vim.fn.executable("magick") ~= 1 then
				vim.notify(
					"'magick' not found — image will not be flattened.",
					vim.log.levels.WARN
				)
				return
			end

			full_path = full_path .. ".png"
			if vim.fn.filereadable(full_path) == 0 then
				vim.notify(
					"Image not found after paste: " .. full_path,
					vim.log.levels.ERROR
				)
				return
			end

			vim.fn.jobstart({
				"magick",
				full_path,
				"-background", "white",
				"-alpha", "remove",
				"-alpha", "off",
				full_path,
			}, {
				detach = true,
				on_exit = function(_, code)
					if code == 0 then
						vim.notify(
							"Image pasted and alpha-flattened: " .. name,
							vim.log.levels.INFO
						)
					else
						vim.notify(
							"`magick` could not flatten pasted image: " .. name,
							vim.log.levels.WARN
						)
					end
				end,
			})
		end)

		-- Render the current markdown file with pandoc and mathjax
		vim.keymap.set("n", "<leader>nr", function()
			local filename = vim.fn.expand("%:p")
			local filedir = vim.fn.fnamemodify(filename, ":p:h")
			local base = vim.fn.fnamemodify(filename, ":t:r")
			local output = filedir .. "/" .. base .. ".html"

			local cmd = {
				"pandoc",
				filename,
				"-s",
				"--katex",
				"--standalone",
				"-c", vim.fn.expand "~" .. "/vaults/custom.css",
				"-o", output,
			}

			vim.notify(
				"Rendering with Pandoc into " .. output,
				vim.log.levels.INFO
			)

			vim.fn.jobstart(cmd, {
				cwd = filedir,
				on_exit = function(_, code)
					if code == 0 then
						vim.fn.jobstart(
							{ "open", output },
							{ detach = true }
						)
					else
						vim.notify(
							"Pandoc failed with exit code: " .. code,
							vim.log.levels.ERROR
						)
					end
				end,
			})
		end)
	end,
}
