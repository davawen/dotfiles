vim.g.do_filetype_lua = 1

vim.filetype.add({ extension = { dotvm = "dotvm" } })
vim.filetype.add({ extension = { bike = "bikelang" } })
vim.filetype.add({ extension = { wgsl = "wgsl" } })
vim.filetype.add({ extension = { mpp = "cpp", tpp = "cpp" } })
vim.filetype.add({ extension = { pest = "pest" } })
vim.filetype.add({ extension = { mypest = "mypest" } })
vim.filetype.add({ filename = { ['hyprland.conf'] = 'hyprconf' } })
-- vim.filetype.add({ pattern = { ['.*/waybar/config'] = 'json' } })
