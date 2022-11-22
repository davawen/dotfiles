function project
	argparse 'l/lang' -- $argv
	or return

	if test -n "$_flag_l"
		set -f fdArray (string split \n -- (fd --base-directory $prjdir --exclude Prototyping --glob $argv --max-depth=1))
	else
		set -f fdArray (string split \n -- (fd --base-directory $prjdir --exclude Prototyping --glob $argv --min-depth=2))
	end
	
	set fdNum ( count $fdArray )

	if test $fdNum -eq 0
		echo "No match found"

		if test -n "$_flag_l"
			echo "Create language directory $argv? (y/N)"
			read userInput

			if test \( "$userInput" = "y" \) -o \( "$userInput" = "Y" \)
				mkdir "$prjdir/$argv"
				cd "$prjdir/$argv"
			end
		end
	else if test $fdNum -eq 1
		cd "$prjdir/$fdArray[1]"
	else
		for i in (seq (count $fdArray))
			set -l found $fdArray[$i]

			printf "%3d. %s\n" "$i" "$found"
		end

		printf "Choice: "
		read userInput

		cd "$prjdir/$fdArray[$userInput]"
	end
end
