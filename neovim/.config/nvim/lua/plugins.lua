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
	{ "rcarriga/nvim-notify",
		config = function ()
			vim.notify = require("notify")
			-- @allow missing_fields
			vim.notify.setup {
				timeout = 2500,
				render = "compact",
			}
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
	'ray-x/lsp_signature.nvim',

	-- Debugging
	{ 'mfussenegger/nvim-dap',
		config = config('dap')
	},
	{ 'rcarriga/nvim-dap-ui',
		config = config('dapui')
	},

	-- Snippets

	-- Completion
	'hrsh7th/nvim-cmp',
    'hrsh7th/cmp-nvim-lsp',
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
	{ 'kaarmu/typst.vim', ft = "typst" },
	{
		'chomosuke/typst-preview.nvim',
		ft = 'typst',
		version = '0.3.*',
		build = function() require('typst-preview').update() end,
		config = function ()
			require('typst-preview').setup {
				follow_cursor = false
			}
		end
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
	{ 'NeogitOrg/neogit',
		dependencies = {
			'nvim-lua/plenary.nvim',
			'sindrets/diffview.nvim'
		},
		config = function ()
			require('neogit').setup {}
		end,
		lazy = true,
		cmd = { "Neogit", "NeogitMessages", "NeogitResetState" }
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

	{
		"nomnivore/ollama.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},

		-- All the user commands added by the plugin
		cmd = { "Ollama", "OllamaModel", "OllamaServe", "OllamaServeStop" },

		keys = {
			-- Sample keybind for prompt menu. Note that the <c-u> is important for selections to work properly.
			{
				"<leader>oo",
				":<c-u>lua require('ollama').prompt()<cr>",
				desc = "ollama prompt",
				mode = { "n", "v" },
			},

			-- Sample keybind for direct prompting. Note that the <c-u> is important for selections to work properly.
			{
				"<leader>oG",
				":<c-u>lua require('ollama').prompt('Generate_Code')<cr>",
				desc = "ollama Generate Code",
				mode = { "n", "v" },
			},
		},

		opts = {
			model = "dolphin-mistral"
			-- your configuration overrides
		},
		event = "VeryLazy"
	},
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
