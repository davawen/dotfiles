#!/usr/bin/env bash
# requirements: sway, grim, slurp, swayimg, ffmpeg, wl-clipboard, swappy
# Freezes the screen, allows capturing an area.
# first argument: wether to edit resulting screenshot ("edit" to edit)
# second argument: path to temporary file
# third argument: the classname to use for swayimg
#
# In sway config add:
# `for_window [app_id="swayimg-screenshot"] fullscreen enable global`
# to ensure that fullscreen spans all outputs
# alternatively, use swaymsg to set that in this script based on IMGCLASS
#
# Configure DESKTOPSIZE variable to match your total desktop size

EDIT=${1:-"false"}
TMPIMG=${2:-"$(mktemp --suffix ss.png)"}
IMGCLASS=${3:-"swayimg-screenshot"}
SLURPARG="-f %w:%h:%x:%y -d -b 00000066"
# DESKTOPSIZE="0,0 3840x1510" -g "$DESKTOPSIZE"

grim -c -t png -l 0 -s 1 "$TMPIMG"
swayimg -s=real -c "general.app_id=$IMGCLASS" "$TMPIMG" &

# swaymsg -q "[app_id=$IMGCLASS] focus"

trim() {
	(ffmpeg -loglevel warning -i "$TMPIMG" -vf "crop=$(slurp $SLURPARG)" -y \
        -c:v png -f image2pipe -pred 2 -compression_level 1 - ; \
        swaymsg -q "[app_id=$IMGCLASS] kill" 1>&2) | cat
}

if [ $EDIT = "edit" ]; then
	trim | swappy -f - -o -
else
	trim | wl-copy
fi

rm "$TMPIMG"
