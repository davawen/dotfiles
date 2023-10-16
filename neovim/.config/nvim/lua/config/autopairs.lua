local npairs = require("nvim-autopairs");
npairs.setup {
	-- Lua pattern to check if plugin should apply depending on next character
	-- |.thing -> (|.thing
	ignored_next_char = "[%%%'%\"]",
	enable_moveright = false,
	enable_check_bracket_line = false, -- check bracket in same line
	fast_wrap = {
		map = '<M-e>',
		pattern = [=[[%'%"%)%>%]%)%}%,%;]]=],
		end_key = '$',
		keys = 'asdfghjkl',
		check_comma = true,
		highlight = 'Search',
		highlight_grey = 'Comment'
	}
}

local Rule = require('nvim-autopairs.rule')
local cond = require('nvim-autopairs.conds')

npairs.add_rule(
	Rule("`", "`", { "markdown" })
		:with_cr(cond.none())
)

npairs.remove_rule('```')
npairs.remove_rule("'")

-- Template generics
npairs.add_rule(
	Rule("<", ">")
		:with_pair(cond.before_regex("%w"))
)
-- Latex brackets
npairs.add_rule(
	Rule('\\[', '\\]', { "tex", "latex" })
		:with_cr(cond.none())
)

-- Add spaces
npairs.add_rules {
  Rule(' ', ' ')
	:with_pair(function (opts)
	  local pair = opts.line:sub(opts.col - 1, opts.col)
	  return vim.tbl_contains({ '()', '[]', '{}' }, pair)
	end),
  Rule('( ', ' )')
	  :with_pair(function() return false end)
	  :with_move(function(opts)
		  return opts.prev_char:match('.%)') ~= nil
	  end)
	  :use_key(')'),
  Rule('{ ', ' }')
	  :with_pair(function() return false end)
	  :with_move(function(opts)
		  return opts.prev_char:match('.%}') ~= nil
	  end)
	  :use_key('}'),
  Rule('[ ', ' ]')
	  :with_pair(function() return false end)
	  :with_move(function(opts)
		  return opts.prev_char:match('.%]') ~= nil
	  end)
	  :use_key(']')
}
