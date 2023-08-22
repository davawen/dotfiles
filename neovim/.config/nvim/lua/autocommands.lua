local autocmd = vim.api.nvim_create_autocmd

_G.augroup = vim.api.nvim_create_augroup("MyGroup", {})

autocmd("FileType", {
	pattern = "vim",
	callback = function()
		vim.cmd [[setlocal wrap foldmethod=marker]]
	end,
	group = augroup
})
autocmd("FileType", {
	pattern = "*",
	callback = function()
		vim.cmd [[setlocal formatoptions-=c formatoptions-=r formatoptions-=o]]
	end,
	group = augroup
})

autocmd("BufReadPost", {
	pattern = "*",
	callback = function()
		vim.cmd [[if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g`\"zz" | endif]]
	end,
	group = augroup
})


-- vim.api.nvim_create_autocmd("BufNew", {
-- 	pattern = { "*/.config/nvim/*" },
-- 	callback = function()
-- 		vim.bo.foldlevel = 2
-- 	end,
-- 	group = augroup
-- })
