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
	{ 'stevearc/profile.nvim',
		config = function ()
			local should_profile = os.getenv("NVIM_PROFILE")
			if should_profile then
				require("profile").instrument_autocmds()
				if should_profile:lower():match("^start") then
					require("profile").start("*")
				else
					require("profile").instrument("*")
				end
			end

			local function toggle_profile()
				local prof = require("profile")
				if prof.is_recording() then
					prof.stop()
					vim.ui.input({ prompt = "Save profile to:", completion = "file", default = "profile.json" }, function(filename)
						if filename then
							prof.export(filename)
							vim.notify(string.format("Wrote %s", filename))
						end
					end)
				else
					prof.start("*")
				end
			end
			vim.keymap.set("", "<f1>", toggle_profile)
		end
	},
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
				snippet_engine = "luasnip"
			}
		end
	},

	-- LSP
	{ "folke/neodev.nvim",
		config = function ()
			require('neodev').setup { 
				library = {
					plugins = true,
				},
				lspconfig = false
			}
		end,
	},
	{ "rcarriga/nvim-notify",
		config = function ()
			vim.notify = require("notify")
		end
	},
	{ 'neovim/nvim-lspconfig',
		dependencies = {
			'williamboman/mason.nvim',
			'williamboman/mason-lspconfig.nvim',
			'j-hui/fidget.nvim',
		},
		config = config('lsp')
	},
	{ 'j-hui/fidget.nvim',
		config = function()
			require('fidget').setup {
				progress = {
					lsp = {
						progress_ringbuf_size = 1000
					}
				}
			}
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
	-- { 'jmbuhr/otter.nvim',
	-- 	dependencies = {
	-- 		'hrsh7th/nvim-cmp',
	-- 		'neovim/nvim-lspconfig',
	-- 		'nvim-treesitter/nvim-treesitter'
	-- 	},
	-- 	config = function ()
	-- 		require('otter').activate({ 'python', 'c', 'cpp' })
	-- 	end
	-- },
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
	{ 'L3MON4D3/LuaSnip',
		version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
		-- install jsregexp (optional!).
		build = "make install_jsregexp",
		config = config('luasnip')
	},

	-- Completion
	'hrsh7th/nvim-cmp',
	'hrsh7th/cmp-buffer',
	'hrsh7th/cmp-path',
	'hrsh7th/cmp-nvim-lsp',
	'saadparwaiz1/cmp_luasnip',
	'weilbith/nvim-code-action-menu',

	-- Syntax highlight
	'brgmnn/vim-opencl',
	'tikhomirov/vim-glsl',
	'timtro/glslView-nvim',
	'evanleck/vim-svelte',

	-- Filetype specific
	'timonv/vim-cargo',
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

	-- terminal
	{ 'numToStr/FTerm.nvim',
		config = function()
			require('FTerm').setup {
				border = 'single',
				dimensions = {
					height = 0.95,
					width = 0.5,
					x = 1.0,
					y = 0.5
				}
			}
		end
	},
	{ 'willothy/flatten.nvim',
		config = function()
			require('flatten').setup {}
		end,
		enabled = false
	},
	{
		'mikesmithgh/kitty-scrollback.nvim',
		enabled = true,
		lazy = true,
		cmd = { 'KittyScrollbackGenerateKittens', 'KittyScrollbackCheckHealth' },
		event = { 'User KittyScrollbackLaunch' },
		-- version = '*', -- latest stable version, may have breaking changes if major version changed
		-- version = '^2.0.0', -- pin major version, include fixes and features that do not have breaking changes
		config = function()
			require('kitty-scrollback').setup()
		end,
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
	{ 'davawen/neo-presence.lua', 
		build = "./build.sh",
		config = function ()
			require('neo-presence').setup {
				autostart = true
			}
		end
	},

	'sotte/presenting.vim',
}

local opts = {
	install = {
		missing = true,
		-- colorscheme = { "catppuccin" }
	},
	lockfile = vim.fn.stdpath("data") .. "/lazy-lock.json", -- lockfile generated after running update.
	dev = {
		path = "/mnt/Projects/Lua"
	}
}

require('lazy').setup(plugins, opts)
