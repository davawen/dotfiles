local autocmd = vim.api.nvim_create_autocmd

autocmd("FileType", {
	pattern = "vim",
	callback = function()
		vim.cmd [[setlocal wrap foldmethod=marker]]
	end
})
autocmd("FileType", {
	pattern = "*",
	callback = function()
		vim.cmd [[setlocal formatoptions-=c formatoptions-=r formatoptions-=o]]
	end
})

autocmd("BufReadPost", {
	pattern = "*",
	callback = function()
		vim.cmd [[if line("\'"") > 0 && line("\'"") <= line("$") | exe "normal! g`"zz" | endif]]
	end
})

