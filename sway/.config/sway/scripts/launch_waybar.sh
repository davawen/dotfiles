#!/bin/sh

arg=""
path="$HOME/.config/waybar/$(hostname).css"
if [ -e "$path" ]
then
	arg="--style $path"
fi

waybar $arg 2>&1 > /tmp/waybar.log
