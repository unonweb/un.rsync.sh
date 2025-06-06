#!/bin/bash

# script location
SCRIPT_PATH="$(readlink -f "${BASH_SOURCE}")"
SCRIPT_DIR=$(dirname -- "$(readlink -f "${BASH_SOURCE}")")
SCRIPT_NAME=$(basename -- "$(readlink -f "${BASH_SOURCE}")")
# formatting
ESC=$(printf "\e")
BOLD="${ESC}[1m"
RESET="${ESC}[0m"
RED="${ESC}[31m"
GREEN="${ESC}[32m"
BLUE="${ESC}[34m"
UNDERLINE="${ESC}[4m"
GREY="${ESC}[37m"

# IMPORTS
source "${SCRIPT_DIR}/lib/readFileToArray.sh"
source "${SCRIPT_DIR}/lib/selectValueFromArray.sh"

declare -A CONFIG=(
  [clear]=0
  [rsyncOpts]="--archive --recursive --progress --delete --exclude=".git"" # 'file1.txt','dir1/*','dir2'
)
declare -A FILES=(
  [pathsLocal]="${SCRIPT_DIR}/paths_local.txt"
  [pathsRemote]="${SCRIPT_DIR}/paths_remote.txt"
)

function main() {

  local pathsRemote=()
  local pathsLocal=()
  local remotePath=""
  local localPath=""
  local direction="local-remote"
  local src=""
  local dest=""

  readFileToArray pathsLocal ${FILES[pathsLocal]}
  readFileToArray pathsRemote ${FILES[pathsRemote]}
  #echo "pathsLocal has ${#pathsLocal[@]} items"
  #echo "pathsRemote has ${#pathsRemote[@]} items"

  if [[ ${#pathsLocal[@]} -eq 0 ]] || [[ ${#pathsRemote[@]} -eq 0 ]]; then
    echo "Error: pathsLocal has ${#pathsLocal[@]} items"
    echo "Error: pathsRemote has ${#pathsRemote[@]} items"
    return 1
  fi

  # interactive loop
	while true; do
		
		if ((CONFIG[clear])); then clear; fi

		# apply direction
		if [[ ${direction} == "local-remote" ]]; then
			src=${localPath}
			dest=${remotePath}
		elif [[ $direction == "remote-local" ]]; then
			src=${remotePath}
			dest=${localPath}
		else
			echo "ERROR: Unknown direction: ${direction}"
		fi

		echo
		echo -e "${BOLD}RSYNC PATHS${RESET}"
		echo "---------------------------"
		echo -e "FROM:\t${GREEN}${src}${RESET}"
		echo -e "TO:\t${GREEN}${dest}${RESET}"
		echo
		
		echo "${UNDERLINE}Set${RESET}"
		echo -e "${GREEN}1${RESET})  Set local path"
		echo -e "${GREEN}2${RESET})  Set remote path"
		

		echo "${UNDERLINE}List${RESET}"
		echo -e "${GREEN}3${RESET})  List local files"
		echo -e "${GREEN}4${RESET})  List remote files"
		
		echo "${UNDERLINE}Misc${RESET}"
		echo -e "${GREEN}5${RESET})  Swap direction"
		echo -e "${GREEN}6${RESET})  Show diff"
		
		echo "${UNDERLINE}Action${RESET}"
		echo -e "${GREEN}7${RESET})  Perform dry-run"
		echo -e "${GREEN}8${RESET})  Run rsync"
		echo
		read -p ">> " cmd
		echo
		echo

		case ${cmd} in
		1)
			# set local path
			selectValueFromArray localPath pathsLocal
			;;
		3)
			# list local files
			/usr/bin/ls -la --color=auto ${pathsLocal} | less
			;;
		2)
			# set remote path
			selectValueFromArray remotePath pathsRemote
			;;
		4)
			# list remote files
			echo -e "CMD:\t ${GREEN}ssh udo@fk-mobil25 '/usr/bin/ls -la --color=auto ${remotePath#*:}'${RESET}"
			ssh udo@fk-mobil25 "/usr/bin/ls -la --color=auto ${remotePath#*:}" | less
			;;
		5)
			# swap direction
			if [[ $direction == "local-remote" ]]; then
				direction="remote-local"
			else
				direction="local-remote"
			fi
			;;
		6)
			# diff
			echo "not implemented"
			;;
		7)
			# dry-run
			echo "CMD: ${GREEN}rsync ${CONFIG[rsyncOpts]} --dry-run ${src}/ ${dest}${RESET}"
			echo -e "\n${BOLD}Dry run results: ${RESET}\n"
			rsync ${CONFIG[rsyncOpts]} --dry-run ${src}/ ${dest} | less
			echo -e "--- \n"
			;;
		8)
			# run rsync
			input=
			while true; do
				echo "CMD: ${GREEN}rsync ${CONFIG[rsyncOpts]} ${src}/ ${dest}${RESET}"
				echo -e "\e[1mHit 'enter' to start or ctrl + c to abort\e[0m"
				read -n 1 -p ">> " -r input
				echo ""
				if [[ -z $input ]]; then
					break
				fi
			done
			rsync ${CONFIG[rsyncOpts]} ${src}/ ${dest}
			;;
		esac
	done
}

main
