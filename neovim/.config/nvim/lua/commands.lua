-- Save current buffer using root privileges
-- Does not work with neovim currently
-- command W :execute ':silent w !sudo tee % > /dev/null' | :edit!

vim.cmd [[cnoreabbrev M vert Man]]

-- Creates a terminal in a right split
vim.api.nvim_create_user_command('Vte', 'vsplit | term', {})

-- Creates a terminal in a new tab
vim.api.nvim_create_user_command('Nte', 'tabnew | term', {})

-- Creates a terminal in a split and executes a command in it
vim.api.nvim_create_user_command('Sh', 'FloatermNew --wintype=split --position=botright --width=1.0 --height=0.5 <args>', {})

vim.api.nvim_create_user_command('Save', function ()
	---@class string
	local pwd = vim.fn.getcwd()
	local escaped = pwd:gsub('/', "_")
	local saver_path = vim.fn.stdpath('state') .. "/saver/"

	vim.fn.mkdir(saver_path, "p")
	vim.cmd.cd{ saver_path, mods = { silent = true } }

	vim.cmd.mksession{ escaped, bang = true }
	vim.cmd.cd{ pwd, mods = { silent = true } }
end, {})

vim.api.nvim_create_user_command('Load', function ()
	---@class string
	local pwd = vim.fn.getcwd()
	local escaped = pwd:gsub('/', "_")

	local saver_path = vim.fn.stdpath('state') .. "/saver/"

	vim.cmd.source(saver_path .. escaped)
	vim.cmd.cd{ pwd, mods = { silent = true } }
end, {})
