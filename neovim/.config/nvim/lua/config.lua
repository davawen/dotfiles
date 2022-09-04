local map = vim.keymap.set

-- Vim auto-pairs config
local npairs = require("nvim-autopairs");
npairs.setup {
	-- Lua pattern to check if plugin should apply depending on next character
	-- |.thing -> (|.thing
	ignored_next_char = "[%%%'%\"]",
	enable_moveright = false,
	enable_check_bracket_line = false, -- check bracket in same line
	fast_wrap = {
		map = '<M-e>',
		pattern = [=[[%'%"%)%>%]%)%}%,%;]]=],
		end_key = '$',
		keys = 'qsdfghjklm',
		check_comma = true,
		highlight = 'Search',
		highlight_grey='Comment'
	}
}

local Rule = require('nvim-autopairs.rule')
local cond = require('nvim-autopairs.conds')

-- Template generics
npairs.add_rule(
	Rule("<", ">")
		:with_pair(cond.before_regex("%w"))
)
-- Latex brackes
npairs.add_rule(
	Rule('\\[', '\\]', { "tex", "latex" })
		:with_cr(cond.none())
)

-- Add spaces
npairs.add_rules {
  Rule(' ', ' ')
    :with_pair(function (opts)
      local pair = opts.line:sub(opts.col - 1, opts.col)
      return vim.tbl_contains({ '()', '[]', '{}' }, pair)
    end),
  Rule('( ', ' )')
      :with_pair(function() return false end)
      :with_move(function(opts)
          return opts.prev_char:match('.%)') ~= nil
      end)
      :use_key(')'),
  Rule('{ ', ' }')
      :with_pair(function() return false end)
      :with_move(function(opts)
          return opts.prev_char:match('.%}') ~= nil
      end)
      :use_key('}'),
  Rule('[ ', ' ]')
      :with_pair(function() return false end)
      :with_move(function(opts)
          return opts.prev_char:match('.%]') ~= nil
      end)
      :use_key(']')
}

-- Tree sitter
local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
parser_config.wgsl = {
    install_info = {
        url = "https://github.com/szebniok/tree-sitter-wgsl",
        files = {"src/parser.c"}
    },
}

require('nvim-treesitter.configs').setup {
	ensure_installed = "all",
	highlight = {
		enable = true,
		disable = { "vim" },
		additional_vim_regex_highlighting = true,
	},
	incremental_selection = {
		enable = true,
		keymaps = {
			init_selection = "gnn",
			node_incremental = "grn",
			scope_incremental = "grc",
			node_decremental = "grm"
		}
	},
	indent = {
		enable = true
	}
}

-- require('treesitter-context').setup {
--     enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
--     throttle = true, -- Throttles plugin updates (may improve performance)
--     max_lines = 7, -- How many lines the window should span. Values <= 0 mean no limit.
--     patterns = { -- Match patterns for TS nodes. These get wrapped to match at word boundaries.
--         -- For all filetypes
--         -- Note that setting an entry here replaces all other patterns for this entry.
--         -- By setting the 'default' entry below, you can control which nodes you want to
--         -- appear in the context window.
--         default = {
--             'class',
--             'function',
--             'method',
--             'for', -- These won't appear in the context
--             'while',
--             -- 'if',
--             'switch',
--             'case',
--         },
--         -- Example for a specific filetype.
--         -- If a pattern is missing, *open a PR* so everyone can benefit.
--         --   rust = {
--         --       'impl_item',
--         --   },
--     },
-- }

vim.api.nvim_create_autocmd("BufNew", {
	pattern = { "config.lua" },
	callback = function()
		vim.api.nvim_set_option("foldlevelstart", 0)
	end
})
local map = vim.keymap.set

-- Comment.nvim setup
require('Comment').setup()

-- Startup.nvim
require('startup').setup{
	theme = "dashboard"
}

-- Hologram.nvim
require('hologram').setup{
    auto_display = true -- WIP automatic markdown image display, may be prone to breaking
}

-- nvim-cmp/snippets configuration
local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

require('snippy').setup({
    mappings = {
        is = {
            ['<Tab>'] = 'expand_or_advance',
            ['<S-Tab>'] = 'previous',
        },
        nx = {
            ['<leader>x'] = 'cut_text',
        },
    },
})

local lspkind = require("lspkind")
local cmp = require("cmp") 

cmp.setup({

	mapping = {
		["<CR>"] = cmp.mapping.confirm {
			behavior = cmp.ConfirmBehavior.Insert,
			select = false,
		},

		["<S-CR>"] = cmp.mapping.confirm {
			behavior = cmp.ConfirmBehavior.Insert,
			select = true
		},
		["<C-CR>"] = cmp.mapping.confirm {
			behavior = cmp.ConfirmBehavior.Insert,
			select = true
		},

		["<c-space>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.close()
			else
				cmp.complete()
			end
		end, { "i", "s" }),

		["<c-J>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			else
				fallback()
			end
		end, { "i", "s" }),

		["<c-K>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			else
				fallback()
			end
		end, { "i", "s" }),

		['<C-d>'] = cmp.mapping.scroll_docs(-4),
		['<C-f>'] = cmp.mapping.scroll_docs(4)
	},
	
	sources = {
		{ name = "path" },

		{ name = "nvim_lua" },
		{ name = "nvim_lsp" },
		{ name = "snippy" },
		{ name = "buffer", keyword_length = 5 },
	},

	snippet = {
		expand = function(args)
			require('snippy').expand_snippet(args.body)
		end,
	},

	formatting = {
		format = lspkind.cmp_format({
			with_text = true,
			menu = {
				buffer = "[buf]",
				nvim_lsp = "[LSP]",
				nvim_lua = "[api]",
				path = "[path]",
				luasnip = "[snip]"
			}
		})
	},
	
	view = {
		entries = "custom"
	},

	experimental = {
		ghost_text = true,
		native_menu = false
	},
})

-- In relation to nvim-autopairs plugin, insert '(' after selected a function or method ithem
local cmp_autopairs = require('nvim-autopairs.completion.cmp')
cmp.event:on( 'confirm_done', cmp_autopairs.on_confirm_done({  map_char = { tex = '' } }))

-- nvim-code-action-menu
vim.g.code_action_menu_window_border = 'single'
vim.g.code_action_menu_show_details = false
vim.g.code_action_menu_show_diff = true

-- nvim LSP configuration
-- Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap=true, silent=true }
vim.api.nvim_set_keymap('n', 'ge', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
vim.api.nvim_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
vim.api.nvim_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
vim.api.nvim_set_keymap('n', 'gq', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  --vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader><space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  --vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader><space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  --vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader><space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>ca', '<cmd>CodeActionMenu<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

-- capabilities.textDocument.completion.completionItem.snippetSupport = false

require('lspfuzzy').setup {
  methods = 'all',         -- either 'all' or a list of LSP methods (see below)
  jump_one = true,         -- jump immediately if there is only one location
  save_last = false,       -- save last location results for the :LspFuzzyLast command
  callback = nil,          -- callback called after jumping to a location
  fzf_preview = {          -- arguments to the FZF '--preview-window' option
    'right:+{2}-/2'          -- preview on the right and centered on entry
  },
  fzf_action = {               -- FZF actions
    ['ctrl-t'] = 'tab split',  -- go to location in a new tab
    ['ctrl-v'] = 'vsplit',     -- go to location in a vertical split
    ['ctrl-x'] = 'split',      -- go to location in a horizontal split
  },
  fzf_modifier = ':~:.',   -- format FZF entries, see |filename-modifiers|
  fzf_trim = true,         -- trim FZF entries
}

local lspconfig = require('lspconfig')

lspconfig.clangd.setup{
	on_attach = on_attach,
	cmd = {
		"clangd",
		"--background-index",
		"--completion-style=detailed",
		"--header-insertion=never"
	},
	init_options = {
		compilationDatabasePath = "build"
	},
	filetypes = { "c", "cpp", "cuda", "opencl" },
	--[[ flags = {
		debounce_text_changes = 150
	}, ]]
    root_dir = lspconfig.util.root_pattern("CMakeLists.txt", "xmake.lua"),
	capabilities = capabilities,
}

lspconfig.jedi_language_server.setup{
	on_attach = on_attach,
	cmd = { "jedi-language-server" },
	filetypes = { "python" },
	single_file_support = true,
	capabilities = capabilities,
}

lspconfig.tsserver.setup{
	on_attach = on_attach,
	cmd = { "typescript-language-server", "--stdio" },
	filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx" },
    init_options = {
		hostInfo = "neovim"
    },
    root_dir = lspconfig.util.root_pattern("package.json", "tsconfig.json"),
	single_file_support = true,
	capabilities = capabilities
}

vim.g.markdown_fenced_languages = { "ts=typescript" }
lspconfig.denols.setup {
	cmd = { "deno", "lsp" },
	filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx" },
	init_options = {
		enable = true,
		unstable = false
	},
	root_dir = lspconfig.util.root_pattern("deno.json", "deno.jsonc")
}

lspconfig.svelte.setup{
	cmd = { "svelteserver", "--stdio" },
	filetypes = { "svelte" },
	root_dir = lspconfig.util.root_pattern("package.json"),
}

lspconfig.omnisharp.setup{
	on_attach = on_attach,
	filetypes = { "cs", "vb" },
	cmd = { "dotnet", "/home/davawen/.local/bin/omnisharp/OmniSharp.dll" },
	-- Enables support for reading code style, naming convention and analyzer
    -- settings from .editorconfig.
    enable_editorconfig_support = true,

    -- If true, MSBuild project system will only load projects for files that
    -- were opened in the editor. This setting is useful for big C# codebases
    -- and allows for faster initialization of code navigation features only
    -- for projects that are relevant to code that is being edited. With this
    -- setting enabled OmniSharp may load fewer projects and may thus display
    -- incomplete reference lists for symbols.
    enable_ms_build_load_projects_on_demand = false,

    -- Enables support for roslyn analyzers, code fixes and rulesets.
    enable_roslyn_analyzers = true,

    -- Specifies whether 'using' directives should be grouped and sorted during
    -- document formatting.
    organize_imports_on_format = true,

    -- Enables support for showing unimported types and unimported extension
    -- methods in completion lists. When committed, the appropriate using
    -- directive will be added at the top of the current file. This option can
    -- have a negative impact on initial completion responsiveness,
    -- particularly for the first few completion sessions after opening a
    -- solution.
    enable_import_completion = false,

    -- Specifies whether to include preview versions of the .NET SDK when
    -- determining which version to use for project loading.
    sdk_include_prereleases = true,

    -- Only run analyzers against open files when 'enableRoslynAnalyzers' is
    -- true
    analyze_open_documents_only = false,
	root_dir = lspconfig.util.root_pattern('*.sln', '*.csproj'),
	capabilities = capabilities
}


lspconfig.texlab.setup{
	cmd = { "texlab" },
	filetypes = { "tex", "latex" },
	settings = {
	  texlab = {
		auxDirectory = ".",
		bibtexFormatter = "texlab",
		build = {
		  args = { "-pdf", "-interaction=nonstopmode", "-synctex=1", "%f" },
		  executable = "latexmk",
		  forwardSearchAfter = false,
		  onSave = false
		},
		chktex = {
		  onEdit = false,
		  onOpenAndSave = false
		},
		diagnosticsDelay = 300,
		formatterLineLength = 80,
		forwardSearch = {
		  args = {}
		},
		latexFormatter = "latexindent",
		latexindent = {
		  modifyLineBreaks = false
		}
	  }
	},
	single_file_support = true,
	capabilities = capabilities
}

-- Rust Tools configuration
require('rust-tools').setup {
	tools = { -- rust-tools options
        autoSetHints = true,
        hover_with_actions = true,
        inlay_hints = {
            show_parameter_hints = false,
            parameter_hints_prefix = "",
            other_hints_prefix = "",
        },
    },

    -- all the opts to send to nvim-lspconfig
    -- these override the defaults set by rust-tools.nvim
    -- see https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#rust_analyzer
	server = {
		-- standalone file support
		-- setting it to false may improve startup time
		standalone = true,
		on_attach = on_attach,
		cmd = { "rust-analyzer" },
		filetypes = { "rust" },
		-- Single file opening should is implemented but not sure how to enable it
		single_file_support = true,
		root_dir = lspconfig.util.root_pattern("Cargo.toml", "rust-project.json"),
		settings = {
			-- to enable rust-analyzer settings visit:
			-- https://github.com/rust-analyzer/rust-analyzer/blob/master/docs/user/generated_config.adoc
			["rust-analyzer"] = {
				-- enable clippy on save
				checkOnSave = {
					command = "clippy"
				},
			}
		},
		capabilities = capabilities
	}, -- rust-analyer options
}

-- Debugging
local dap = require('dap')
dap.adapters.lldb = {
  type = 'executable',
  command = '/usr/bin/lldb-vscode', -- adjust as needed, must be absolute path
  name = 'lldb'
}

dap.configurations.cpp = {
  {
    name = 'Launch',
    type = 'lldb',
    request = 'launch',
    program = function()
      return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
    end,
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
    args = { "-h" },
	env = { 
		LLDB_LAUNCH_FLAG_LAUNCH_IN_TTY = "YES"
	},

    -- 💀
    -- if you change `runInTerminal` to true, you might need to change the yama/ptrace_scope setting:
    --
    --    echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
    --
    -- Otherwise you might get the following error:
    --
    --    Error on launch: Failed to attach to the target process
    --
    -- But you should be aware of the implications:
    -- https://www.kernel.org/doc/html/latest/admin-guide/LSM/Yama.html
    runInTerminal = false,

    -- 💀
    -- If you use `runInTerminal = true` and resize the terminal window,
    -- lldb-vscode will receive a `SIGWINCH` signal which can cause problems
    -- To avoid that uncomment the following option
    -- See https://github.com/mfussenegger/nvim-dap/issues/236#issuecomment-1066306073
    -- postRunCommands = {'process handle -p true -s false -n false SIGWINCH'}
  },
}
dap.configurations.c = dap.configurations.cpp
dap.configurations.rust = dap.configurations.cpp

vim.fn.sign_define('DapBreakpoint', {text='', texthl='', linehl='', numhl=''});
vim.fn.sign_define('DapStopped', {text='', texthl='', linehl='', numhl=''});


local function attach()
	print("Attaching debugger...")
	dap.run({
		type = 'node2',
		request = 'attach',
		cwd = vim.fn.getcwd(),
		sourceMaps = true,
		protocol = 'inspector',
		skipFiles = {'<node_internals>/**/*.js'}
	})
end

require("dapui").setup{
	icons = { expanded = "▾", collapsed = "▸" },
	mappings = {
		-- Use a table to apply multiple mappings
		expand = { "<CR>", "<2-LeftMouse>" },
		open = "o",
		remove = "d",
		edit = "e",
		repl = "r",
		toggle = "t",
	},
	-- Expand lines larger than the window
	-- Requires >= 0.7
	expand_lines = vim.fn.has("nvim-0.7"),
	-- Layouts define sections of the screen to place windows.
	-- The position can be "left", "right", "top" or "bottom".
	-- The size specifies the height/width depending on position. It can be an Int
	-- or a Float. Integer specifies height/width directly (i.e. 20 lines/columns) while
	-- Float value specifies percentage (i.e. 0.3 - 30% of available lines/columns)
	-- Elements are the elements shown in the layout (in order).
	-- Layouts are opened in order so that earlier layouts take priority in window sizing.
	layouts = {
		{
			elements = {
				-- Elements can be strings or table with id and size keys.
				{ id = "scopes", size = 0.25 },
				"breakpoints",
				"stacks",
				"watches",
			},
			size = 40, -- 40 columns
			position = "left",
		},
		{
			elements = {
				"repl",
				"console",
			},
			size = 0.25, -- 25% of total lines
			position = "bottom",
		},
	},
	floating = {
		max_height = nil, -- These can be integers or a float between 0 and 1.
		max_width = nil, -- Floats will be treated as percentage of your screen.
		border = "single", -- Border style. Can be "single", "double" or "rounded"
		mappings = {
			close = { "q", "<Esc>" },
		},
	},
	windows = { indent = 1 },
	render = {
		max_type_length = 30, -- Can be integer or nil.
	}
}

local double_eval = function()
	local eval = require("dapui").eval
	eval()
	eval()
end

map('n', '<leader>dh', dap.toggle_breakpoint)
map('n', '<leader>dd', dap.continue) -- start debugger and relaunch execution
map('n', '<leader>da', attach) -- attach debugger to process
map('n', '<leader>dr', function() dap.repl.open({}, 'belowright split') end)
map('n', '<leader>di', double_eval)
map('v', '<leader>di', double_eval)
map('n', '<leader>d?', function() local widgets = require'dap.ui.widgets'; widgets.centered_float(widgets.scope) end)
map('n', '<leader>dk', dap.step_out)
map('n', 'd<S-l>', dap.step_into)
map('n', 'd<S-j>', dap.step_over)
map('n', 'dk', dap.up) -- navigate up/down the callstack
map('n', 'dj', dap.down)


-- formatter.nvim
-- Provides the Format and FormatWrite commands
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

-- barbar.nvim
require('bufferline').setup {
  -- Enable/disable animations
  animation = true,
  -- Enable/disable auto-hiding the tab bar when there is a single buffer
  auto_hide = false,
  -- Enable/disable current/total tabpages indicator (top right corner)
  tabpages = true,
  -- Enable/disable close button
  closable = true,
  -- Enables/disable clickable tabs
  --  - left-click: go to buffer
  --  - middle-click: delete buffer
  clickable = true,
  -- Excludes buffers from the tabline
  exclude_ft = {},
  exclude_name = {'package.json', 'init.vim', 'config.lua', 'Cargo.toml'},

  -- Enable/disable icons
  -- if set to 'numbers', will show buffer index in the tabline
  -- if set to 'both', will show buffer index and icons in the tabline
  icons = 'both',

  -- If set, the icon color will follow its corresponding buffer
  -- highlight group. By default, the Buffer*Icon group is linked to the
  -- Buffer* group (see Highlighting below). Otherwise, it will take its
  -- default value as defined by devicons.
  icon_custom_colors = false,

  -- Configure icons on the bufferline.
  icon_separator_active = '▎ ',
  icon_separator_inactive = '▎',
  icon_close_tab = '',
  icon_close_tab_modified = '●',
  icon_pinned = '車',

  -- If true, new buffers will be inserted at the start/end of the list.
  -- Default is to insert after current buffer.
  insert_at_end = true,
  insert_at_start = false,

  -- Sets the maximum padding width with which to surround each tab
  maximum_padding = 1,

  -- Sets the maximum buffer name length.
  maximum_length = 30,

  -- If set, the letters for each buffer in buffer-pick mode will be
  -- assigned based on their name. Otherwise or in case all letters are
  -- already assigned, the behavior is to assign letters in order of
  -- usability (see order below)
  semantic_letters = true,

  -- New buffer letters are assigned in this order. This order is
  -- optimal for the qwerty keyboard layout but might need adjustement
  -- for other layouts.
  letters = 'asdfjkl;ghnmxcvbziowerutyqpASDFJKLGHNMXCVBZIOWERUTYQP',

  -- Sets the name of unnamed buffers. By default format is "[Buffer X]"
  -- where X is the buffer number. But only a static string is accepted here.
  no_name_title = nil,
}

map('n', '<A-,>', '<Cmd>BufferPrevious<Cr>')
map('n', '<A-.>', '<Cmd>BufferNext<Cr>')

map('n', '<C-[>', '<Cmd>BufferMovePrevious<Cr>')
map('n', '<C-]>', '<Cmd>BufferMoveNext<Cr>')

map('n', 'db', '<Cmd>BufferClose!<Cr>')
map('n', 'gp', '<Cmd>BufferPick<Cr>')
map('n', '<A-p>', '<Cmd>BufferPin<Cr>')

map('n', '<A-1>', '<Cmd>BufferGoto 1<Cr>')
map('n', '<A-2>', '<Cmd>BufferGoto 2<Cr>')
map('n', '<A-3>', '<Cmd>BufferGoto 3<Cr>')
map('n', '<A-4>', '<Cmd>BufferGoto 4<Cr>')
map('n', '<A-5>', '<Cmd>BufferGoto 5<Cr>')
map('n', '<A-6>', '<Cmd>BufferGoto 6<Cr>')
map('n', '<A-7>', '<Cmd>BufferGoto 7<Cr>')
map('n', '<A-8>', '<Cmd>BufferGoto 8<Cr>')
map('n', '<A-9>', '<Cmd>BufferGoto 9<Cr>')
map('n', '<A-9>', '<Cmd>BufferLast 9<Cr>')

-- map('n', '<silent>dbe', '<Cmd>BufferLineSortByExtension<Cr>')
-- map('n', '<silent>dbd', '<Cmd>BufferLineSortByDirectory<Cr>')

-- lualine
require('lualine').setup({
    options = { 
		theme = 'everforest',
		globalstatus = true
	},
    sections = {
        lualine_a = { 'mode'},
        lualine_b = { 'branch', 'diagnostics', 'diff'},
        lualine_c = { "vim.fn.expand('%')"},
        lualine_x = { 'location', 'filetype'},
        lualine_y = { 'os.date("%I:%M:%S", os.time())'},
        lualine_z = { }
    }
})


lsp_signature_cfg = {
	debug = false, -- set to true to enable debug logging
  log_path = vim.fn.stdpath("cache") .. "/lsp_signature.log", -- log dir when debug is on
  -- default is  ~/.cache/nvim/lsp_signature.log
  verbose = false, -- show debug line number

  bind = true, -- This is mandatory, otherwise border config won't get registered.
               -- If you want to hook lspsaga or other signature handler, pls set to false
  doc_lines = 10, -- will show two lines of comment/doc(if there are more than two lines in doc, will be truncated);
                 -- set to 0 if you DO NOT want any API comments be shown
                 -- This setting only take effect in insert mode, it does not affect signature help in normal
                 -- mode, 10 by default

  floating_window = false, -- show hint in a floating window, set to false for virtual text only mode

  floating_window_above_cur_line = false, -- try to place the floating above the current line when possible Note:
  -- will set to true when fully tested, set to false will use whichever side has more space
  -- this setting will be helpful if you do not want the PUM and floating win overlap

  floating_window_off_x = 1, -- adjust float windows x position.
  floating_window_off_y = 1, -- adjust float windows y position.


  fix_pos = false,  -- set to true, the floating window will not auto-close until finish all parameters
  hint_enable = true, -- virtual hint enable
  hint_prefix = "🐼 ",  -- Panda for parameter
  hint_scheme = "String",
  hi_parameter = "LspSignatureActiveParameter", -- how your parameter will be highlight
  max_height = 10, -- max height of signature floating_window, if content is more than max_height, you can scroll down
                   -- to view the hiding contents
  max_width = 140, -- max_width of signature floating_window, line will be wrapped if exceed max_width
  handler_opts = {
    border = "rounded"   -- double, rounded, single, shadow, none
  },

  always_trigger = true, -- sometime show signature on new line or in middle of parameter can be confusing, set it to false for #58

  auto_close_after = nil, -- autoclose signature float win after x sec, disabled if nil.
  extra_trigger_chars = {}, -- Array of extra characters that will trigger signature completion, e.g., {"(", ","}
  zindex = 200, -- by default it will be on top of all floating windows, set to <= 50 send it to bottom

  padding = '', -- character to pad on left and right of signature can be ' ', or '|'  etc

  transparency = nil, -- disabled by default, allow floating win transparent value 1~100
  shadow_blend = 36, -- if you using shadow as border use this set the opacity
  shadow_guibg = 'Black', -- if you using shadow as border use this set the color e.g. 'Green' or '#121315'
  timer_interval = 200, -- default timer check interval set to lower value if you want to reduce latency
  toggle_key = nil -- toggle signature on and off in insert mode,  e.g. toggle_key = '<M-x>'
}
require('lsp_signature').setup(lsp_signature_cfg)

-- Trigger rerender of status line every second for clock
if _G.Statusline_timer == nil then
    _G.Statusline_timer = vim.loop.new_timer()
else
    _G.Statusline_timer:stop()
end
_G.Statusline_timer:start(0, 1000, vim.schedule_wrap(
                              function() vim.api.nvim_command('redrawstatus') end))

-- Telescope.nvim
require('telescope').setup {
	defaults = { file_ignore_patterns = { "build", "dist", "node_modules" } } 
}

-- neotree.nvim
vim.cmd([[
	hi link NeoTreeDirectoryName Directory
	hi link NeoTreeDirectoryIcon NeoTreeDirectoryName
]])

require('neo-tree').setup {
	close_if_last_window = false, -- Close Neo-tree if it is the last window left in the tab
	popup_border_style = "rounded",
	enable_git_status = true,
	enable_diagnostics = true,
	default_component_configs = {
	  indent = {
		indent_size = 2,
		padding = 1, -- extra padding on left hand side
		with_markers = true,
		indent_marker = "│",
		last_indent_marker = "└",
		highlight = "NeoTreeIndentMarker",
	  },
	  icon = {
		folder_closed = "",
		folder_open = "",
		folder_empty = "ﰊ",
		default = "*",
	  },
	  name = {
		trailing_slash = false,
		use_git_status_colors = true,
	  },
	  git_status = {
		highlight = "NeoTreeDimText", -- if you remove this the status will be colorful
	  },
	},
	filesystem = {
	  filters = { --These filters are applied to both browsing and searching
		show_hidden = true,
		respect_gitignore = false,
	  },
	  follow_current_file = false, -- This will find and focus the file in the active buffer every
								   -- time the current file is changed while the tree is open.
	  use_libuv_file_watcher = false, -- This will use the OS level file watchers
									  -- to detect changes instead of relying on nvim autocmd events.
	  hijack_netrw_behavior = "open_default", -- netrw disabled, opening a directory opens neo-tree
											  -- in whatever position is specified in window.position
							-- "open_split",  -- netrw disabled, opening a directory opens within the
											  -- window like netrw would, regardless of window.position
							-- "disabled",    -- netrw left alone, neo-tree does not handle opening dirs
	  window = {
		position = "left",
		width = 40,
		mappings = {
		  ["<2-LeftMouse>"] = "open",
		  ["<cr>"] = "open",
		  ["S"] = "open_split",
		  ["s"] = "open_vsplit",
		  ["C"] = "close_node",
		  ["<bs>"] = "navigate_up",
		  ["."] = "set_root",
		  ["H"] = "toggle_hidden",
		  ["I"] = "toggle_gitignore",
		  ["R"] = "refresh",
		  ["/"] = "fuzzy_finder",
		  --["/"] = "filter_as_you_type", -- this was the default until v1.28
		  --["/"] = "none" -- Assigning a key to "none" will remove the default mapping
		  ["f"] = "filter_on_submit",
		  ["<c-x>"] = "clear_filter",
		  ["a"] = "add",
		  ["d"] = "delete",
		  ["r"] = "rename",
		  ["c"] = "copy_to_clipboard",
		  ["x"] = "cut_to_clipboard",
		  ["p"] = "paste_from_clipboard",
		  ["m"] = "move", -- takes text input for destination
		  ["q"] = "close_window",
		}
	  }
	},
	buffers = {
	  show_unloaded = true,
	  window = {
		position = "left",
		mappings = {
		  ["<2-LeftMouse>"] = "open",
		  ["<cr>"] = "open",
		  ["S"] = "open_split",
		  ["s"] = "open_vsplit",
		  ["<bs>"] = "navigate_up",
		  ["."] = "set_root",
		  ["R"] = "refresh",
		  ["a"] = "add",
		  ["d"] = "delete",
		  ["r"] = "rename",
		  ["c"] = "copy_to_clipboard",
		  ["x"] = "cut_to_clipboard",
		  ["p"] = "paste_from_clipboard",
		  ["bd"] = "buffer_delete",
		}
	  },
	},
	git_status = {
	  window = {
		position = "float",
		mappings = {
		  ["<2-LeftMouse>"] = "open",
		  ["<cr>"] = "open",
		  ["S"] = "open_split",
		  ["s"] = "open_vsplit",
		  ["C"] = "close_node",
		  ["R"] = "refresh",
		  ["d"] = "delete",
		  ["r"] = "rename",
		  ["c"] = "copy_to_clipboard",
		  ["x"] = "cut_to_clipboard",
		  ["p"] = "paste_from_clipboard",
		  ["A"]  = "git_add_all",
		  ["gu"] = "git_unstage_file",
		  ["ga"] = "git_add_file",
		  ["gr"] = "git_revert_file",
		  ["gc"] = "git_commit",
		  ["gp"] = "git_push",
		  ["gg"] = "git_commit_and_push",
		}
	  }
	}
}

-- todo-comments
require('todo-comments').setup {
	keywords = {
		DONE = { icon = " ", color = "hint", alt = { "FINISHED", "IMPL", "IMPLEMENTED" }  }
	},
	merge_keywords = true,
}

-- neoclip.lua
require('neoclip').setup {
	enable_persistent_history = false
}
map('n', '<leader>fp', require('telescope').extensions.neoclip.default)
