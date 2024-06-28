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

do
	-- declare local variables
	--// exportstring( string )
	--// returns a "Lua" portable version of the string
	local function exportstring( s )
		return string.format("%q", s)
	end

	--// The Save Function
	function table.save(  tbl,filename )
		local charS,charE = "   ","\n"
		local file, err = io.open( filename, "wb" )
		if err then return err end
		if file == nil then return end

		-- initiate variables for save procedure
		local tables,lookup = { tbl },{ [tbl] = 1 }
		file:write( "return {"..charE )

		for idx,t in ipairs( tables ) do
			file:write( "-- Table: {"..idx.."}"..charE )
			file:write( "{"..charE )
			local thandled = {}

			for i,v in ipairs( t ) do
				thandled[i] = true
				local stype = type( v )
				-- only handle value
				if stype == "table" then
					if not lookup[v] then
						table.insert( tables, v )
						lookup[v] = #tables
					end
					file:write( charS.."{"..lookup[v].."},"..charE )
				elseif stype == "string" then
					file:write(  charS..exportstring( v )..","..charE )
				elseif stype == "number" then
					file:write(  charS..tostring( v )..","..charE )
				end
			end

			for i,v in pairs( t ) do
				-- escape handled values
				if (not thandled[i]) then

					local str = ""
					local stype = type( i )
					-- handle index
					if stype == "table" then
						if not lookup[i] then
							table.insert( tables,i )
							lookup[i] = #tables
						end
						str = charS.."[{"..lookup[i].."}]="
					elseif stype == "string" then
						str = charS.."["..exportstring( i ).."]="
					elseif stype == "number" then
						str = charS.."["..tostring( i ).."]="
					end

					if str ~= "" then
						stype = type( v )
						-- handle value
						if stype == "table" then
							if not lookup[v] then
								table.insert( tables,v )
								lookup[v] = #tables
							end
							file:write( str.."{"..lookup[v].."},"..charE )
						elseif stype == "string" then
							file:write( str..exportstring( v )..","..charE )
						elseif stype == "number" then
							file:write( str..tostring( v )..","..charE )
						end
					end
				end
			end
			file:write( "},"..charE )
		end
		file:write( "}" )
		file:close()
	end

	--// The Load Function
	function table.load( sfile )
		local ftables,err = loadfile( sfile )
		if err then return _,err end
		local tables = ftables()
		for idx = 1,#tables do
			local tolinki = {}
			for i,v in pairs( tables[idx] ) do
				if type( v ) == "table" then
					tables[idx][i] = tables[v[1]]
				end
				if type( i ) == "table" and tables[i[1]] then
					table.insert( tolinki,{ i,tables[i[1]] } )
				end
			end
			-- link indices
			for _,v in ipairs( tolinki ) do
				tables[idx][v[2]],tables[idx][v[1]] =  tables[idx][v[1]],nil
			end
		end
		return tables[1]
	end
	-- close do
end

function Save_window_state()
	--- @param t table
	--- @param i integer
	local function swap_remove(t, i)
		local n = #t
		t[i] = t[n]
		table.remove(t, n)
	end

	local function equals(a, b)
		return a[1] == b[1] and a[2] == b[2]
	end

	--- @class Window
	--- @field leaf true
	--- @field buf integer
	--- @field x integer
	--- @field y integer
	--- @field w integer
	--- @field h integer

	--- @class Split
	--- @field leaf false
	--- @field left Split|Window
	--- @field right Split|Window
	--- @field horizontal boolean
	--- @field x integer
	--- @field y integer
	--- @field w integer
	--- @field h integer

	local window_ids = vim.api.nvim_tabpage_list_wins(0)

	--- @type (Window|Split)[]
	local windows = {}
	for _, id in ipairs(window_ids) do
		local buf = vim.api.nvim_win_get_buf(id)
		if vim.api.nvim_win_is_valid(id) and vim.api.nvim_buf_is_loaded(buf) then
			-- pos is [row, col]
			local pos = vim.api.nvim_win_get_position(id)
			local w = vim.api.nvim_win_get_width(id)
			local h = vim.api.nvim_win_get_height(id)

			local window = {
				leaf = true,
				buf = buf,
				x = pos[2],
				y = pos[1],
				w = w,
				h = h
			}

			vim.print(window)

			table.insert(windows, window)
		end
	end

	repeat
		local no_merge = true

		for i, w1 in ipairs(windows) do
			for j, w2 in ipairs(windows) do
				if i == j then goto continue end

				local tr1 = { w1.x + w1.w + 1, w1.y }
				local br1 = { w1.x + w1.w + 1, w1.y + w1.h }

				local tl2 = { w2.x, w2.y }
				local bl2 = { w2.x, w2.y + w2.h }

				if equals(tr1, tl2) and equals(br1, bl2) then
					-- horizontal split 
					swap_remove(windows, i)
					swap_remove(windows, j)

					local tree = {
						leaf = false,
						left = w1,
						right = w2,
						horizontal = true,
						x = w1.x,
						y = w1.y,
						w = w1.w + 1 + w2.w,
						h = w1.h
					}

					table.insert(windows, tree)

					vim.print("got horizontal split, merging ", i, " and ", j)
					no_merge = false
					goto merge
				end

				local bl1 = { w1.x, w1.y + w1.h + 1 }
				local br1 = { w1.x + w1.w, w1.y + w1.h + 1 }

				local tl2 = { w2.x, w2.y }
				local tr2 = { w2.x + w2.w, w2.y }

				if equals(bl1, tl2) and equals(br1, tr2) then
					-- vertical split 
					swap_remove(windows, i)
					swap_remove(windows, j)

					local tree = {
						leaf = false,
						left = w1,
						right = w2,
						horizontal = false,
						x = w1.x,
						y = w1.y,
						w = w1.w,
						h = w1.h + 1 + w2.h
					}

					table.insert(windows, tree)

					vim.print("got vertical split, merging " .. i .. " and " .. j)
					no_merge = false
					goto merge
				end

				::continue::
			end
		end
		::merge::
	until no_merge

	print("Finished saving window state!")
	table.save(windows, "output.lua")
end

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
