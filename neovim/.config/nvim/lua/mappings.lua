vim.g.mapleader = ";"

local map, remap = unpack(require("utils.map"))

--- Returns a new function wich calls the given function with the given arguments
---@param fn function
---@param args any[]
---@return function
local function fn_args(fn, args)
	return function()
		fn(unpack(args))
	end
end

-- Force h j k l
map("n", "<Left>", "<nop>")
map("n", "<Right>", "<nop>")
map("n", "<Up>", "<nop>")
map("n", "<Down>", "<nop>")

-- Make j and k move by visible line for wrapped lines
map("n", "j", "gj")
map("n", "k", "gk")
map("n", "gj", "j")
map("n", "gk", "k")

-- Since leader key is ;, make \ be repetition
map("n", "\\", ";")

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

-- ;c cycles through unnamed and clipboard registers
map("n", "<leader>cb", ':let @z=@" | let @"=@+ | let @+=@z<CR>')

-- Open floating terminal
map("n", "<leader>te", "<Cmd>FloatermToggle<Cr>")
remap("t", "<leader>te", "<C-\\><leader>te")
remap("t", "<leader>th", "<C-\\><Cmd>FloatermPrev<Cr>")
remap("t", "<leader>tl", "<C-\\><Cmd>FloatermNext<Cr>")
remap("t", "<leader>tn", "<C-\\><Cmd>FloatermNew<Cr>")

-- ctrl-u uppercases a word
map("i", "<c-u>", "<esc>viwUea")

-- C-\ to quit terminal
map("t", "<C-\\>", "<C-\\><C-n>")

-- Quick return to line
map("n", "d,", "^d0kJ")

-- Select pasted text
map("n", "gs", "`[v`]")

-- Wrap selection in braces and break lines
map("v", "<leader>S", [[di{<CR><CR>}<ESC>k"_Sx<ESC>p^x$]])

-- Telescope mappings
local telescope = require('telescope.builtin')
map("n", "<leader>ff", telescope.find_files)
map("n", "<leader>fw", telescope.lsp_workspace_symbols)
map("n", "<leader>fs", telescope.lsp_document_symbols)
map("n", "<leader>fr", telescope.lsp_references)
map("n", "<leader>fk", telescope.keymaps)
map("n", "<leader>fh", telescope.help_tags)
map("n", "<leader>fg", telescope.live_grep)
map("n", "<leader>fd", telescope.diagnostics)
map("n", "<leader>fb", telescope.buffers)

-- Neotree mappings
map("n", "<leader>nf", "<Cmd>Neotree source=filesystem position=float focus<CR>")
map("n", "<leader>nb", "<Cmd>Neotree source=buffers position=float focus<CR>")
map("n", "<leader>ns", "<Cmd>Neotree source=document_symbols position=float focus<CR>")

-- Open config
map("n", "<leader>evs", fn_args(telescope.live_grep, {{ cwd = "~/.config/nvim" }}))
map("n", "<leader>evv", fn_args(telescope.find_files, {{ cwd = "~/.config/nvim" }}))

map("n", "<leader><left>", "<c-w>h")
map("n", "<leader><right>", "<c-w>l")
map("n", "<leader><up>", "<c-w>k")
map("n", "<leader><down>", "<c-w>j")

map("n", "<leader>h", "<c-w>h")
map("n", "<leader>l", "<c-w>l")
map("n", "<leader>k", "<c-w>k")
map("n", "<leader>j", "<c-w>j")

-- wiki.vim mappings
map("n", "<leader>wf", "<plug>(wiki-pages)")

-- vim-easy-align
-- Start interactive EasyAlign in visual mode (e.g. vipga)
map("x", "ga", "<Plug>(EasyAlign)")
-- Start interactive EasyAlign for a motion/text object (e.g. gaip)
map("n", "ga", "<Plug>(EasyAlign)")

