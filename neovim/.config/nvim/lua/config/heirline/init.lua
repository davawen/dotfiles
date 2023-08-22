local c = require('heirline.conditions')
local u = require('heirline.utils')

--- @param modname string
local function reload(modname)
	package.loaded[modname] = nil
	return require(modname)
end

local statusline = reload('config.heirline.status')
local tabline = reload('config.heirline.tabline')

require('heirline').setup {
	statusline = statusline,
	winbar = {},
	tabline = tabline,
	opts = {
		disable_winbar_cb = function (_)
			return true
		end
	}
}

require('heirline').load_colors(require("catppuccin.palettes").get_palette("macchiato"))
