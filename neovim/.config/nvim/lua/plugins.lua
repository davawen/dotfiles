local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

return require'packer'.startup(function(use)
	use 'wbthomason/packer.nvim'

	-- Themes
	use 'shaunsingh/nord.nvim'
	use 'sainnhe/everforest'
	use 'habamax/vim-polar'
	use { 'catppuccin/nvim', as = 'catppuccin' }
	use'nyoom-engineering/oxocarbon.nvim'

	use 'nvim-lualine/lualine.nvim'
	use 'startup-nvim/startup.nvim'

	-- Treesitter
	use { 'nvim-treesitter/nvim-treesitter', run = ":TSUpdate" }
	-- 'romgrk/nvim-treesitter-context'
	use 'danymat/neogen'

	-- LSP
	use 'neovim/nvim-lspconfig'
	use 'onsails/lspkind-nvim'
	use 'ray-x/lsp_signature.nvim'
	use 'ojroques/nvim-lspfuzzy'

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
	use 'simrat39/rust-tools.nvim'
	use 'mhartington/formatter.nvim'

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
	use { 'plasticboy/vim-markdown',
		config = function ()
			vim.g.vim_markdown_folding_disabled = 1
			vim.g.vim_markdown_conceal = 0

			vim.g.tex_conceal = ""
			vim.g.vim_markdown_math = 1

			vim.g.vim_markdown_frontmatter = 1  -- for YAML format
			vim.g.vim_markdown_toml_frontmatter = 1  -- for TOML format
			vim.g.vim_markdown_json_frontmatter = 1  -- for JSON format
		end
	}
	use 'habamax/vim-godot'
	-- { 'xuhdev/vim-latex-live-preview', opt = true }

	-- Navigation
	use 'nvim-telescope/telescope.nvim'
	use 'MunifTanjim/nui.nvim'
	use { 'nvim-neo-tree/neo-tree.nvim',
		-- Remove neo-tree legacy commands before plugin is loaded
		setup = function ()
			vim.g.neo_tree_remove_legacy_commands = 1
		end
	}
	use 'romgrk/barbar.nvim'
	use { 'mg979/vim-visual-multi', branch = 'master'}
	use { 'voldikss/vim-floaterm',
		config = function ()
			vim.g.floaterm_width = 0.5
			vim.g.floaterm_height = 1.0
			vim.g.floaterm_position = "right"
		end
	}
	use 'unblevable/quick-scope'

	-- Other
	use 'wakatime/vim-wakatime'
	use 'tomtom/templator_vim'
	use 'junegunn/vim-easy-align'
	use 'numToStr/Comment.nvim'

	use 'windwp/nvim-autopairs'
	use 'tpope/vim-surround'
	use { 'junegunn/fzf', run = function() vim.cmd([[ -> fzf#install() ]]) end }
	use 'junegunn/fzf.vim'
	use 'gfanto/fzf-lsp.nvim'
	-- use 'kkharji/sqlite.lua'
	use 'AckslD/nvim-neoclip.lua'
	use 'fidian/hexmode'
	use { 'michaelb/sniprun', run = 'bash install.sh' }

	use 'nvim-lua/plenary.nvim'
	use 'folke/todo-comments.nvim'
	use { 'davawen/neo-presence', run = { "cmake -B build .", "make -C build" } }
	use 'edluffy/hologram.nvim'

	use 'sotte/presenting.vim'
	use 'ryanoasis/vim-devicons'
	use 'kyazdani42/nvim-web-devicons'

	if packer_bootstrap then
		require('packer').sync()
	end
end)
