function selectValueFromArray() { # result array
	local -n result=${1}
	local -n array=${2}
	local choice
	local index=1
	local tmp

	while true; do
		for item in "${array[@]}"; do
			echo -e "${GREEN}${index}${RESET})  ${item}"
			((index++))
		done
		echo -e "${GREEN}q${RESET})  Quit" # add quit
		read -p ">> " choice

		if [[ "${choice}" == "q" ]]; then
			# user abort
			return 1
		fi

		tmp=${array[$((choice - 1))]} # decrease by 1 because of zero-based array

		if [[ -n "${tmp}" ]]; then
			# value exists
			result=${tmp} # set value
			unset tmp
			return 0
		else
			# value does not exist
			echo "Invalid choice. Please try again."
			continue
		fi
	done
}