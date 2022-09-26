function get_upwards_wineprefix
	set -l start_dir $(pwd)
	while ! test -d "drive_c" && ! test -d "dosdevices"
		if test "$(pwd)" = "/"
			return 1
		end
		cd ..
	end
	echo $(pwd)
	cd $start_dir
end
