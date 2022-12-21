vim.g.mapleader = ";"
map = vim.keymap.set
function remap(mode, key, value)
	map(mode, key, value, {
		remap = true
	})
end

-- Force h j k l
map("n", "<Left>", "<nop>")
map("n", "<Right>", "<nop>")
map("n", "<Up>", "<nop>")
map("n", "<Down>", "<nop>")

-- Space opens command menu
map("n", "<space>", ":")

-- Force <c-c> for escape
map("i", "<C-c>", "<esc>")
map("i", "<C-v>", "<esc>")

-- Fix weird issue with barbar.nvim
map("n", "<esc>", "<esc>")

-- Avoid yanking replaced text
map("v", "p", '"_dP')

-- ;; add semicolon at the end of the line
map("n", "<leader>;", "mpA;<esc>`p")

-- ;s cycles through unnamed and clipboard registers
map("n", "<Leader>s", ':let @z=@" | let @"=@+ | let @+=@z<CR>')

-- Open floating terminal
map("n", "<leader>te", "<Cmd>FloatermToggle<Cr>")
remap("t", "<leader>te", "<Esc><leader>te")
remap("t", "<leader>th", "<Esc><Cmd>FloatermPrev<Cr>")
remap("t", "<leader>tl", "<Esc><Cmd>FloatermNext<Cr>")
remap("t", "<leader>tn", "<Esc><Cmd>FloatermNew<Cr>")

-- ctrl-u uppercases a word
map("i", "<c-u>", "<esc>viwUea")

-- Escape to quit terminal
map("t", "<esc>", "<C-\\><C-n>")

-- Quick return to line
map("n", "d,", "^d0kJ")

-- Telescope mappings
local telescope = require('telescope.builtin')
map("n", "<leader>ff", telescope.find_files)
map("n", "<leader>fs", telescope.lsp_document_symbols)
map("n", "<leader>fr", telescope.lsp_references)
map("n", "<leader>n", "<Cmd>Neotree source=filesystem reveal position=float toggle<CR>")
map("n", "<leader>b", "<Cmd>Neotree source=buffers reveal position=float toggle<CR>")
-- Use ;ev to open config directory
local function open_config()
	-- Open over startup page if it is opened
	if vim.bo.filetype ~= 'startup' then
		vim.cmd [[exe "normal! \<Cmd>vsp\<Cr>\<C-w>l"]]
	end
	telescope.find_files({
		cwd = "~/.config/nvim"
	})
end
map("n", "<leader>ev", open_config)


map("n", "<leader><left>", "<c-w>h")
map("n", "<leader><right>", "<c-w>l")
map("n", "<leader><up>", "<c-w>k")
map("n", "<leader><down>", "<c-w>j")

map("n", "<leader>h", "<c-w>h")
map("n", "<leader>l", "<c-w>l")
map("n", "<leader>k", "<c-w>k")
map("n", "<leader>j", "<c-w>j")

-- vim-easy-align
-- Start interactive EasyAlign in visual mode (e.g. vipga)
map("x", "ga", "<Plug>(EasyAlign)")
-- Start interactive EasyAlign for a motion/text object (e.g. gaip)
map("n", "ga", "<Plug>(EasyAlign)")

