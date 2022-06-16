function project
	set fdArray (string split \n -- (fd --base-directory $prjdir --glob $argv))
	
	set fdNum ( count $fdArray )

	if test $fdNum -eq 0
		echo "No match found"
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
