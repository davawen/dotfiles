function add_app
	if test (count $argv) -ne 1
		echo "add_desktop_app {App Name}"
		return 1
	end

	cd $HOME/.local/share/applications

	set -l FILENAME "$argv[1].desktop"

	if ! test -e $FILENAME
		echo "[Desktop Entry]
Name=$argv[1]
Comment=
Exec=
Icon=
Terminal=false
Type=Application
Categories=" > $FILENAME
	end

	$EDITOR $FILENAME
end
