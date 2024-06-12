local c = require('heirline.conditions')
local u = require('heirline.utils')

---@param b boolean
---@param v1 any
---@param v2 any
local function ternary(b, v1, v2)
	if b then return v1 else return v2 end
end

--- Sets the default stauts line background in the hl if it is not set
local function with_default_bg(hl)
	if type(hl) == "table" then
		if not hl.bg then
			hl.bg = u.get_highlight("StatusLine").bg
		end
	end
	return hl
end

local function left_incline(hl)
	return { provider = "", hl = function () return with_default_bg(hl) end }
end
local function right_incline(hl)
	return { provider = "", hl = function () return with_default_bg(hl) end }
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
	right_incline { reverse = false }
}

local git = {
    condition = c.is_git_repo,
	update = { "User",
		pattern = "GitSignsUpdate"
	},

    init = function(self)
        self.status_dict = vim.b.gitsigns_status_dict
        self.has_changes = self.status_dict.added ~= 0 or self.status_dict.removed ~= 0 or self.status_dict.changed ~= 0
    end,

    hl = { fg = "sapphire", bg = "surface1" },


	left_incline { fg = "surface1" },
    {   -- git branch name
        provider = function(self)
            return " " .. self.status_dict.head
        end,
        hl = { bold = true }
    },
    -- You could handle delimiters, icons and counts similar to Diagnostics
    {
        condition = function(self)
            return self.has_changes
        end,
        provider = "["
    },
    {
        provider = function(self)
            local count = self.status_dict.added or 0
            return count > 0 and ("+" .. count)
        end,
        hl = { fg = "green" },
    },
    {
        provider = function(self)
            local count = self.status_dict.removed or 0
            return count > 0 and ("-" .. count)
        end,
        hl = { fg = "red" },
    },
    {
        provider = function(self)
            local count = self.status_dict.changed or 0
            return count > 0 and ("~" .. count)
        end,
        hl = { fg = "blue" },
    },
    {
        condition = function(self)
            return self.has_changes
        end,
        provider = "]",
    },
	right_incline { fg = "surface1" }
}

local function diagnostic_component(severity)
	return {
		provider = function (self)
			local num = #vim.diagnostic.get(nil, { severity = severity })
			return num > 0 and ( self.formatting[severity].icon .. num ) .. " "
		end,
		hl = function (self) return self.formatting[severity].hl end
	}
end

local diagnostics = {
	condition = function ()
		return #vim.diagnostic.get(nil) > 0
	end,
	static = {
		formatting = {
			[vim.diagnostic.severity.HINT]  = { icon = " ", hl = "DiagnosticHint" },
			[vim.diagnostic.severity.INFO]  = { icon = " ", hl = "DiagnosticInfo" },
			[vim.diagnostic.severity.WARN]  = { icon = " ", hl = "DiagnosticWarn" },
			[vim.diagnostic.severity.ERROR] = { icon = " ", hl = "DiagnosticError" }
		}
	},
	left_incline { fg = "surface0" },
	{
		hl = { bg = "surface0" },
		{ provider = " " },
		diagnostic_component(vim.diagnostic.severity.HINT),
		diagnostic_component(vim.diagnostic.severity.INFO),
		diagnostic_component(vim.diagnostic.severity.WARN),
		diagnostic_component(vim.diagnostic.severity.ERROR),
	},
	right_incline { fg = "surface0" },
}

local lsp_name = {
	provider = function ()
		local names = {}
        for _, server in pairs(vim.lsp.get_active_clients({ bufnr = 0 })) do
            table.insert(names, server.name)
        end
        return "[" .. table.concat(names, " ") .. "] "
	end,
	hl = { fg = "subtext0", bold = true }
}

local navic = require("nvim-navic")
local navic_context = {
	condition = c.lsp_attached(),
	provider = navic.get_location
}

local lsp = {
	condition = c.lsp_attached,
	update = { "CursorMoved", "DiagnosticChanged", "LspAttach", "LspDetach" },
	u.surround({ "", "" }, "surface0", lsp_name),
	diagnostics,
	{ provider = " " },
	navic_context
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

local file_icon = require('config.heirline.file_icon')

local current_file = {
	init = function (self)
		self.filename = vim.api.nvim_buf_get_name(0)
		self.ext = vim.fn.fnamemodify(self.filename, ":e")
		self.filetype = vim.bo.filetype
	end,
	file_icon,
	file_name_modifier
}


local filetype = {
	provider = function (self)
		return " [" .. ternary(self.ft == "", "blank", self.ft) .. "] "
	end
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
	update = { "BufEnter", "WinEnter", "FileType" },
	file_format,
	file_encoding,
	filetype,
	file_size,
}

local position = {
	provider = "%3l/%L:%-2c %3p%% ",
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
	provider = function (_)
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


local function with_adjacent(component, left, right)
	return {
		condition = component.condition,
		left,
		component,
		right
	}
end

return {
	mode,
	git,
	lsp,
	{ provider = "%=" },
	current_file,
	file,
	{ provider = " | " },
	ruler,
	with_adjacent(clock, { provider = " | " }, nil),
	hl = { bg = "mantle" }
}

