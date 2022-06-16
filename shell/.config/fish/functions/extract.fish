function extract
	argparse -X 2 'h/help' -- $argv
	or return

	if test -n "$_flag_h"; or test ( count $argv ) -eq 0
		echo "Usage: Extract <archive> [<directory>]"
		return
	end

	if test ( count $argv ) -eq 1
		tar -xf $argv[1]
	else
		mkdir -p $argv[2]
		tar -xf $argv[1] -C $argv[2]
	end
end
