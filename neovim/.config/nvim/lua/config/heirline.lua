local c = require('heirline.conditions')
local u = require('heirline.utils')

---@param b boolean
---@param v1 any
---@param v2 any
local function ternary(b, v1, v2)
	if b then return v1 else return v2 end
end

local mode = {
	condition = function ()
		return c.is_active()
	end,
	init = function (self)
		self.mode = vim.fn.mode()
	end,
	provider = function (self)
		return " " .. self.as_text[self.mode] .. " "
	end,
	hl = function (self)
		return {
			fg = self.as_color[self.mode],
			bg = "surface0",
			bold = true,
			reverse = true
		}
	end,
	static = {
		as_text = {
			n = "NORMAL",
			v = "VISUAL",
			V = "VILINE",
			["\22"] =  "VBLOCK", -- visual block
			s = "SELECT",
			S = "SELINE",
			["\19"] = "SBLOCK",
			i = "INSERT",
			R = "REPLCE",
			c = "COMMND",
			r = "PROMPT",
			["!"] = "!SHELL",
			t = "TERMNL"
		},
		as_color = {
			n = "green",
			v = "lavender",
			V = "lavender",
			["\22"] =  "lavender", -- visual block
			s = "mauve",
			S = "mauve",
			["\19"] = "mauve",
			i = "yellow",
			R = "peach",
			c = "blue",
			r = "text",
			["!"] = "red",
			t = "red"
		}
	},
	update = {
        "ModeChanged",
		"WinEnter",
        callback = vim.schedule_wrap(function()
            vim.cmd.redrawstatus()
        end),
    },
}

local function diagnostic_component(severity)
	return {
		provider = function (self)
			local num = #vim.diagnostic.get(nil, { severity = severity })
			return num > 0 and ( self.formatting[severity].icon .. " " .. num .. "  " )
		end,
		hl = function (self) return self.formatting[severity].hl end
	}
end

local diagnostics = {
	static = {
		formatting = {
			[vim.diagnostic.severity.HINT]  = { icon = "", hl = "DiagnosticHint" },
			[vim.diagnostic.severity.INFO]  = { icon = "", hl = "DiagnosticInfo" },
			[vim.diagnostic.severity.WARN]  = { icon = "", hl = "DiagnosticWarn" },
			[vim.diagnostic.severity.ERROR] = { icon = "", hl = "DiagnosticError" }
		}
	},
	diagnostic_component(vim.diagnostic.severity.HINT),
	diagnostic_component(vim.diagnostic.severity.INFO),
	diagnostic_component(vim.diagnostic.severity.WARN),
	diagnostic_component(vim.diagnostic.severity.ERROR)
}

local lsp = {
	condition = c.lsp_attached,
	update = { "DiagnosticChanged", "LspAttach", "LspDetach" },
	provider = function ()
		local names = {}
        for i, server in pairs(vim.lsp.get_active_clients({ bufnr = 0 })) do
            table.insert(names, server.name)
        end
        return " LSP: [" .. table.concat(names, " ") .. "] "
	end,
	hl = { fg = "text", bg = "base", bold = true },
	diagnostics
}

local file_name = {
	provider = " %f %m",
	hl = { fg = "blue" }
}

local file_name_modifier = {
	hl = function ()
		if vim.bo.modified then
			return { bold = true, force = true }
		end
	end,
	file_name
}

local file_icon = {
	init = function (self)
		self.icon, self.icon_color = require('nvim-web-devicons').get_icon_color(self.ext, { default = true })
	end,
	provider = function (self) return self.icon end,
	hl = function (self) return { fg = self.icon_color } end
}

local current_file = {
	init = function (self)
		self.filename = vim.api.nvim_buf_get_name(0)
		self.ext = vim.fn.fnamemodify(self.filename, ":e")
	end,
	file_icon,
	file_name_modifier
}


local filetype = {
	provider = function (self)
		return " [" .. ternary(self.ft == "", "blank", self.ft) .. "] "
	end,
	update = { "WinEnter", "BufEnter" }
}

local file_encoding = {
	provider = function ()
		local enc = (vim.bo.fenc ~= '' and vim.bo.fenc) or vim.o.enc -- :h 'enc'
        return enc ~= 'utf-8' and enc:upper()
	end
}

local file_format = {
	provider = function()
        local fmt = vim.bo.fileformat
        return fmt ~= 'unix' and fmt:upper()
    end
}

local file_size = {
    provider = function()
        -- stackoverflow, compute human readable file size
        local suffix = { 'b', 'k', 'M', 'G', 'T', 'P', 'E' }
        local fsize = vim.fn.getfsize(vim.api.nvim_buf_get_name(0))
        fsize = (fsize < 0 and 0) or fsize
        if fsize < 1024 then
            return fsize..suffix[1]
        end
        local i = math.floor((math.log(fsize) / math.log(1024)))
        return string.format("%.2g%sB", fsize / math.pow(1024, i), suffix[i + 1])
    end
}

local file = {
	init = function (self)
		self.ft = vim.bo.filetype
		_, self.icon_color = require('nvim-web-devicons').get_icon_color_by_filetype(self.ft, { default = true })
	end,
	hl = function (self) return { fg = self.icon_color } end,
	update = { "FileType" },
	file_format,
	file_encoding,
	filetype,
	file_size,
}

local position = {
	provider = "%l/%L:%-2c %p%% ",
	hl = { fg = "rosewater" }
}

local scroll = {
	static = {
        sbar = { '🭶', '🭷', '🭸', '🭹', '🭺', '🭻' }
    },
    provider = function(self)
        local curr_line = vim.api.nvim_win_get_cursor(0)[1]
        local lines = vim.api.nvim_buf_line_count(0)
        local i = math.floor((curr_line - 1) / lines * #self.sbar) + 1
        return string.rep(self.sbar[i], 2)
    end,
    hl = { fg = "rosewater", bg = "base" },
}

local ruler = {
	position, scroll
}

local clock = {
	condition = function ()
		return c.is_active()
	end,
	provider = function (self)
		return os.date("%I:%M:%S")
	end,
	update = function (self)
		local new = os.time()
		if os.difftime(new, self.last) >= 1 then
			self.last = new
			return true
		end
		return false
	end,
	static = {
		last = os.time()
	}
}
local function refreshstatus()
	vim.cmd.redrawstatus()
	vim.defer_fn(refreshstatus, 1000)
end
refreshstatus()

--- @param char string
local function separator(char)
	return { provider = char }
end

local function with_adjacent(component, left, right)
	return {
		condition = component.condition,
		left,
		component,
		right
	}
end

local statusline = {
	mode,
	lsp,
	{ provider = "%=" },
	current_file,
	{ provider = "%<%=" },
	file,
	separator(" | "),
	ruler,
	with_adjacent(clock, separator(" | "), nil),
	hl = { bg = "mantle" }
}

local indices = { buf_to_index = {}, index_to_buf = {} }

_G.show_tabline = function ()
	vim.print(indices)
end

local function should_buffer_tabline(bufnr)
	return
		vim.api.nvim_buf_is_valid(bufnr) and
		vim.api.nvim_get_option_value("buftype", { buf = bufnr }) == ""
end

-- add already open buffers to tabline
do
	local bufs = vim.api.nvim_list_bufs()
	local index = 1
	for _, buf in ipairs(bufs) do
		if  vim.api.nvim_buf_is_loaded(buf) and
			should_buffer_tabline(buf) then
			table.insert(indices.index_to_buf, buf)
			indices.buf_to_index[buf] = index
			index = index + 1
		end
	end
end

vim.api.nvim_create_autocmd("BufCreate", {
	callback = function (args)
		if not args.buf then
			return
		end

		if should_buffer_tabline(args.buf) then
			table.insert(indices.index_to_buf, args.buf)

			local index = #indices.index_to_buf
			indices.buf_to_index[args.buf] = index
		end
	end
})

vim.api.nvim_create_autocmd("BufUnload", {
	callback = function(args)
		if not args.buf then
			return
		end

		local index = indices.buf_to_index[args.buf]
		if index then
			indices.buf_to_index[args.buf] = nil
			table.remove(indices.index_to_buf, index)
		end
	end
})

local function buffer_goto(index)
	local bufnr = indices.index_to_buf[index]
	if bufnr then
		vim.api.nvim_set_current_buf(bufnr)
	end
end

local function current_index()
	local current = vim.api.nvim_get_current_buf()
	return indices.buf_to_index[current]
end

local function buffer_swap(indexa, indexb)
	local bufa, bufb = indices.index_to_buf[indexa], indices.index_to_buf[indexb]
	if not (bufa and bufb) then
		return
	end

	indices.index_to_buf[indexa] = bufb
	indices.index_to_buf[indexb] = bufa
	indices.buf_to_index[bufa] = indexb
	indices.buf_to_index[bufb] = indexa
	vim.cmd.redrawtabline()
end

local function wrap(f, ...)
	local args = { ... }
	return function ()
		f(unpack(args))
	end
end

local function relative(f, v, ...)
	local args = { ... }
	return function ()
		local index = current_index()
		for i, arg in ipairs(args) do
			args[i] = index + arg
		end
		f(index + v, unpack(args))
	end
end

local map, _ = unpack(require('utils.map'))
map('n', '<A-,>', relative(buffer_goto, -1));
map('n', '<A-.>', relative(buffer_goto, 1))

map('n', '<C-[>', relative(buffer_swap, 0, -1))
map('n', '<C-]>', relative(buffer_swap, 0, 1))

map('n', 'db', '<Cmd>bdelete!<Cr>')
-- map('n', 'gp', '<Cmd>BufferPick<Cr>')
-- map('n', '<A-p>', '<Cmd>BufferPin<Cr>')

map('n', '<A-1>', wrap(buffer_goto, 1))
map('n', '<A-2>', wrap(buffer_goto, 2))
map('n', '<A-3>', wrap(buffer_goto, 3))
map('n', '<A-4>', wrap(buffer_goto, 4))
map('n', '<A-5>', wrap(buffer_goto, 5))
map('n', '<A-6>', wrap(buffer_goto, 6))
map('n', '<A-7>', wrap(buffer_goto, 7))
map('n', '<A-8>', wrap(buffer_goto, 8))
map('n', '<A-9>', wrap(buffer_goto, 9))
map('n', '<A-0>', wrap(buffer_goto, 10))

local TablineBufnr = {
    provider = function(self)
		local index = indices.buf_to_index[self.bufnr]
        return tostring(index or self.bufnr) .. ". "
    end,
    hl = "Comment",
}

-- we redefine the filename component, as we probably only want the tail and not the relative path
local TablineFileName = {
    provider = function(self)
        -- self.filename will be defined later, just keep looking at the example!
        local filename = self.filename
        filename = filename == "" and "[No Name]" or vim.fn.fnamemodify(filename, ":t")
        return " " .. filename
    end,
    hl = function(self)
        return { bold = self.is_active or self.is_visible, italic = true }
    end,
}

-- this looks exactly like the FileFlags component that we saw in
-- #crash-course-part-ii-filename-and-friends, but we are indexing the bufnr explicitly
-- also, we are adding a nice icon for terminal buffers.
local TablineFileFlags = {
    {
        condition = function(self)
            return vim.api.nvim_buf_get_option(self.bufnr, "modified")
        end,
        provider = " [+]",
        hl = { fg = "green" },
    },
    {
        condition = function(self)
            return not vim.api.nvim_buf_get_option(self.bufnr, "modifiable")
                or vim.api.nvim_buf_get_option(self.bufnr, "readonly")
        end,
        provider = function(self)
            if vim.api.nvim_buf_get_option(self.bufnr, "buftype") == "terminal" then
                return "  "
            else
                return ""
            end
        end,
        hl = { fg = "orange" },
    },
}

-- Here the filename block finally comes together
local TablineFileNameBlock = {
    init = function(self)
        self.filename = vim.api.nvim_buf_get_name(self.bufnr)
		self.ext = vim.fn.fnamemodify(self.filename, ":e")
    end,
    hl = function(self)
        if self.is_active then
            return "TabLineSel"
        -- why not?
        elseif self.is_visible then
            return { fg = "overlay0" }
        else
            return "TabLine"
        end
    end,
    on_click = {
        callback = function(_, minwid, _, button)
            if (button == "m") then -- close on mouse middle click
                vim.schedule(function()
                    vim.api.nvim_buf_delete(minwid, { force = false })
                end)
            else
                vim.api.nvim_win_set_buf(0, minwid)
            end
        end,
        minwid = function(self)
            return self.bufnr
        end,
        name = "heirline_tabline_buffer_callback",
    },
    TablineBufnr,
    file_icon,
    TablineFileName,
    TablineFileFlags,
}

-- a nice "x" button to close the buffer
local TablineCloseButton = {
    condition = function(self)
        return not vim.api.nvim_buf_get_option(self.bufnr, "modified")
    end,
    { provider = " " },
    {
        provider = "",
        hl = { fg = "gray" },
        on_click = {
            callback = function(_, minwid)
                vim.schedule(function()
                    vim.api.nvim_buf_delete(minwid, { force = false })
                    vim.cmd.redrawtabline()
                end)
            end,
            minwid = function(self)
                return self.bufnr
            end,
            name = "heirline_tabline_close_buffer_callback",
        },
    },
}

local TablineBufferBlock = u.surround({ "", "" }, function(self)
    if self.is_active then
        return u.get_highlight("TabLineSel").bg
    else
        return u.get_highlight("TabLine").bg
    end
end, { TablineFileNameBlock, TablineCloseButton })

local BufferLine = u.make_buflist(
    TablineBufferBlock,
    { provider = "", hl = { fg = "gray" } }, -- left truncation, optional (defaults to "<")
    { provider = "", hl = { fg = "gray" } }, -- right trunctation, also optional (defaults to ...... yep, ">")
	function () return indices.index_to_buf end,
	false
)

local tabline = {
	BufferLine
}

require('heirline').setup {
	statusline = statusline,
	winbar = {},
	tabline = tabline,
	opts = {
		disable_winbar_cb = function (args)
			return true
		end
	}
}

require('heirline').load_colors(require("catppuccin.palettes").get_palette("macchiato"))
