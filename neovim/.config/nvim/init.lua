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

-- Neovide config
vim.o.guifont = "Iosevka:h13.5"
vim.g.neovide_refresh_rate = 144
vim.g.neovide_cursor_animation_length = 0.05
vim.g.neovide_cursor_trail_size = 0.2
vim.g.neovide_cursor_animate_command_line = false
vim.g.neovide_cursor_vfx_mode = "pixiedust"
if vim.g.neovide then
	vim.g.neovide_input_use_logo = 1 -- enable use of the logo (cmd) key
	vim.keymap.set('v', '<D-c>', '"+y') -- Copy
	vim.keymap.set('n', '<D-v>', '"+P') -- Paste normal mode
	vim.keymap.set('v', '<D-v>', '"+P') -- Paste visual mode
	vim.keymap.set('c', '<D-v>', '<C-R>+') -- Paste command mode
	vim.keymap.set('i', '<C-S-V>', '<ESC>l"+Pla') -- Paste insert mode
end

-- vim.cmd [[ set mouse=nv ]]
vim.cmd [[ set wrap ]]
vim.cmd [[ let g:c_syntax_for_h = 1 ]] -- Set *.h files to be c instead of cpp
vim.cmd [[ let g:cursorhold_updatetime = 250 ]]

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
	Folded = { bg = "NONE", fg = "#6e738d" },

	-- Overwrite horrendous buffer line visible color
	TabLineSel = { bg = "#1e2030", fg = "#81a1c1" },
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
	icons = {
		-- Configure the base icons on the bufferline.
		buffer_index = true,
		buffer_number = false,
		button = '',
		-- Enables / disables diagnostic symbols
		diagnostics = {
			[vim.diagnostic.severity.ERROR] = {enabled = true, icon = 'ﬀ'},
			[vim.diagnostic.severity.WARN] = {enabled = false},
			[vim.diagnostic.severity.INFO] = {enabled = false},
			[vim.diagnostic.severity.HINT] = {enabled = false},
		},
		filetype = {
			-- Sets the icon's highlight group.
			-- If false, will use nvim-web-devicons colors
			custom_colors = false,

			-- Requires `nvim-web-devicons` if `true`
			enabled = true,
		}
	},

	-- If set, the icon color will follow its corresponding buffer
	-- highlight group. By default, the Buffer*Icon group is linked to the
	-- Buffer* group (see Highlighting below). Otherwise, it will take its
	-- default value as defined by devicons.
	icon_custom_colors = false,

	-- Configure icons on the bufferline.
	separator = { left = '▎', right = '' },
	modified = { button = '●' },
	pinned = { button = '車' },

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
map('n', '<A-0>', '<Cmd>BufferGoto 10<Cr>')

-- map('n', '<silent>dbe', '<Cmd>BufferLineSortByExtension<Cr>')
-- map('n', '<silent>dbd', '<Cmd>BufferLineSortByDirectory<Cr>')

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

-- Telescope.nvim
require('telescope').setup {
	defaults = {
		file_ignore_patterns = { "build", "dist", "node_modules", "Cargo.lock" }
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
