-- Save current buffer using root privileges
-- Does not work with neovim currently
-- command W :execute ':silent w !sudo tee % > /dev/null' | :edit!

-- Creates a terminal in a right split
vim.api.nvim_create_user_command('Vte', 'vsplit | execute "normal! \\<c-w>l" | term', {})

-- Creates a terminal in a new tab
vim.api.nvim_create_user_command('Nte', 'tabnew | term', {})

-- Creates a terminal in a split and executes a command in it
vim.api.nvim_create_user_command('Sh', 'FloatermNew --wintype=split --position=botright --width=1.0 --height=0.5 <args>', {})

vim.api.nvim_create_user_command('Save', function ()
	---@class string
	local pwd = vim.fn.getcwd()
	local escaped = pwd:gsub('/', "_")

	vim.fn.mkdir(vim.fn.expand("~/.local/state/nvim/saver/"), "p")
	vim.cmd [[ cd ~/.local/state/nvim/saver/ ]]

	vim.cmd [[ mksession! ]]
	vim.cmd([[ call rename("Session.vim", "]] .. escaped .. [[") ]])
	vim.cmd([[ cd ]] .. pwd)
end, {})

vim.api.nvim_create_user_command('Load', function ()
	---@class string
	local pwd = vim.fn.getcwd()
	local escaped = pwd:gsub('/', "_")

	vim.cmd([[ so ~/.local/state/nvim/saver/]] .. escaped)
	vim.cmd([[ cd ]] .. pwd)
end, {})
