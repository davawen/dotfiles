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
		lualine_a = { 'mode' },
		lualine_b = { 'branch', 'diagnostics', 'diff' },
		lualine_c = { "filename", signature_help },
		lualine_x = { 'location', 'filetype' },
		lualine_y = { 'os.date("%I:%M:%S", os.time())' },
		lualine_z = {}
	}
})
