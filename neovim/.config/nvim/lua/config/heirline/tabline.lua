local c = require('heirline.conditions')
local u = require('heirline.utils')

local file_icon = require('config.heirline.file_icon')

local indices = { buf_to_index = {}, index_to_buf = {} }

_G.show_tabline = function ()
	vim.print(indices)
end

-- add already open buffers to tabline
do
	local bufs = vim.api.nvim_list_bufs()
	local index = 1
	for _, buf in ipairs(bufs) do
		if  vim.fn.buflisted(buf) == 1 then
			table.insert(indices.index_to_buf, buf)
			indices.buf_to_index[buf] = index
			index = index + 1
		end
	end
end

vim.api.nvim_create_autocmd("BufAdd", {
	callback = function (args)
		if not args.buf then
			return
		end

		if vim.fn.buflisted(args.buf) == 1 then
			table.insert(indices.index_to_buf, args.buf)

			local index = #indices.index_to_buf
			indices.buf_to_index[args.buf] = index

			vim.cmd.redrawtabline()
		end
	end
})

vim.api.nvim_create_autocmd("BufDelete", {
	callback = function(args)
		if not args.buf then
			return
		end

		local index = indices.buf_to_index[args.buf]
		if index then
			indices.buf_to_index[args.buf] = nil
			table.remove(indices.index_to_buf, index)

			vim.cmd.redrawtabline()
		end
	end
})

local function buffer_goto(index)
	local bufnr = indices.index_to_buf[index]
	if bufnr then
		vim.api.nvim_set_current_buf(bufnr)
		vim.cmd.redrawtabline()
	end
end

function _G.current_index()
	local current = vim.api.nvim_get_current_buf()
	return indices.buf_to_index[current]
end

local function buffer_swap(indexa, indexb)
	local bufa, bufb = indices.index_to_buf[indexa], indices.index_to_buf[indexb]
	if not (bufa and bufb) then
		return
	end

	indices.index_to_buf[indexa] = bufb
	indices.index_to_buf[indexb] = bufa
	indices.buf_to_index[bufa] = indexb
	indices.buf_to_index[bufb] = indexa
	vim.cmd.redrawtabline()
end

local function wrap(f, ...)
	local args = { ... }
	return function ()
		f(unpack(args))
	end
end

local map, _ = unpack(require('utils.map'))
map('n', '<A-,>', function() buffer_goto(current_index()-1) end);
map('n', '<A-.>', function() buffer_goto(current_index()+1) end)

map('n', '<C-[>', function() buffer_swap(current_index(), current_index()-1) end)
map('n', '<C-]>', function() buffer_swap(current_index(), current_index()+1) end )

map('n', 'db', '<Cmd>bdelete!<Cr>')
-- map('n', '<A-p>', '<Cmd>BufferPin<Cr>')

map('n', '<A-1>', wrap(buffer_goto, 1))
map('n', '<A-2>', wrap(buffer_goto, 2))
map('n', '<A-3>', wrap(buffer_goto, 3))
map('n', '<A-4>', wrap(buffer_goto, 4))
map('n', '<A-5>', wrap(buffer_goto, 5))
map('n', '<A-6>', wrap(buffer_goto, 6))
map('n', '<A-7>', wrap(buffer_goto, 7))
map('n', '<A-8>', wrap(buffer_goto, 8))
map('n', '<A-9>', wrap(buffer_goto, 9))
map('n', '<A-0>', wrap(buffer_goto, 10))

local TablineBufnr = {
    provider = function(self)
		local index = indices.buf_to_index[self.bufnr]
        return tostring(index or self.bufnr) .. ". "
    end,
    hl = "Comment",
}

-- we redefine the filename component, as we probably only want the tail and not the relative path
local TablineFileName = {
    provider = function(self)
        -- self.filename will be defined later, just keep looking at the example!
        local filename = self.filename
        filename = filename == "" and "[No Name]" or vim.fn.fnamemodify(filename, ":t")
        return " " .. filename
    end,
    hl = function(self)
        return { bold = self.is_active or self.is_visible, italic = true }
    end,
}

-- this looks exactly like the FileFlags component that we saw in
-- #crash-course-part-ii-filename-and-friends, but we are indexing the bufnr explicitly
-- also, we are adding a nice icon for terminal buffers.
local TablineFileFlags = {
    {
        condition = function(self)
            return vim.api.nvim_buf_get_option(self.bufnr, "modified")
        end,
        provider = " [+]",
        hl = { fg = "green" },
    },
    {
        condition = function(self)
            return not vim.api.nvim_buf_get_option(self.bufnr, "modifiable")
                or vim.api.nvim_buf_get_option(self.bufnr, "readonly")
        end,
        provider = function(self)
            if vim.api.nvim_buf_get_option(self.bufnr, "buftype") == "terminal" then
                return "  "
            else
                return ""
            end
        end,
        hl = { fg = "orange" },
    },
}

-- Here the filename block finally comes together
local TablineFileNameBlock = {
    init = function(self)
        self.filename = vim.api.nvim_buf_get_name(self.bufnr)
		self.ext = vim.fn.fnamemodify(self.filename, ":e")
    end,
    hl = function(self)
        if self.is_active then
            return "TabLineSel"
        elseif self.is_visible then
            return { fg = "overlay0" }
        else
            return "TabLine"
        end
    end,
    on_click = {
        callback = function(_, minwid, _, button)
            if (button == "m") then -- close on mouse middle click
                vim.schedule(function()
                    vim.api.nvim_buf_delete(minwid, { force = false })
                end)
            else
                vim.api.nvim_win_set_buf(0, minwid)
            end
        end,
        minwid = function(self)
            return self.bufnr
        end,
        name = "heirline_tabline_buffer_callback",
    },
    TablineBufnr,
    file_icon,
    TablineFileName,
    TablineFileFlags,
}

-- a nice "x" button to close the buffer
local TablineCloseButton = {
    condition = function(self)
        return not vim.api.nvim_buf_get_option(self.bufnr, "modified")
    end,
    { provider = " " },
    {
        provider = "",
        hl = { fg = "gray" },
        on_click = {
            callback = function(_, minwid)
                vim.schedule(function()
                    vim.api.nvim_buf_delete(minwid, { force = false })
                    vim.cmd.redrawtabline()
                end)
            end,
            minwid = function(self)
                return self.bufnr
            end,
            name = "heirline_tabline_close_buffer_callback",
        },
    },
}

local TablineBufferBlock = u.surround({ "", "" }, function(self)
    if self.is_active then
        return u.get_highlight("TabLineSel").bg
    else
        return u.get_highlight("TabLine").bg
    end
end, { TablineFileNameBlock, TablineCloseButton })

local BufferLine = u.make_buflist(
    TablineBufferBlock,
    { provider = "", hl = { fg = "gray" } }, -- left truncation, optional (defaults to "<")
    { provider = "", hl = { fg = "gray" } }, -- right trunctation, also optional (defaults to ...... yep, ">")
	function () return indices.index_to_buf end,
	false
)

return {
	BufferLine
}
