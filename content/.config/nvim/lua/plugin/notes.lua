return {
	"obsidian-nvim/obsidian.nvim",
	version = "*",
	lazy = true,
	event = {
		"BufReadPre " .. vim.fn.expand "~" .. "/vaults/**/*.md",
		"BufNewFile " .. vim.fn.expand "~" .. "/vaults/**/*.md",
	},

	dependencies = {
		"nvim-lua/plenary.nvim",
	},

	opts = {
		workspaces = {
			{
				name = "notes",
				path = "~/vaults/notes",
				overrides = {
					templates = {
						folder = "templates",
					}
				}
			},
			{
				name = "todo",
				path = "~/vaults/todo",
				overrides = {
					templates = {
						folder = "templates",
					}
				}
			},
			{
				name = "creative",
				path = "~/vaults/creative",
				overrides = {
					templates = {
						folder = "templates",
					}
				}
			},
		},
		preferred_link_style = "markdown",
		wiki_link_func = "use_alias_only",
		new_notes_location = "current_dir",
		note_id_func = function(title)
			local suffix = ""
			if title ~= nil then
				suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
			end
			return tostring(os.time()) .. "-" .. suffix
		end,
	},

	templates = {
		date_format = "%Y-%m-%d",
		time_format = "%H:%M",
	},

	attachments = {
		img_folder = "assets/images/",
		img_name_func = function()
			return string.format("pasted-%s", os.date "%Y%m%d%H%M%S")
		end,

		img_text_func = function(client, path)
			path = client:vault_relative_path(path) or path
			return string.format("![%s](%s)", path.name, path)
		end,
	},

	statusline = {
		enabled = true,
		format = "{{properties}} properties, {{backlinks}} backlinks, {{words}} words",
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
	end,
}
