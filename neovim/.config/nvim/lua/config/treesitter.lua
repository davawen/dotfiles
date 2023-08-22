-- local parser_config = require('nvim-treesitter.parsers').get_parser_configs()
-- parser_config.opencl = {
-- 	install_info = {
-- 		url = "https://github.com/lefp/tree-sitter-opencl",
-- 		files = { "src/parser.c" }
-- 	}
-- }

require('nvim-treesitter.configs').setup {
	ensure_installed = { "c", "cpp", "rust", "lua", "vim", "python" },
	ignore_install = { "comment" },
	disable = { "comment", "gdscript" },
	auto_install = true,
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = false,
	},
	incremental_selection = {
		enable = true,
		keymaps = {
			init_selection = "<CR>",
			node_incremental = "<CR>",
			scope_incremental = "<S-CR>",
			node_decremental = "<BS>",
		}
	},
	indent = {
		enable = true,
		disable = { "python" }
	},
	playground = {
		enable = true,
		disable = {},
		updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
		persist_queries = false, -- Whether the query persists across vim sessions
		keybindings = {
			toggle_query_editor = 'o',
			toggle_hl_groups = 'i',
			toggle_injected_languages = 't',
			toggle_anonymous_nodes = 'a',
			toggle_language_display = 'I',
			focus_language = 'f',
			unfocus_language = 'F',
			update = 'R',
			goto_node = '<cr>',
			show_help = '?',
		},
	}
}

vim.o.foldmethod = "expr"
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.o.foldlevelstart = 4
