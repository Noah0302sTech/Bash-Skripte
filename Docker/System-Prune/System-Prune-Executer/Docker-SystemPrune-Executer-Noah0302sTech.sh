#!/bin/bash
#	Made by Noah0302sTech
#	chmod +x Docker-SystemPrune-Executer-Noah0302sTech.sh && sudo bash Docker-SystemPrune-Executer-Noah0302sTech.sh

#---------- Initial Checks & Functions
	#----- Check for administrative privileges
		if [[ $EUID -ne 0 ]]; then
			echo "Das Skript muss mit Admin-Privilegien ausgeführt werden! (sudo)"
			exit 1
		fi



	#----- Source of Spinner-Function: https://github.com/tlatsas/bash-spinner -----#
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



	#----- echoEnd
			function echoEnd {
				echo
				echo
				echo
			}



	#----- Refresh Packages
		start_spinner "Aktualisiere Package-Listen..."
			apt update -y > /dev/null 2>&1
		stop_spinner $?
		echoEnd

#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#




#----- APT
	#--- Update
		start_spinner "Update Package-Listen..."
			apt update -y > /dev/null 2>&1
		stop_spinner $?

	#--- Autoremove
		start_spinner "Autoremove Packages..."
			apt autoremove -y > /dev/null 2>&1
		stop_spinner $?
	echoEnd



#----- Variables
	dockerPruneOutput="Docker-System-Prune did not run! Laufen alle Docker-Container?"
	fstrimOutput="FS-Trim did not run! Unterstützt dein Filesystem den Trim-Command?"



#----- Docker
	if command -v docker &> /dev/null
	then
		if [[ -z "$(docker ps -q -f status=exited)" ]]; then
			start_spinner "Alle Docker Container laufen, führe Docker-System-Prune aus..."
				dockerPruneOutput=$(docker system prune -f 2>&1)
			stop_spinner $?
			echo $dockerPruneOutput
		else
			echo "Es wurden gestoppte Container gefunden:"
			docker ps -f "status=exited"
		fi
	else
		echo "Docker ist nicht installiert, überspringe Docker System Prune"
	fi
	echoEnd



#----- Check if the filesystem supports fstrim command
	#--- Check if the script is running within a container
	if [ -f /proc/1/environ ] && grep -q container=lxc /proc/1/environ; then
		echo "Script läuft in einem Container!"
		echo "Möglicherweise keine Berechtigungen für 'fstrim' Command!"
		echo "Script wird abgebrochen!"
		exit 0
	fi

	#--- Check if the script is running within a VMware VM
	if command -v dmidecode >/dev/null 2>&1 && dmidecode -s system-product-name | grep -qi "VMware"; then
		echo "Script läuft in einer VMware-VM"
		echo "Möglicherweise keine Berechtigungen für 'fstrim' Command"
		echo "Script wird abgebrochen!"
		exit 0
	fi

	#--- Check if the filesystem supports fstrim command
	if blkid -o value -s discard $(findmnt -n -o SOURCE --target /) >/dev/null 2>&1; then
		echo "Filesystem unterstützt 'fstrim' Command"

		# Run fstrim on the root filesystem
		if command -v fstrim >/dev/null 2>&1; then
			start_spinner "Trimme Filesystem..."
				fstrimOutput=$(/sbin/fstrim -av 2>&1)
			stop_spinner $?
			echo $fstrimOutput
		else
			echo "'fstrim' Command ist nicht verfügbar"
		fi
	else
		echo "Filesystem unterstützt 'fstrim' Command NICHT!"
	fi

	echoEnd




#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#