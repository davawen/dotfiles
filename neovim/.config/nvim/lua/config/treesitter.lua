local parser_config = require('nvim-treesitter.parsers').get_parser_configs()
parser_config.hare_custom = {
	install_info = {
		url = "/home/davawen/.build/tree-sitter-hare",
		files = { "src/parser.c" }
	},
	filetype = "hare"
}

vim.treesitter.language.add("hare", { path = "/home/davawen/.local/share/nvim/lazy/nvim-treesitter/parser/hare_custom.so" })

require('nvim-treesitter.configs').setup {
	ensure_installed = { "c", "cpp", "rust", "lua", "vim", "python", "query" },
	ignore_install = { "comment", "text", "hare" },
	disable = { "comment", "text" },
	auto_install = true,
	sync_install = false,
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = false,
		disable = function (lang, bufnr) -- disable on big files
			local fsize = vim.fn.getfsize(vim.api.nvim_buf_get_name(bufnr))
			return fsize > 500000
		end
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
		enable = true
	}
}

vim.o.foldmethod = "expr"
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.o.foldlevelstart = 4
