function project
	argparse 'l/lang' -- $argv
	or return

	if test -n "$_flag_l"
		set -f fd_out "$(fd --base-directory $prjdir --exclude Prototyping --max-depth=1)"
	else
		set -f fd_out "$(fd --base-directory $prjdir --exclude Prototyping --exact-depth=2)"
	end
		
	set fzf_out $(echo $fd_out | fzf --query="$argv")
	
	if test $status -eq 0
		cd "$prjdir/$fzf_out"
	else
		echo "No match found"

		if test -n "$_flag_l"
			echo "Create language directory $argv? (y/c/N)"
			read user_input

			if test \( "$user_input" = "y" \) -o \( "$user_input" = "Y" \)
				mkdir "$prjdir/$argv"
				cd "$prjdir/$argv"
			else if test \( "$user_input" = "c" \) -o \( "$user_input" = "C" \)
				read user_input
				mkdir "$prjdir/$user_input"
				cd "$prjdir/$user_input"
			end
		end
	end
end
