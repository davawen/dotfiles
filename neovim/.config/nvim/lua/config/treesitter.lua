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
	}
}

vim.o.foldmethod = "expr"
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.o.foldlevelstart = 4
