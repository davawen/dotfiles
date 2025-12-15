#!/bin/bash

lines=$(ps -C swayidle | wc --lines)
if [[ "$@" = "echo" ]]; then
	if [[ "$lines" = 1 ]]; then
		echo -e "󱑼 \nEnable swayidle"
	else
		echo -e "󱡗 \nDisable swayidle"
	fi
elif [[ "$@" = "toggle" ]]; then
	if [[ "$lines" = 1 ]]; then
		swayidle -w \
			timeout 300 'swaylock -f -c 000000' \
			timeout 600 'swaymsg "output * dpms off"' \
			resume 'swaymsg "output * dpms on"' \
			before-sleep 'swaylock -f -c 000000' & disown
	else
		killall swayidle
	fi
fi
