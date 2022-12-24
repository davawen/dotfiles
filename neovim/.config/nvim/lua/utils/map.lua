local map = vim.keymap.set
local function remap(mode, key, value)
	map(mode, key, value, {
		remap = true
	})
end

return { map, remap }
