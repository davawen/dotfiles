vim.opt.shortmess:append({ I = true })

require("plugins")
require("mappings")
require("autocommands")
require("commands")
require("custom_cursor_hold")
require("lsp")

vim.g.man_hardwrap = true

vim.o.number = true
vim.o.relativenumber = true

vim.o.tabstop = 4     -- number of visual spaces per tab 
vim.o.softtabstop = 4 -- number of spaces in tab when editing
vim.o.shiftwidth = 4  -- number of spaces to use for autoindent

vim.o.mouse = "nvh"

vim.o.breakindent = true -- indent word wrapped lines as much as the parent line
vim.o.formatoptions = "l" -- ensures word-wrap doesn't split words
vim.o.lbr = true
vim.o.wrap = true
vim.o.splitright = true

vim.o.conceallevel = 0

vim.o.laststatus = 3
vim.o.showtabline = 2

vim.o.signcolumn = "number"

local map, _ = unpack(require("utils.map"))

-- Neovide config
vim.o.guifont = "Iosevka:h13.5"
vim.g.neovide_refresh_rate = 60
vim.g.neovide_cursor_animation_length = 0
vim.g.neovide_cursor_trail_size = 0
vim.g.neovide_cursor_animate_command_line = false
if vim.g.neovide then
	vim.g.neovide_input_use_logo = 1 -- enable use of the logo (cmd) key
	vim.keymap.set('v', '<D-c>', '"+y') -- Copy
	vim.keymap.set('n', '<D-v>', '"+P') -- Paste normal mode
	vim.keymap.set('v', '<D-v>', '"+P') -- Paste visual mode
	vim.keymap.set('c', '<D-v>', '<C-R>+') -- Paste command mode
	vim.keymap.set('i', '<C-S-V>', '<ESC>l"+Pla') -- Paste insert mode
end

vim.g.c_syntax_for_h = 1 -- Set *.h files to be c instead of cpp
vim.g.cursorhold_updatetime = 250

-- Set Highlights
local highlights = {
	CmpItemAbbrDeprecated = { bg = "NONE", strikethrough = true, fg = "#616E88" },
	CmpItemAbbrMatch = { bg = "NONE", fg = "#B48EAD" },
	CmpItemAbbrMatchFuzzy = { bg = "NONE", fg = "#B48EAD" },
	CmpItemKindVariable = { bg = "NONE", fg = "#81A1C1" },
	CmpItemKindClass = { bg = "NONE", fg = "#81A1C1" },
	CmpItemKindInterface = { bg = "NONE", fg = "#81A1C1" },
	CmpItemKindText = { bg = "NONE", fg = "#81A1C1" },
	CmpItemKindFunction = { bg = "NONE", fg = "#88C0D0" },
	CmpItemKindConstructor = { bg = "NONE", fg = "#88C0D0" },
	CmpItemKindMethod = { bg = "NONE", fg = "#88C0D0" },
	CmpItemKindKeyword = { bg = "NONE", fg = "#81A1C1" },
	CmpItemKindProperty = { bg = "NONE", fg = "#81A1C1" },
	CmpItemKindUnit = { bg = "NONE", fg = "#81A1C1" },
	CmpItemKindEnum = { bg = "NONE", fg = "#EBCB8B" },
	CmpItemKindEnumMember = { bg = "NONE", fg = "#EBCB8B" },
	CmpItemKindConstant = { bg = "NONE", fg = "#EBCB8B" },

	-- Use undercurls for warnings and lower
	DiagnosticUnderlineWarn = { undercurl = true, sp = "#eed49f" },
	DiagnosticUnderlineInfo = { undercurl = true, sp = "#91d7e3" },
	DiagnosticUnderlineHint = { undercurl = true, sp = "#8bd5ca" },

	LspDiagnosticUnderlineWarning = { undercurl = true, sp = "#eed49f" },
	LspDiagnosticUnderlineInformation = { undercurl = true, sp = "#91d7e3" },
	LspDiagnosticUnderlineHint = { undercurl = true, sp = "#8bd5ca" },

	-- Overwrite catpuccin fold
	Folded = { bg = "NONE", fg = "#6e738d" },

	-- Overwrite horrendous buffer line visible color
	TabLineSel = { bg = "#1e2030", fg = "#81a1c1" },
}

for group, values in pairs(highlights) do
	vim.api.nvim_set_hl(0, group, values)
end
