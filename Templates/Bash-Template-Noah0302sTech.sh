#!/bin/bash
#   Made by Noah0302sTech
#   chmod +x Bash-Template-Noah0302sTech.sh && sudo bash Bash-Template-Noah0302sTech.sh





#----- Check for administrative privileges
	if [[ $EUID -ne 0 ]]; then
		echo "Das Skript muss mit Admin-Privilegien ausgeführt werden! (sudo)"
		exit 1
	fi



#----- Source of Spinner-Function: https://github.com/tlatsas/bash-spinner
		function _spinner() {
			# $1 start/stop
			#
			# on start: $2 display message
			# on stop : $2 process exit status
			#           $3 spinner function pid (supplied from stop_spinner)

			local on_success="DONE"
			local on_fail="FAIL"
			local white="\e[1;37m"
			local green="\e[1;32m"
			local red="\e[1;31m"
			local nc="\e[0m"

			case $1 in
				start)
					# calculate the column where spinner and status msg will be displayed
					let column=$(tput cols)-${#2}-8
					# display message and position the cursor in $column column
					echo -ne ${2}
					printf "%${column}s"

					# start spinner
					i=1
					sp='\|/-'
					delay=${SPINNER_DELAY:-0.15}

					while :
					do
						printf "\b${sp:i++%${#sp}:1}"
						sleep $delay
					done
					;;
				stop)
					if [[ -z ${3} ]]; then
						echo "spinner is not running.."
						exit 1
					fi

					kill $3 > /dev/null 2>&1

					# inform the user uppon success or failure
					echo -en "\b["
					if [[ $2 -eq 0 ]]; then
						echo -en "${green}${on_success}${nc}"
					else
						echo -en "${red}${on_fail}${nc}"
					fi
					echo -e "]"
					;;
				*)
					echo "invalid argument, try {start/stop}"
					exit 1
					;;
			esac
		}

		function start_spinner {
			# $1 : msg to display
			_spinner "start" "${1}" &
			# set global spinner pid
			_sp_pid=$!
			disown
		}

		function stop_spinner {
			# $1 : command exit status
			_spinner "stop" $1 $_sp_pid
			unset _sp_pid
		}





#----- Refresh Packages
	start_spinner "Aktualisiere Package-Listen..."
		sudo apt update -y > /dev/null 2>&1
	stop_spinner $?
	echo
	echo



#----- INSERT NEW LINES HERE
	start_spinner "INSERT NEW LINES HERE..."
		echo "INSERT NEW LINES HERE"
	stop_spinner $?
	echo
	echo



#----- Create Folder
	start_spinner "Erstelle Verzeichnisse..."
		mkdir Noah0302sTech
		mkdir Noah0302sTech/Templates
	stop_spinner $?

	#--- Move Bash-Script
		start_spinner "Verschiebe Bash-Skript..."
			mv Bash-Template-Noah0302sTech.sh Noah0302sTech/Templates/Bash-Template-Noah0302sTech.sh
		stop_spinner $?
	echo
	echo