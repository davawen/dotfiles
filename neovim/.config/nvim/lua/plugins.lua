--- Takes a module and packages it into a function to be called by lazy
--- Use it like so:
--- ```lua
--- use { 'plugin',
---     config = config('module')
--- }
--- 
--- -- config/module.lua
--- -- ...
--- require('plugin').setup {
---     -- ...
--- }
--- ```
--- @param path string
--- @return function
local config = function(path)
	return function()
		require('config.' .. path)
	end
end


local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

local plugins = {
	'shaunsingh/nord.nvim',

	-- Themes
	'shaunsingh/nord.nvim',
	'sainnhe/everforest',
	'habamax/vim-polar',
	{ 'catppuccin/nvim', name ='catppuccin',
		config = function ()
			require('catppuccin').setup {
				show_end_of_buffer = true,
			}
			vim.cmd.colorscheme("catppuccin-macchiato")
		end,
		priority = 1000
	},
	'AlexvZyl/nordic.nvim',
	'joshdick/onedark.vim',
	'rebelot/kanagawa.nvim',
	{ "bluz71/vim-nightfly-colors", name ="nightfly" },
	'ribru17/bamboo.nvim',
	'yorickpeterse/vim-paper',

	'ryanoasis/vim-devicons',
	'kyazdani42/nvim-web-devicons',

	-- Status info
	{ 'rebelot/heirline.nvim',
		config = config('heirline'),
	},
	{ 'b0o/incline.nvim',
		config = true
	},

	-- Treesitter
	{ 'nvim-treesitter/nvim-treesitter',
		config = config('treesitter')
	},
	{ 'nvim-treesitter/nvim-treesitter-context',
		dependencies = 'nvim-treesitter',
		config = function()
			require('treesitter-context').setup {
				enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
				throttle = true, -- Throttles plugin updates (may improve performance)
				max_lines = 7, -- How many lines the window should span. Values <= 0 mean no limit.
				patterns = { -- Match patterns for TS nodes. These get wrapped to match at word boundaries.
					-- For all filetypes
					-- Note that setting an entry here replaces all other patterns for this entry.
					-- By setting the 'default' entry below, you can control which nodes you want to
					-- appear in the context window.
					default = {
						'class',
						'function',
						'method',
						'for', -- These won't appear in the context
						'while',
						-- 'if',
						'switch',
						'case',
					},
					-- Example for a specific filetype.
					-- If a pattern is missing, *open a PR* so everyone can benefit.
					--   rust = {
					--       'impl_item',
					--   },
				},
			}
		end
	},
	{ 'danymat/neogen',
		config = function()
			require('neogen').setup {
				snippet_engine = "snippy"
			}
		end
	},

	-- LSP
	{ 'neovim/nvim-lspconfig',
		dependencies = {
			'williamboman/mason.nvim',
			'williamboman/mason-lspconfig.nvim',
			'j-hui/fidget.nvim'
		},
		config = config('lsp')
	},
	{ 'j-hui/fidget.nvim',
		tag = 'legacy',
		config = function()
			require('fidget').setup {}
		end
	},
	{
		"lewis6991/hover.nvim",
		config = function()
			require("hover").setup {
				init = function()
					-- Require providers
					require("hover.providers.lsp")
					-- require('hover.providers.gh') -- require('hover.providers.gh_user') -- require('hover.providers.jira') -- require('hover.providers.man') -- require('hover.providers.dictionary')
				end,
				preview_opts = {
					border = nil
				},
				-- Whether the contents of a currently open hover window should be moved
				-- to a :h preview-window when pressing the hover keymap.
				preview_window = false,
				title = true
			}

			-- Setup keymaps
			vim.keymap.set("n", "K", require("hover").hover, {desc = "hover.nvim"})
			vim.keymap.set("n", "gK", require("hover").hover_select, {desc = "hover.nvim (select)"})
		end
	},
	'SmiteshP/nvim-navic',
	'onsails/lspkind-nvim',
	'ray-x/lsp_signature.nvim',
	'simrat39/rust-tools.nvim',
	'sigmasd/deno-nvim',
	{ 'mhartington/formatter.nvim',
		config = function()
			require("formatter").setup {
			  -- Enable or disable logging
			  logging = true,
			  -- Set the log level
			  log_level = vim.log.levels.WARN,
			  -- All formatter configurations are opt-in
			  filetype = {
				-- Formatter configurations for filetype "lua" go here
				-- and will be executed in order
				cpp = require("formatter.filetypes.cpp").clangformat,
				c = require("formatter.filetypes.c").clangformat,
				typescript = require("formatter.filetypes.javascript").prettier,

				-- Use the special "*" filetype for defining formatter configurations on
				-- any filetype
				["*"] = {
				  -- "formatter.filetypes.any" defines default configurations for any
				  -- filetype
				  require("formatter.filetypes.any").remove_trailing_whitespace
				}
			  }
			}
		end
	},
	{ 'jmbuhr/otter.nvim',
		dependencies = {
			'hrsh7th/nvim-cmp',
			'neovim/nvim-lspconfig',
			'nvim-treesitter/nvim-treesitter'
		},
		config = function ()
			require('otter').activate({ 'python', 'c', 'cpp' })
		end
	},
	{'dgagn/diagflow.nvim',
		config = function ()
			require('diagflow').setup {
				padding_right = 1,
				update_event = { 'DiagnosticChanged', 'BufEnter', 'WinScrolled' }
			}
		end
	},

	-- Debugging
	{ 'mfussenegger/nvim-dap',
		config = config('dap')
	},
	{ 'rcarriga/nvim-dap-ui',
		config = config('dapui')
	},

	-- Snippets
	{ 'dcampos/nvim-snippy',
		config = config('snippy')
	},
	'honza/vim-snippets',

	-- Completion
	'hrsh7th/nvim-cmp',
	'hrsh7th/cmp-buffer',
	'hrsh7th/cmp-path',
	'hrsh7th/cmp-nvim-lua',
	'hrsh7th/cmp-nvim-lsp',
	'dcampos/cmp-snippy',
	'weilbith/nvim-code-action-menu',

	-- Syntax highlight
	'brgmnn/vim-opencl',
	'tikhomirov/vim-glsl',
	'timtro/glslView-nvim',
	'evanleck/vim-svelte',

	-- Filetype specific
	'timonv/vim-cargo',
	{ 'iamcco/markdown-preview.nvim', run = 'cd app && yarn install' },
	{ 'shuntaka9576/preview-asciidoc.nvim', run = 'yarn install' },
	'godlygeek/tabular',
	'habamax/vim-godot',
	{ 'xuhdev/vim-latex-live-preview', lazy = true },
	'pest-parser/pest.vim',

	-- Navigation
	{ 'nvim-telescope/telescope.nvim',
		config = function()
			require('telescope').setup {
				defaults = {
					file_ignore_patterns = { "build", "dist", "node_modules", "Cargo.lock" }
				}
			}
		end
	},
	'MunifTanjim/nui.nvim',
	{ 'nvim-neo-tree/neo-tree.nvim',
		-- Remove neo-tree legacy commands before plugin is loaded
		init = function()
			vim.g.neo_tree_remove_legacy_commands = 1
		end,
		config = config('neotree'),
		branch = "v3.x"
		-- lazy = true
	},
	-- { 'romgrk/barbar.nvim',
	-- 	config = config('barbar'),
	-- 	cond = false
	-- },
	{ 'mg979/vim-visual-multi', branch = 'master' },
	{ 'stevearc/dressing.nvim',
		config = function()
			require('dressing').setup {
				input = {
					insert_only = false,
					start_in_insert = true,
				}
			}
		end
	},
	'unblevable/quick-scope',
	{ 'ggandor/leap.nvim',
		config = function()
			require('leap').setup {}

			vim.keymap.set("n", '<leader>s', '<Plug>(leap-forward-to)')
			vim.keymap.set("n", '<leader>S', '<Plug>(leap-backward-to)')
		end,
		dependencies = 'tpope/vim-repeat',
	},
	{ 'mizlan/iswap.nvim',
		config = function ()
			require('iswap').setup {
				keys = 'qwertyuiop'
			}
		end
	},

	-- Terminal
	{ 'voldikss/vim-floaterm',
		config = function()
			vim.g.floaterm_width = 0.5
			vim.g.floaterm_height = 0.99999999 -- avoid implicit conversion to int
			vim.g.floaterm_position = "right"
		end
	},
	{ 'willothy/flatten.nvim',
		config = function()
			require('flatten').setup {}
		end,
		enabled = false
	},

	-- Git
	{
		'lewis6991/gitsigns.nvim',
		config = function()
			require('gitsigns').setup()
		end
	},
	{ 'NeogitOrg/neogit', dependencies = 'nvim-lua/plenary.nvim',
		config = function ()
			require('neogit').setup {}
		end,
		lazy = true,
		cmd = { "Neogit", "NeogitMessages", "NeogitResetState" }
	},
	'wintermute-cell/gitignore.nvim',

	-- Other
	'wakatime/vim-wakatime',
	'junegunn/vim-easy-align',
	{ 'numToStr/Comment.nvim',
		config = function()
			require('Comment').setup {}
		end
	},
	'mbbill/undotree',

	{ 'windwp/nvim-autopairs',
		config = config('autopairs')
	},
	{ 'kylechui/nvim-surround',
		config = config('surround'),
		lazy = true,
		event = "VeryLazy"
	},
	-- 'kkharji/sqlite.lua'
	{ 'AckslD/nvim-neoclip.lua',
		dependencies = 'nvim-telescope/telescope.nvim',
		config = function()
			require('neoclip').setup {}
			vim.keymap.set('n', '<leader>fc', function () -- sometimes, neoclip isn't loaded in telescope at this moment, so we only call it when the keymap's called
				require('telescope').extensions.neoclip.default()
			end)
		end,
		event = "VeryLazy"
	},
	'fidian/hexmode',
	-- { 'michaelb/sniprun', run = 'bash install.sh' }

	'nvim-lua/plenary.nvim',
	{ 'folke/todo-comments.nvim',
		config = function()
			require('todo-comments').setup {
				keywords = {
					DONE = { icon = " ", color = "hint", alt = { "FINISHED", "IMPL", "IMPLEMENTED" }  }
				},
				merge_keywords = true,
			}
		end,
		lazy = true,
		event = "VeryLazy"
	},
	-- -- { 'davawen/neo-presence', run = { "cmake -B build .", "make -C build" }, enabled = true }

	'sotte/presenting.vim',
}

local opts = {
	install = {
		missing = true,
		-- colorscheme = { "catppuccin" }
	},
	lockfile = vim.fn.stdpath("data") .. "/lazy-lock.json", -- lockfile generated after running update.
}

require('lazy').setup(plugins, opts)
