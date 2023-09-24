#!/bin/sh

set -e

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

function icon() {
	echo -n "$1\0icon\x1f$2"
}

commands="$(icon run system-search)\n$(icon session user)\n$(icon terminal terminal)"
command=$(printf "$commands" | fuzzel -d)

if [ $? -eq 0 ]; then
	if [ "$command" = "run" ]; then
		fuzzel
	elif [ "$command" = "session" ]; then

		commands="$(icon "log out" "system-logout")
$(icon "suspend" "system-suspend")
$(icon "hibernate" "system-suspend-hibernate")
$(icon "reboot" "system-reboot")
$(icon "power off" "system-shutdown")"

		command=$(printf "$commands" | fuzzel -d)
		if [ $? -eq 0 ]; then
			if [ "$command" = "log out" ]; then
				sway exit
			elif [ "$command" = "suspend" ]; then
				systemctl suspend
			elif [ "$command" = "hibernate" ]; then
				systemctl hibernate
			elif [ "$command" = "reboot" ]; then
				systemctl reboot
			elif [ "$command" = "power off" ]; then
				systemctl poweroff
			fi
		fi
	elif [ "$command" = "terminal" ]; then
		command=$(list_execs | fuzzel -d)
		if [ -n "$command" ]; then
			kitty $command
		fi
	fi
fi

