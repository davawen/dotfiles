local map, remap = unpack(require("utils.map"))

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
	use { 'ribru17/bamboo.nvim',
		config = function()
			-- require('bamboo').load()
		end
	}
	use 'yorickpeterse/vim-paper'

	use 'ryanoasis/vim-devicons'
	use 'kyazdani42/nvim-web-devicons'

	use { 'nvim-lualine/lualine.nvim',
		config = function ()
			local function signature_help()
				local sig = require("lsp_signature").status_line(100)
				return sig.label
			end

			-- lualine
			require('lualine').setup({
				options = {
					theme = 'everforest',
					globalstatus = true
				},
				sections = {
					lualine_a = { 'mode'},
					lualine_b = { 'branch', 'diagnostics', 'diff'},
					lualine_c = { "filename", signature_help },
					lualine_x = { 'location', 'filetype'},
					lualine_y = { 'os.date("%I:%M:%S", os.time())'},
					lualine_z = { }
				}
			})


			-- Trigger rerender of status line every second for clock
			if _G.Statusline_timer == nil then
				_G.Statusline_timer = vim.loop.new_timer()
			else
				_G.Statusline_timer:stop()
			end
			_G.Statusline_timer:start(0, 1000, vim.schedule_wrap(
				function() vim.api.nvim_command('redrawstatus') end))

		end
	}
	use { 'willothy/veil.nvim',
		config = function()
			local builtin = require("veil.builtin")

			require('veil').setup {
				sections = {
					builtin.sections.animated(builtin.headers.frames_nvim, {
						hl = { fg = "#5de4c7" },
					}),
					builtin.sections.buttons({
						{
							icon = "",
							text = "File Tree",
							shortcut = "n",
							callback = function ()
								vim.cmd [[ Neotree source=filesystem reveal position=float focus ]]
							end
						},
						{
							icon = "",
							text = "Find Files",
							shortcut = "f",
							callback = function()
								require("telescope.builtin").find_files()
							end,
						},
						{
							icon = "",
							text = "Find Word",
							shortcut = "w",
							callback = function()
								require("telescope.builtin").live_grep()
							end,
						},
						{
							icon = "",
							text = "Buffers",
							shortcut = "b",
							callback = function()
								require("telescope.builtin").buffers()
							end,
						},
						{
							icon = "",
							text = "Config",
							shortcut = "c",
							callback = function()
								require("telescope").extensions.file_browser.file_browser({
									path = vim.fn.stdpath("config"),
								})
							end,
						},
					}),
					builtin.sections.oldfiles(),
				},
				mappings = {},
				startup = true,
				listed = false
			}
		end,
		disable = true
	}

	-- Treesitter
	use { 'nvim-treesitter/nvim-treesitter',
		run = ":TSUpdate",
		config = function()
			local parser_config = require('nvim-treesitter.parsers').get_parser_configs()
			parser_config.opencl = {
				install_info = {
					url = "https://github.com/lefp/tree-sitter-opencl",
					files = { "src/parser.c" }
				}
			}

			require('nvim-treesitter.configs').setup {
				ensure_installed = "all",
				disable = { "gdscript" },
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
					disable = { "c", "python", "cpp" }
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

			vim.o.foldlevelstart = 4
		end
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
		}
	}
	use { 'j-hui/fidget.nvim',
		config = function()
			require('fidget').setup {}
		end
	}
	use { 'lvimuser/lsp-inlayhints.nvim',
		disable = true,
		config = function()
			require("lsp-inlayhints").setup()


			vim.api.nvim_create_augroup("LspAttach_inlayhints", {})
			vim.api.nvim_create_autocmd("LspAttach", {
				group = "LspAttach_inlayhints",
				callback = function(args)
					if not (args.data and args.data.client_id) then
						return
					end

					local bufnr = args.buf
					local client = vim.lsp.get_client_by_id(args.data.client_id)
					require("lsp-inlayhints").on_attach(client, bufnr)
				end,
			})
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
	use 'mhartington/formatter.nvim'
	use {'dgagn/diagflow.nvim',
		config = function ()
			require('diagflow').setup {
				padding_right = 1,
				update_event = { 'DiagnosticChanged', 'BufEnter' }
			}
		end
	}

	-- Debugging
	use 'mfussenegger/nvim-dap'
	use 'rcarriga/nvim-dap-ui'

	-- Snippets
	use 'dcampos/nvim-snippy'
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
	use 'nvim-telescope/telescope.nvim'
	use 'MunifTanjim/nui.nvim'
	use { 'nvim-neo-tree/neo-tree.nvim',
		-- Remove neo-tree legacy commands before plugin is loaded
		setup = function()
			vim.g.neo_tree_remove_legacy_commands = 1
		end,
		config = function()
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
		end
	}
	use 'romgrk/barbar.nvim'
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

	-- Notes
	use {
		'lervag/wiki.vim',
		config = function()
			vim.g.wiki_root = '~/wiki'
			vim.cmd [[
				augroup WikiGroup
					autocmd!
					autocmd User WikiBufferInitialized nnoremap gf <plug>(wiki-link-follow)
				augroup END
			]]
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
	use 'tomtom/templator_vim'
	use 'junegunn/vim-easy-align'
	use 'numToStr/Comment.nvim'
	use 'mbbill/undotree'

	use 'windwp/nvim-autopairs'
	use 'tpope/vim-surround'
	-- use { 'junegunn/fzf', run = function() vim.cmd([[ -> fzf#install() ]]) end }
	-- use 'junegunn/fzf.vim'
	-- use 'gfanto/fzf-lsp.nvim'
	-- use 'kkharji/sqlite.lua'
	use 'AckslD/nvim-neoclip.lua'
	use 'fidian/hexmode'
	use { 'michaelb/sniprun', run = 'bash install.sh' }

	use 'nvim-lua/plenary.nvim'
	use 'folke/todo-comments.nvim'
	-- use { 'davawen/neo-presence', run = { "cmake -B build .", "make -C build" }, disable = true }

	use 'sotte/presenting.vim'

	if packer_bootstrap then
		require('packer').sync()
	end
end)
