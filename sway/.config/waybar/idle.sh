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
		$HOME/.config/sway/scripts/idlecmd.sh &
	else
		killall swayidle
	fi
fi
