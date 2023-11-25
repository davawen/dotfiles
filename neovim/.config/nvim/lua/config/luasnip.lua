local ls = require('luasnip')

vim.keymap.set({"i"}, "<Tab>", function()
	if ls.expand_or_jumpable() then
		ls.expand_or_jump()
	else
		return "<Tab>"
	end
end, { silent = true, expr = true, replace_keycodes = true })

vim.keymap.set({"i", "s"}, "<S-Tab>", function()
	if ls.jumpable() then
		ls.jump(-1)
	else
		return "<S-Tab>"
	end
end, {silent = true, expr = true, replace_keycodes = true })

vim.keymap.set({"i", "s"}, "<C-E>", function()
	if ls.choice_active() then
		ls.change_choice(1)
	end
end, {silent = true})
