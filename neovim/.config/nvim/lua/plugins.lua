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

			function ToggleProfile()
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
			vim.keymap.set("", "<f1>", ToggleProfile)
		end
	},
	"nvim-neotest/nvim-nio",

	-- Themes
	{ 'catppuccin/nvim', name ='catppuccin',
		config = function ()
			require('catppuccin').setup {
				show_end_of_buffer = true,
			}
			vim.cmd.colorscheme("catppuccin-macchiato")
		end,
		priority = 1000
	},
	'joshdick/onedark.vim',
	'sainnhe/everforest',
	'rebelot/kanagawa.nvim',
	'yorickpeterse/vim-paper',

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
		build = ":TSUpdate", -- update parsers on update
		config = config('treesitter')
	},

	-- LSP
	{ "folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				-- Library items can be absolute paths
				-- "~/projects/my-awesome-lib",
				-- Or relative, which means they will be resolved as a plugin
				-- "LazyVim",
				-- When relative, you can also provide a path to the library in the plugin dir
			}
		}
	},
	{ "Ajnasz/notify-send.nvim",
		config = function ()
			-- local notify = require('notify-send')
			-- notify.setup {
			-- 	override_vim_notify = false
			-- }
			--
			-- local notifications = {}
			-- vim.notify = function (msg, level, opts)
			-- 	notify.send(msg, level, opts)
			--
			-- 	table.insert(notifications, msg)
			-- end
			--
			-- function ShowNotifications()
			-- 	for index, value in ipairs(notifications) do
			-- 		print(index)
			-- 		print(value)
			-- 	end
			-- end
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
	{
		'mrcjkb/rustaceanvim',
		version = '^4', -- Recommended
		ft = { 'rust' },
	},
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
	-- 'ray-x/lsp_signature.nvim',

	-- Debugging
	{ 'mfussenegger/nvim-dap',
		config = config('dap')
	},
	{ 'rcarriga/nvim-dap-ui',
		config = config('dapui')
	},

	-- Snippets

	-- Completion
	{
		'saghen/blink.cmp',
		lazy = false,
		-- version = 'v0.*',
		-- commit = "8b553f6",
		build = "cargo build --release",
		opts = {
			keymap = {
				["<C-space>"] = { "show", "hide" },
				["<CR>"] = { "accept", "fallback" },
				["<Up>"] = { "select_prev", "fallback" },
				["<C-k>"] = { "select_prev", "fallback" },
				["<Down>"] = { "select_next", "fallback" },
				["<C-j>"] = { "select_next", "fallback" },

				['<C-y>'] = { 'scroll_documentation_up', 'fallback' },
				['<C-e>'] = { 'scroll_documentation_down', 'fallback' },

				['<Tab>'] = { 'snippet_forward', 'fallback' },
				['<S-Tab>'] = { 'snippet_backward', 'fallback' },
			},
			appearance = {
				use_nvim_cmp_as_default = true
			},
			signature = {
				enabled = true
			},
			completion = {
				trigger = {
					show_on_keyword = false,
					show_on_trigger_character = false,
				},
				menu = {
					min_width = 25,
					max_height = 20
				},
				documentation = {
					auto_show = true
				},
				ghost_text = {
					enabled = true
				}
			},
			fuzzy = {
				prebuilt_binaries = {
					download = false
				}
			},
			sources = {
				default = {
					"lsp", "path", "snippets"
				},
				providers = {
					lsp = { module = 'blink.cmp.sources.lsp', name = "LSP" },
					path = { module = 'blink.cmp.sources.path', name = "Path" },
					snippets = { module = 'blink.cmp.sources.snippets', name = "Snippets", score_offset = -3 },
				}
			},
		},
	},
	-- 'hrsh7th/nvim-cmp',
	-- 'hrsh7th/cmp-nvim-lsp',
	--    'hrsh7th/cmp-buffer',
	--    'hrsh7th/cmp-path',
	{ "aznhe21/actions-preview.nvim",
		config = function()
			require("actions-preview").setup {
				-- priority list of preferred backend
				backend = { "telescope", "nui" },
			}
		end,
	},

	-- Syntax highlight
	'timtro/glslView-nvim',

	-- Filetype specific
	'pest-parser/pest.vim',
	{ 'RaafatTurki/hex.nvim' },
	-- { 'kaarmu/typst.vim', ft = "typst" },
	{ 'chomosuke/typst-preview.nvim',
		ft = "typst",
		config = function ()
			require("typst-preview").setup {
				open_cmd = "firefox --new-window %s --class typst-preview",
				dependencies_bin = {
					["typst-preview"] = vim.fn.expand("$CARGO_HOME/bin/tinymist")
				}
			}
		end
	},
	{ 'MeanderingProgrammer/markdown.nvim',
		ft = 'markdown',
		main = "render-markdown",
		opts = {},
		name = "render-markdown"
	},

	-- Navigation
	{ 'nvim-telescope/telescope.nvim',
		config = function()
			require('telescope').setup {
				defaults = {
					file_ignore_patterns = { "node_modules", "Cargo.lock" }
				}
			}
		end
	},
	{ 'stevearc/oil.nvim',
		-- Optional dependencies
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function ()
			require("oil").setup {
				lsp_file_methods = {
					timeout_ms = 50
				}
			}

			function ProfileOil()
				local oil = require("oil")

				ToggleProfile()

				oil.open()
			end

			vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
			vim.keymap.set("n", "_", "<CMD>Oil .<CR>", { desc = "Open currend working directory" })
		end
	},
	"mg979/vim-visual-multi",
	'unblevable/quick-scope',

	-- UI
	'MunifTanjim/nui.nvim',
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

	-- terminal
	{ 'willothy/flatten.nvim',
		config = function()
			require('flatten').setup {}
		end,
		event = "VeryLazy"
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
		'isakbm/gitgraph.nvim',
		opts = {
			symbols = {
				merge_commit = 'M',
				commit = '*',
			},
			format = {
				timestamp = '%H:%M:%S %d-%m-%Y',
				fields = { 'hash', 'timestamp', 'author', 'branch_name', 'tag' },
			},
			hooks = {
				on_select_commit = function(commit)
					print('selected commit:', commit.hash)
				end,
				on_select_range_commit = function(from, to)
					print('selected range:', from.hash, to.hash)
				end,
			},
		},
		keys = {
			{
				"<leader>gl",
				function()
					require('gitgraph').draw({}, { all = true, max_count = 5000 })
				end,
				desc = "GitGraph - Draw",
			},
		},
	},


	-- Other
	'wakatime/vim-wakatime',
	'junegunn/vim-easy-align',
	{ 'numToStr/Comment.nvim',
		config = function()
			require('Comment').setup()
		end
	},
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
		-- enabled = false,
		build = "./build.sh",
		config = function ()
			require('neo-presence').setup {
				autostart = true
			}
		end,
		event = "VeryLazy"
	},
	"vim-utils/vim-man"
}

local opts = {
	install = {
		missing = true,
		colorscheme = { "catppuccin" }
	},
	lockfile = vim.fn.stdpath("data") .. "/lazy-lock.json", -- lockfile generated after running update.
	dev = {
		path = "/mnt/Projects/Lua"
	}
}

require('lazy').setup(plugins, opts)
