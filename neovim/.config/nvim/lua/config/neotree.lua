vim.cmd([[
		highlight link NeoTreeDirectoryName Directory
		highlight link NeoTreeDirectoryIcon NeoTreeDirectoryName
	]])

require('neo-tree').setup {
	enable_normal_mode_for_inputs = true,
	default_component_configs = {
		indent = {
			indent_size = 2,
			padding = 1, -- extra padding on left hand side
			-- indent guides
			with_markers = true,
			indent_marker = "│",
			last_indent_marker = "└",
			highlight = "NeoTreeIndentMarker",
			-- expander config, needed for nesting files
			with_expanders = nil, -- if nil and file nesting is enabled, will enable expanders
			expander_collapsed = "",
			expander_expanded = "",
			expander_highlight = "NeoTreeExpander",
		},
		icon = {
			folder_closed = "",
			folder_open = "",
			folder_empty = "ﰊ",
			-- The next two settings are only a fallback, if you use nvim-web-devicons and configure default icons there
			-- then these will never be used.
			default = "*",
			highlight = "NeoTreeFileIcon"
		},
		modified = {
			symbol = "[+]",
			highlight = "NeoTreeModified",
		},
	},
	filesystem = {
		filtered_items = {
			visible = true,
			hide_dotfiles = false
		}
	},
	window = {
		popup = {
			position = { col = "100%", row = "2" },
			size = function(state)
				local root_name = vim.fn.fnamemodify(state.path, ":~")
				local root_len = string.len(root_name) + 4
				return {
					width = math.max(root_len, 70),
					height = vim.o.lines - 6
				}
			end
		},
	},
	sources = {
		"filesystem",
		"git_status",
		"buffers",
		"document_symbols"
	},
	source_selector = {
		winbar = false,
		statusline = true,
		sources = {
			{ source = "filesystem", display_name = " 󰉓 Files " },
			{ source = "git_status", display_name = " 󰊢 Git " },
		}
	}
}
