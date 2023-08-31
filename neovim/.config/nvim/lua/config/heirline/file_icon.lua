
--- Expects a property self.ext
return {
	init = function (self)
		self.icon, self.icon_color = require('nvim-web-devicons')
			.get_icon_color(self.ext, { default = true })
	end,
	provider = function (self) return self.icon end,
	hl = function (self) return { fg = self.icon_color } end
}
