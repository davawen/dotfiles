-- Remove config file from cached files in case init.vim is reloaded
for k, v in pairs(package.loaded) do
    if string.match(k, "^config") then
		package.loaded[k] = nil
    end
end
require("plugins")

vim.cmd [[ packadd neo-tree.nvim]]

require("mappings")
require("autocommands")
require("commands")

local map, _ = unpack(require("utils.map"))

vim.cmd [[ source ~/.config/nvim/variables.vim ]]

vim.cmd [[let g:AutoPairs = {'(':')', '[':']', '{':'}','"':'"', "`":"`", '```':'```', '"""':'"""', "'''":"'''"}]]

vim.cmd [[ set guifont=Greybeard\ 17px:h12.75 ]]
-- vim.opt.guifont = { "Greybeard 17px", "h12.75" }

-- Set Highlights
local highlights = {
	CmpItemAbbrDeprecated = { bg = "NONE", strikethrough = true, fg = "#616E88" },
	CmpItemAbbrMatch = { bg = "NONE", fg = "#B48EAD" },
	CmpItemAbbrMatchFuzzy = { bg = "NONE", fg = "#B48EAD" },
	CmpItemKindVariable = { bg = "NONE", fg = "#81A1C1" },
	CmpItemKindClass = { bg = "NONE", fg = "#81A1C1" },
	CmpItemKindInterface = { bg = "NONE", fg = "#81A1C1" },
	CmpItemKindText = { bg = "NONE", fg = "#81A1C1" },
	CmpItemKindFunction = { bg = "NONE", fg = "#88C0D0" },
	CmpItemKindConstructor = { bg = "NONE", fg = "#88C0D0" },
	CmpItemKindMethod = { bg = "NONE", fg = "#88C0D0" },
	CmpItemKindKeyword = { bg = "NONE", fg = "#81A1C1" },
	CmpItemKindProperty = { bg = "NONE", fg = "#81A1C1" },
	CmpItemKindUnit = { bg = "NONE", fg = "#81A1C1" },
	CmpItemKindEnum = { bg = "NONE", fg = "#EBCB8B" },
	CmpItemKindEnumMember = { bg = "NONE", fg = "#EBCB8B" },
	CmpItemKindConstant = { bg = "NONE", fg = "#EBCB8B" },

	-- Use undercurls for warnings and lower
	DiagnosticUnderlineWarn = { undercurl = true, sp = "#eed49f" },
	DiagnosticUnderlineInfo = { undercurl = true, sp = "#91d7e3" },
	DiagnosticUnderlineHint = { undercurl = true, sp = "#8bd5ca" },

	-- Overwrite catpuccin fold
	Folded = { bg = "NONE", fg = "#6e738d" }
}

for group, values in pairs(highlights) do
	vim.api.nvim_set_hl(0, group, values)
end

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
		keys = 'asdfghjkl',
		check_comma = true,
		highlight = 'Search',
		highlight_grey = 'Comment'
	}
}

local Rule = require('nvim-autopairs.rule')
local cond = require('nvim-autopairs.conds')

npairs.add_rule(
	Rule("`", "`", { "markdown" })
		:with_cr(cond.none())
)

npairs.remove_rule('```')

-- Template generics
npairs.add_rule(
	Rule("<", ">")
		:with_pair(cond.before_regex("%w"))
)
-- Latex brackets
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


vim.api.nvim_create_autocmd("BufNew", {
	pattern = { "config.lua" },
	callback = function()
		vim.api.nvim_set_option("foldlevelstart", 0)
	end
})

-- Comment.nvim setup
require('Comment').setup()

-- Startup.nvim
require('startup').setup{
	theme = "dashboard"
}

-- require('hologram').setup{
--     auto_display = true -- WIP automatic markdown image display, may be prone to breaking
-- }

-- nvim-cmp/snippets configuration
-- local has_words_before = function()
--   local line, col = unpack(vim.api.nvim_win_get_cursor(0))
--   return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
-- end

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
  insert_at_end = false,
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
	highlight link NeoTreeDirectoryName Directory
	highlight link NeoTreeDirectoryIcon NeoTreeDirectoryName
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
	  filtered_items = { --These filters are applied to both browsing and searching
		hide_dotfiles = false,
		hide_gitignored = false,
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
