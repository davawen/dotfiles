-- Save current buffer using root privileges
-- Does not work with neovim currently
-- command W :execute ':silent w !sudo tee % > /dev/null' | :edit!

vim.cmd [[cnoreabbrev M vert Man]]

-- Creates a terminal in a right split
vim.api.nvim_create_user_command('Vte', 'vsplit | term', {})

-- Creates a terminal in a new tab
vim.api.nvim_create_user_command('Nte', 'tabnew | term', {})

-- Toggle hex editing
vim.api.nvim_create_user_command('Hex', require('hex').toggle, {})

vim.api.nvim_create_user_command('Save', function ()
	---@class string
	local pwd = vim.fn.getcwd()
	local escaped = pwd:gsub('/', "_")
	local saver_path = vim.fn.stdpath('state') .. "/saver/"

	vim.fn.mkdir(saver_path, "p")
	vim.cmd.cd{ saver_path, mods = { silent = true } }

	vim.cmd.mksession{ escaped, bang = true }
	vim.cmd.cd{ pwd, mods = { silent = true } }

	vim.notify("Saved session.", vim.log.levels.INFO);
end, {})

vim.api.nvim_create_user_command('Load', function ()
	---@class string
	local pwd = vim.fn.getcwd()
	local escaped = pwd:gsub('/', "_")

	local saver_path = vim.fn.stdpath('state') .. "/saver/"
	local file_path = saver_path .. escaped

	if vim.fn.filereadable(file_path) == 1 then
		vim.cmd.source(file_path)
		vim.cmd.cd{ pwd, mods = { silent = true } }

		vim.notify("Loaded session.", vim.log.levels.INFO);
	else
		vim.notify("Session doesn't exist.", vim.log.levels.INFO);
	end

end, {})

local term_id = nil
local old_id = nil
vim.api.nvim_create_user_command('Term', function ()
	if term_id == nil or not vim.api.nvim_buf_is_valid(term_id) then
		old_id = vim.api.nvim_get_current_buf()

		term_id = vim.api.nvim_create_buf(false, false)
		vim.api.nvim_set_current_buf(term_id)
		vim.fn.termopen("/usr/bin/fish")
		vim.api.nvim_feedkeys('i', 'n', false)
	else
		local current = vim.api.nvim_get_current_buf()
		if current ~= term_id then
			old_id = current
			vim.api.nvim_set_current_buf(term_id)
		vim.api.nvim_feedkeys('i', 'n', false)
		else
			if old_id == nil then
				old_id = vim.api.nvim_create_buf(true, false)
			end
			vim.api.nvim_set_current_buf(old_id)
		end
	end
end, {})
