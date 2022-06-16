function proto
	if test (count $argv) -ne 1
		return 1
	end

	set path "$prjdir/Prototyping/$argv[1]"

	mkdir -p $path
	cd $path
end
