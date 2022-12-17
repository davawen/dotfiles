-- Save current buffer using root privileges
-- Does not work with neovim currently
-- command W :execute ':silent w !sudo tee % > /dev/null' | :edit!

-- Creates a terminal in a right split
vim.api.nvim_create_user_command('Vte', 'vsplit | execute "normal! \\<c-w>l" | term', {})

-- Creates a terminal in a new tab
vim.api.nvim_create_user_command('Nte', 'tabnew | term', {})

-- Creates a terminal in a split and executes a command in it
vim.api.nvim_create_user_command('Sh', 'FloatermNew --wintype=split --position=botright --width=1.0 --height=0.5 <args>', {})
