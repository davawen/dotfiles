#!/bin/sh

function list_execs() {
	local IFS=':'
	set -f

	for p in $PATH; do
		if [ -d "$p" ]; then
			find -L $p -maxdepth 1 -type f -executable -printf "%f\n" # print only filename
		fi
	done

	set +f
}

commands="run\nsession\nterminal"
command=$(printf "$commands" | fuzzel -d)

if [ $? -eq 0 ]; then
	if [ "$command" = "run" ]; then
		fuzzel
	elif [ "$command" = "session" ]; then
		commands="log out\nsuspend\nreboot\npower off"
		command=$(printf "$commands" | fuzzel -d)
		if [ $? -eq 0 ]; then
			if [ "$command" = "log out" ]; then
				sway exit
			elif [ "$command" = "suspend" ]; then
				systemctl suspend
			elif [ "$command" = "reboot" ]; then
				systemctl reboot
			elif [ "$command" = "power off" ]; then
				systemctl poweroff
			fi
		fi
	elif [ "$command" = "terminal" ]; then
		command=$(list_execs | fuzzel -d)
		if [ $? -eq 0 ]; then
			kitty $command
		fi
	fi
fi

