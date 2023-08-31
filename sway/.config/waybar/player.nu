#!/usr/local/bin/nu

let status = playerctl -a status | lines
if ($status | is-empty) or (($status | first) == "Stopped") {
	print "\n\nstopped"
	exit 1
}
let status = ($status | first)

# Needed to specify player, otherwise unsupported attributes might spill over to the next
let player = playerctl -l | lines | first

let name = playerctl -p $player metadata -f '{{title}} by `{{artist}}`' | str trim
let album = playerctl -p $player metadata -f '{{album}}' | into string | str trim
let album = if ($album | is-empty) { "No album" } else { $"From album `($album)`" }

let volume = playerctl -p $player volume | into string
let volume = if ($volume | is-empty) { "" } else {
	$"(($volume | into decimal) * 100 | into int) %"
}

let icon = if $status == "Playing" { "󰏤" } else { "󰐊" }

$"󰒮 ($icon) 󰒭 ($volume) ($name)\n($album)\n($status | str downcase)"
