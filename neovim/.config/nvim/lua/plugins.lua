local ensure_packer = function()
	local fn = vim.fn
	local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
	if fn.empty(fn.glob(install_path)) > 0 then
		fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path })
		vim.cmd [[packadd packer.nvim]]
		return true
	end
	return false
end

local packer_bootstrap = ensure_packer()

return require 'packer'.startup(function(use)

--- Takes a module and packages it into a function to be called by packer
--- Use it like so:
--- ```lua
--- use { 'plugin',
---     config = config('path.module')
--- }
--- 
--- -- path/module.lua
--- -- ...
--- require('plugin').setup {
---     -- ...
--- }
--- ```
--- @param path string
--- @return string
local config = function(path)
	return string.format("require('%s')", path)
end

	use 'wbthomason/packer.nvim'

	-- Themes
	use 'shaunsingh/nord.nvim'
	use 'sainnhe/everforest'
	use 'habamax/vim-polar'
	use { 'catppuccin/nvim', as = 'catppuccin' }
	use 'AlexvZyl/nordic.nvim'
	use 'joshdick/onedark.vim'
	use 'rebelot/kanagawa.nvim'
	use { "bluz71/vim-nightfly-colors", as = "nightfly" }
	use 'ribru17/bamboo.nvim'
	use 'yorickpeterse/vim-paper'

	use 'ryanoasis/vim-devicons'
	use 'kyazdani42/nvim-web-devicons'

	use { 'nvim-lualine/lualine.nvim',
		config = config('setup.lualine')
	}

	-- Treesitter
	use { 'nvim-treesitter/nvim-treesitter',
		config = config('setup.treesitter')
	}
	use { 'nvim-treesitter/nvim-treesitter-context',
		requires = 'nvim-treesitter',
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
	}
	use 'nvim-treesitter/playground'
	use { 'danymat/neogen',
		config = function()
			require('neogen').setup {
				snippet_engine = "snippy"
			}
		end
	}

	-- LSP
	use { 'neovim/nvim-lspconfig',
		requires = {
			'williamboman/mason.nvim',
			'williamboman/mason-lspconfig.nvim',
			'j-hui/fidget.nvim'
		},
		config = config('setup.lsp')
	}
	use { 'j-hui/fidget.nvim',
		tag = 'legacy',
		config = function()
			require('fidget').setup {}
		end
	}
	use {
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
	}
	use 'onsails/lspkind-nvim'
	use 'ray-x/lsp_signature.nvim'
	use 'simrat39/rust-tools.nvim'
	use 'sigmasd/deno-nvim'
	use { 'mhartington/formatter.nvim',
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
	}
	use {'dgagn/diagflow.nvim',
		config = function ()
			require('diagflow').setup {
				padding_right = 1,
				update_event = { 'DiagnosticChanged', 'BufEnter', 'WinScrolled' }
			}
		end
	}

	-- Debugging
	use { 'mfussenegger/nvim-dap',
		config = config('setup.dap')
	}
	use { 'rcarriga/nvim-dap-ui',
		config = config('setup.dapui')
	}

	-- Snippets
	use { 'dcampos/nvim-snippy',
		config = config('setup.snippy')
	}
	use 'honza/vim-snippets'

	-- Completion
	use 'hrsh7th/nvim-cmp'
	use 'hrsh7th/cmp-buffer'
	use 'hrsh7th/cmp-path'
	use 'hrsh7th/cmp-nvim-lua'
	use 'hrsh7th/cmp-nvim-lsp'
	use 'dcampos/cmp-snippy'
	use 'weilbith/nvim-code-action-menu'

	-- Syntax highlight
	use 'brgmnn/vim-opencl'
	use 'tikhomirov/vim-glsl'
	use 'timtro/glslView-nvim'
	use 'evanleck/vim-svelte'

	-- Filetype specific
	use 'timonv/vim-cargo'
	use { 'iamcco/markdown-preview.nvim', run = 'cd app && yarn install' }
	use { 'shuntaka9576/preview-asciidoc.nvim', run = 'yarn install' }
	use 'godlygeek/tabular'
	use 'habamax/vim-godot'
	use { 'xuhdev/vim-latex-live-preview', opt = true }
	use 'pest-parser/pest.vim'

	-- Navigation
	use { 'nvim-telescope/telescope.nvim',
		config = function()
			require('telescope').setup {
				defaults = {
					file_ignore_patterns = { "build", "dist", "node_modules", "Cargo.lock" }
				}
			}
		end
	}
	use 'MunifTanjim/nui.nvim'
	use { 'nvim-neo-tree/neo-tree.nvim',
		-- Remove neo-tree legacy commands before plugin is loaded
		setup = function()
			vim.g.neo_tree_remove_legacy_commands = 1
		end,
		config = config('setup.neotree'),
		opt = false
	}
	use { 'romgrk/barbar.nvim',
		config = config('setup.barbar')
	}
	use { 'mg979/vim-visual-multi', branch = 'master' }
	use { 'stevearc/dressing.nvim',
		config = function()
			require('dressing').setup {
				input = {
					insert_only = false,
					start_in_insert = true,
				}
			}
		end
	}
	use 'unblevable/quick-scope'
	use { 'ggandor/leap.nvim',
		config = function()
			require('leap').setup {}

			vim.keymap.set("n", '<leader>s', '<Plug>(leap-forward-to)')
			vim.keymap.set("n", '<leader>S', '<Plug>(leap-backward-to)')
		end,
		requires = 'tpope/vim-repeat',
	}
	use { 'mizlan/iswap.nvim',
		config = function ()
			require('iswap').setup {
				keys = 'qwertyuiop'
			}
		end
	}

	-- Terminal
	use { 'voldikss/vim-floaterm',
		config = function()
			vim.g.floaterm_width = 0.5
			vim.g.floaterm_height = 0.99999999 -- avoid implicit conversion to int
			vim.g.floaterm_position = "right"
		end
	}
	use { 'willothy/flatten.nvim',
		config = function()
			require('flatten').setup {}
		end,
		disable = true
	}

	-- Git
	use {
		'lewis6991/gitsigns.nvim',
		config = function()
			require('gitsigns').setup()
		end
	}
	use { 'NeogitOrg/neogit', requires = 'nvim-lua/plenary.nvim',
		config = function ()
			require('neogit').setup {}
		end
	}
	use 'wintermute-cell/gitignore.nvim'

	-- Other
	use 'wakatime/vim-wakatime'
	use 'junegunn/vim-easy-align'
	use { 'numToStr/Comment.nvim',
		config = function()
			require('Comment').setup {}
		end
	}
	use 'mbbill/undotree'

	use { 'windwp/nvim-autopairs',
		config = config('setup.autopairs')
	}
	use 'tpope/vim-surround'
	-- use 'kkharji/sqlite.lua'
	use { 'AckslD/nvim-neoclip.lua',
		requires = 'telescope.nvim',
		config = function()
			require('neoclip').setup {}
			vim.keymap.set('n', '<leader>fp', require('telescope').extensions.neoclip.default)
		end
	}
	use 'fidian/hexmode'
	-- use { 'michaelb/sniprun', run = 'bash install.sh' }

	use 'nvim-lua/plenary.nvim'
	use { 'folke/todo-comments.nvim',
		config = function()
			require('todo-comments').setup {
				keywords = {
					DONE = { icon = " ", color = "hint", alt = { "FINISHED", "IMPL", "IMPLEMENTED" }  }
				},
				merge_keywords = true,
			}
		end
	}
	-- -- use { 'davawen/neo-presence', run = { "cmake -B build .", "make -C build" }, disable = true }

	use 'sotte/presenting.vim'

	if packer_bootstrap then
		require('packer').sync()
	end
end)
