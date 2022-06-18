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
		chars = { '{', '[', '(', '"', "'" },
		pattern = [=[[%'%"%)%>%]%)%}%,]]=],
		end_key = '$',
		keys = 'qwertyuiopzxcvbnmasdfghjkl',
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

require('nvim-treesitter.configs').setup {
	ensure_installed = "all",
	highlight = {
		enable = true,
		disable = { "vim" },
		additional_vim_regex_highlighting = true,
	},
}

vim.api.nvim_create_autocmd("BufNew", {
	pattern = { "config.lua" },
	callback = function()
		vim.api.nvim_set_option("foldlevelstart", 0)
	end
})

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

-- Comment.nvim setup
require('Comment').setup()

-- nvim-cmp / luasnip configuration
local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

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
		['<C-f>'] = cmp.mapping.scroll_docs(4),
	
		-- ["<Tab>"] = cmp.mapping(function(fallback)
		-- 	if luasnip.expand_or_locally_jumpable() then
		-- 		luasnip.expand_or_jump()
		-- 	else
		-- 		fallback()
		-- 	end
		-- end, { "i", "s" }),

		-- ["<S-Tab>"] = cmp.mapping(function(fallback)
		-- 	if luasnip.jumpable(-1) then
		-- 		luasnip.jump(-1)
		-- 	else
		-- 		fallback()
		-- 	end
		-- end, { "i", "s" }),
	},
	
	sources = {
		{ name = "path" },

		{ name = "nvim_lua" },
		{ name = "nvim_lsp" },
		{ name = "vsnip" },
		{ name = "buffer", keyword_length = 5 },
	},

	snippet = {
		expand = function(args)
			vim.fn["vsnip#anonymous"](args.body)
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
    root_dir = lspconfig.util.root_pattern("CMakeLists.txt"),
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

lspconfig.svelte.setup{
	cmd = { "svelteserver", "--stdio" },
	filetypes = { "svelte" },
	root_dir = lspconfig.util.root_pattern("package.json"),
}

local pid = vim.fn.getpid()

lspconfig.omnisharp.setup{
	on_attach = on_attach,
	cmd = { vim.fn.getenv("HOME") .. "/bin/omnisharp/run", "--languageserver", "--hostPID", tostring(pid) },
	filetypes = { "cs", "vb" },
    init_options = {},
    on_new_config = function(new_config, new_root_dir)
		if new_root_dir then
			table.insert(new_config.cmd, '-s')
			table.insert(new_config.cmd, new_root_dir)
		end
	end,
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
    args = {},
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

vim.keymap.set('n', '<leader>dh', dap.toggle_breakpoint)
vim.keymap.set('n', '<leader>dd', dap.continue) -- start debugger and relaunch execution
vim.keymap.set('n', '<leader>da', attach) -- attach debugger to process
vim.keymap.set('n', '<leader>dr', function() dap.repl.open({}, 'vsplit') end)
vim.keymap.set('n', '<leader>di', require'dap.ui.widgets'.hover)
-- vim.keymap.set('v', '<leader>di', require'dap.ui.variables'.visual_hover)
vim.keymap.set('n', '<leader>d?', function() local widgets = require'dap.ui.widgets'; widgets.centered_float(widgets.scope) end)
vim.keymap.set('n', '<leader>dk', dap.step_out)
vim.keymap.set('n', '<S-l>', dap.step_into)
vim.keymap.set('n', '<S-j>', dap.step_over)
vim.keymap.set('n', '<leader>k', dap.up) -- navigate up/down the callstack
vim.keymap.set('n', '<leader>j', dap.down)

require("dapui").setup()

-- lualine
require('lualine').setup({
    options = { theme = 'everforest' },
    sections = {
        lualine_a = { 'branch'},
        lualine_b = { 'diagnostics', 'diff'},
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

  floating_window = true, -- show hint in a floating window, set to false for virtual text only mode

  floating_window_above_cur_line = true, -- try to place the floating above the current line when possible Note:
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

-- presence.nvim config
require("presence"):setup({
    -- General options
    auto_update         = true,                       -- Update activity based on autocmd events (if `false`, map or manually execute `:lua package.loaded.presence:update()`)
    neovim_image_text   = "The One True Text Editor", -- Text displayed when hovered over the Neovim image
    main_image          = "neovim",                   -- Main image display (either "neovim" or "file")
    client_id           = "793271441293967371",       -- Use your own Discord application client id (not recommended)
    log_level           = "error",                        -- Log messages at or above this level (one of the following: "debug", "info", "warn", "error")
    debounce_timeout    = 10,                         -- Number of seconds to debounce events (or calls to `:lua package.loaded.presence:update(<filename>, true)`)
    enable_line_number  = false,                      -- Displays the current line number instead of the current project
    blacklist           = {},                         -- A list of strings or Lua patterns that disable Rich Presence if the current file name, path, or workspace matches
    buttons             = true,                       -- Configure Rich Presence button(s), either a boolean to enable/disable, a static table (`{{ label = "<label>", url = "<url>" }, ...}`, or a function(buffer: string, repo_url: string|nil): table)
    file_assets         = {},                         -- Custom file asset definitions keyed by file names and extensions (see default config at `lua/presence/file_assets.lua` for reference)

    -- Rich Presence text options
    editing_text        = "Editing %s",               -- Format string rendered when an editable file is loaded in the buffer (either string or function(filename: string): string)
    file_explorer_text  = "Browsing %s",              -- Format string rendered when browsing a file explorer (either string or function(file_explorer_name: string): string)
    git_commit_text     = "Committing changes",       -- Format string rendered when committing changes in git (either string or function(filename: string): string)
    plugin_manager_text = "Managing plugins",         -- Format string rendered when managing plugins (either string or function(plugin_manager_name: string): string)
    reading_text        = "Reading %s",               -- Format string rendered when a read-only or unmodifiable file is loaded in the buffer (either string or function(filename: string): string)
    workspace_text      = "Working on %s",            -- Format string rendered when in a git repository (either string or function(project_name: string|nil, filename: string): string)
    line_number_text    = "Line %s out of %s",        -- Format string rendered when `enable_line_number` is set to true (either string or function(line_number: number, line_count: number): string)
})

require('telescope').setup {
	defaults = { file_ignore_patterns = { "build"  } } 
}

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
		show_hidden = false,
		respect_gitignore = true,
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

require('todo-comments').setup {
	keywords = {
		DONE = { icon = " ", color = "hint", alt = { "FINISHED", "IMPL", "IMPLEMENTED" }  }
	},
	merge_keywords = true,
}
