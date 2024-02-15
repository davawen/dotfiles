local c = require('heirline.conditions')
local u = require('heirline.utils')

local file_icon = require('config.heirline.file_icon')

local indices = { buf_to_index = {}, index_to_buf = {} }

---@param b boolean
---@param v1 any
---@param v2 any
local function ternary(b, v1, v2)
	if b then return v1 else return v2 end
end

show_bufferline = function ()
	vim.print(indices)
end

local function valid_buffer(bufnr)
	return vim.fn.buflisted(bufnr) == 1 and (vim.bo[bufnr].buftype == "" or vim.bo[bufnr].buftype == "terminal")
end

-- add already open buffers to tabline
do
	local bufs = vim.api.nvim_list_bufs()
	local index = 1
	for _, bufnr in ipairs(bufs) do
		if valid_buffer(bufnr) then
			table.insert(indices.index_to_buf, bufnr)
			indices.buf_to_index[bufnr] = index
			index = index + 1
		end
	end
end

local function remove_buffer(bufnr)
	local index = indices.buf_to_index[bufnr]
	if index then
		indices.buf_to_index[bufnr] = nil
		table.remove(indices.index_to_buf, index)
		local num = #indices.index_to_buf
		for i = index, num do -- sync buffer list
			local buf = indices.index_to_buf[i]
			indices.buf_to_index[buf] = i
		end
		vim.cmd.redrawtabline()
	end
end

vim.api.nvim_create_autocmd("BufAdd", {
	callback = function (args)
		if not args.buf then
			return
		end

		if valid_buffer(args.buf) then
			local index = (current_index() or #indices.index_to_buf) + 1

			table.insert(indices.index_to_buf, index, args.buf)

			indices.buf_to_index[args.buf] = index

			for i = index+1, #indices.index_to_buf do
				local bufnr = indices.index_to_buf[i]
				indices.buf_to_index[bufnr] = i
			end

			-- if a buffer gets added that shouldn't be (because of voodoo timing shit), remove it
			vim.defer_fn(function ()
				if not valid_buffer(args.buf) then
					remove_buffer(args.buf)
				end
			end, 150)

			vim.cmd.redrawtabline()
		end
	end
})

vim.api.nvim_create_autocmd("BufDelete", {
	callback = function(args)
		if not args.buf then
			return
		end

		remove_buffer(args.buf)
	end
})

local function buffer_goto(index)
	local bufnr = indices.index_to_buf[index]
	if bufnr then
		vim.api.nvim_set_current_buf(bufnr)
		vim.cmd.redrawtabline()
	end
end

function current_pos()
	local current = vim.api.nvim_get_current_buf()
	return {
		bufnr = current,
		index = indices.buf_to_index[current]
	}
end

function current_index()
	return current_pos().index
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
map('n', '<A-,>', function() buffer_goto((current_index() or #indices.index_to_buf+1)-1) end);
map('n', '<A-.>', function() buffer_goto((current_index() or 0)+1) end)

map('n', '<C-[>', function() buffer_swap(current_index(), current_index()-1) end)
map('n', '<C-]>', function() buffer_swap(current_index(), current_index()+1) end )

map('n', 'db', function ()
	local pos = current_pos()
	local num = #indices.index_to_buf

	if pos.index == num and num > 1 then -- if there no buffer after, set to last buffer
		buffer_goto(pos.index-1)
	elseif num > 1 then
		buffer_goto(pos.index+1)
	end

	local opts = {}
	if vim.api.nvim_buf_get_name(pos.bufnr) == "" then -- anonymous buffer
		opts.force = true
	end
	vim.api.nvim_buf_delete(pos.bufnr, opts)
end)
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

local BufferlineBufnr = {
    provider = function(self)
		local index = indices.buf_to_index[self.bufnr]
        return tostring(index or self.bufnr) .. ". "
    end,
    hl = "Comment",
}

-- we redefine the filename component, as we probably only want the tail and not the relative path
local BufferlineFileName = {
    provider = function(self)
        -- self.filename will be defined later, just keep looking at the example!
        local filename = self.filename
        local short_name = filename == "" and "[No Name]" or vim.fn.fnamemodify(filename, ":t")
		if short_name == "mod.rs" then
			short_name = vim.fn.fnamemodify(filename, ":h:t") .. "/mod.rs"
		end
        return " " .. short_name
    end,
    hl = function(self)
        return { bold = self.is_active or self.is_visible, italic = true }
    end,
}

-- this looks exactly like the FileFlags component that we saw in
-- #crash-course-part-ii-filename-and-friends, but we are indexing the bufnr explicitly
-- also, we are adding a nice icon for terminal buffers.
local BufferlineFileFlags = {
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
local BufferlineFileNameBlock = {
    init = function(self)
        self.filename = vim.api.nvim_buf_get_name(self.bufnr)
		self.ext = vim.fn.fnamemodify(self.filename, ":e")
		self.filetype = vim.bo[self.bufnr].filetype
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
    BufferlineBufnr,
    file_icon,
    BufferlineFileName,
    BufferlineFileFlags,
}

-- a nice "x" button to close the buffer
local BufferlineCloseButton = {
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

local BufferlineBufferBlock = u.surround({ "", "" }, function(self)
    if self.is_active then
        return u.get_highlight("TabLineSel").bg
    else
        return u.get_highlight("TabLine").bg
    end
end, { BufferlineFileNameBlock, BufferlineCloseButton })

local BufferList = u.make_buflist(
    BufferlineBufferBlock,
    { provider = "", hl = { fg = "gray" } }, -- left truncation, optional (defaults to "<")
    { provider = "", hl = { fg = "gray" } }, -- right trunctation, also optional (defaults to ...... yep, ">")
	function () return indices.index_to_buf end,
	false
)

local tablist_component = {
	provider = function (self)
		return " " .. self.tabnr .. " "
	end,
	hl = function (self)
		return { fg = ternary(self.is_active, "rosewater", "gray"), bg = "mantle" }
	end
}

local tablist = u.make_tablist(tablist_component)

return {
	BufferList,
	{ provider = "%=" },
	tablist
}
