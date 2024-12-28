local wezterm = require('wezterm')

wezterm.on(
	'format-tab-title',
	function (tab, tabs, panes, config, hover, max_width)
		local background = '#24273a'
		local edge_background = background
		local foreground = '#cad3f5'
		local intensity = "Normal"

		if tab.is_active then
			background = '#c6a0f6'
			foreground = '#000000'
			intensity = "Bold"
		end

		local SEPARATOR_LEFT = utf8.char(0xe0ba)
		local SEPARATOR_RIGHT = utf8.char(0xe0bc)

		-- ensure that the titles fit in the available space,
		-- and that we have room for the edges.
		local title = wezterm.truncate_right(tab.active_pane.title, max_width - 2)

		return {
			{ Background = { Color = edge_background } },
			{ Foreground = { Color = background } },
			{ Text = SEPARATOR_LEFT },
			{ Background = { Color = background } },
			{ Foreground = { Color = foreground } },
			{ Attribute = { Intensity = intensity } },
			{ Text = title },
			{ Background = { Color = edge_background } },
			{ Foreground = { Color = background } },
			{ Text = SEPARATOR_RIGHT },
		}
	end
)

local act = wezterm.action

return {
	default_cursor_style = "SteadyBar",
	color_scheme = "Catppuccin Macchiato",
	font = wezterm.font_with_fallback { { family = "Iosevka", weight = "Medium" }, "Symbols Nerd Font" },
	font_size = 13.5,
	keys = {
		{ key = 'LeftArrow', mods = 'CTRL|SHIFT', action = act.ActivateTabRelative(-1) },
		{ key = 'RightArrow', mods = 'CTRL|SHIFT', action = act.ActivateTabRelative(1) },
		{ key = 'h', mods = 'CTRL|SHIFT', action = act.ActivateTabRelative(-1) },
		{ key = 'l', mods = 'CTRL|SHIFT', action = act.ActivateTabRelative(1) },
		{ key = '<', mods = 'CTRL|SHIFT', action = act.MoveTabRelative(-1) },
		{ key = '>', mods = 'CTRL|SHIFT', action = act.MoveTabRelative(1) },
		{ key = 't', mods = 'CTRL|SHIFT', action = act.SpawnCommandInNewTab { cwd = '~' }},

		{ key = 'UpArrow', mods = 'CTRL|SHIFT', action = act.ScrollByLine(-1) },
		{ key = 'DownArrow', mods = 'CTRL|SHIFT', action = act.ScrollByLine(1) },
		{ key = 'PageUp', mods = 'CTRL|SHIFT', action = act.ScrollByPage(-1) },
		{ key = 'PageDown', mods = 'CTRL|SHIFT', action = act.ScrollByPage(1) },

		{ key = ';', mods = 'CTRL|ALT', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
		{ key = "'", mods = 'CTRL|ALT', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
		{ key = 'h', mods = 'CTRL|ALT', action = act.ActivatePaneDirection 'Left' },
		{ key = 'j', mods = 'CTRL|ALT', action = act.ActivatePaneDirection 'Down' },
		{ key = 'k', mods = 'CTRL|ALT', action = act.ActivatePaneDirection 'Up' },
		{ key = 'l', mods = 'CTRL|ALT', action = act.ActivatePaneDirection 'Right' },
		{ key = 'w', mods = 'CTRL|ALT', action = act.CloseCurrentPane { confirm = false } }
	},
	hide_mouse_cursor_when_typing = false,
	tab_bar_at_bottom = true,
	use_fancy_tab_bar = false,
	window_frame = {
		border_left_width = '0.25cell',
		border_right_width = '0.25cell',
		border_bottom_height = '0.125cell',
		border_top_height = '0.125cell',
		border_left_color = '#303446',
		border_right_color = '#303446',
		border_bottom_color = '#303446',
		border_top_color = '#303446',
	},
	window_padding = {
		left = 0,
		right = 0,
		top = 0,
		bottom = 0
	},
}
