#!/bin/bash
#	Made by Noah0302sTech
#	chmod +x Docker-SystemPrune-UnInstaller-Noah0302sTech.sh && sudo bash Docker-SystemPrune-UnInstaller-Noah0302sTech.sh

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

	#----- Variables
		urlVar="https://raw.githubusercontent.com/Noah0302sTech/Bash-Skripte/testing/Docker/System-Prune/Uninstaller/Docker-SystemPrune-UnInstaller-Noah0302sTech.sh"
		cronJobAdded=true

		parentFolder="Docker"
			subFolder="System-Prune"
				fullInstallerFolder="Full-Installer"
					fullInstaller="Docker-SystemPrune-Installer-Noah0302sTech.sh"
				bashExecuterFolder="System-Prune-Executer"
					bashExecuter="Docker-SystemPrune-Executer-Noah0302sTech.sh"
				unInstallerFolder="Uninstaller"
					unInstaller="Docker-SystemPrune-UnInstaller-Noah0302sTech.sh"
				cronCheck="Cron-Check.txt"

		parentFolderPath="/home/$SUDO_USER/Noah0302sTech/$parentFolder"
			subFolderPath="/home/$SUDO_USER/Noah0302sTech/$parentFolder/$subFolder"
				fullInstallerFolderPath="/home/$SUDO_USER/Noah0302sTech/$parentFolder/$subFolder/$fullInstallerFolder"
					fullInstallerPath="/home/$SUDO_USER/Noah0302sTech/$parentFolder/$subFolder/$fullInstallerFolder/$fullInstaller"
				bashExecuterFolderPath="/home/$SUDO_USER/Noah0302sTech/$parentFolder/$subFolder/$bashExecuterFolder"
					bashExecuterPath="/home/$SUDO_USER/Noah0302sTech/$parentFolder/$subFolder/$bashExecuterFolder/$bashExecuter"
				unInstallerFolderPath="/home/$SUDO_USER/Noah0302sTech/$parentFolder/$subFolder/$unInstallerFolder"
					unInstallerPath="/home/$SUDO_USER/Noah0302sTech/$parentFolder/$subFolder/$unInstallerFolder/$unInstaller"
				cronCheckPath="/home/$SUDO_USER/Noah0302sTech/$parentFolder/$subFolder/$cronCheck"

#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#





#----- Remove Cron-Job
	while IFS= read -n1 -r -p "Möchtest du einen Cron-Job entfernen? [y]es|[n]o: " && [[ $REPLY != q ]]; do
	case $REPLY in
		y)  echo
			#--- Remove Cron-Job
				start_spinner "Lösche Crontab..."
					rm /etc/cron.d/docker-System-Prune-Noah0302sTech
				stop_spinner $?

			#--- Modify Variable
				cronJobAdded="false"
				stop_spinner $?

			break;;
		n)  echo
			echo "Cron-Job wurde nicht gelöscht."
			
			break;;
		*)  echo
			echo "Antoworte mit y oder n";;
	esac
	done
	echoEnd


#----- Remove Alias
	while IFS= read -n1 -r -p "Möchtest du den Bash-Alias entfernen? [y]es|[n]o: " && [[ $REPLY != q ]]; do
	case $REPLY in
		y)  echo
			#--- Remove Alias
				start_spinner "Lösche Bash-Alias..."
					sed -i '/^#Alias/d' /home/$SUDO_USER/.bashrc
					sed -i '/^alias DSPtrim/d' /home/$SUDO_USER/.bashrc
					sed -i '/^alias ccDocker/d' /home/$SUDO_USER/.bashrc
				stop_spinner $?

			break;;
		n)  echo
			echo "Bash-Alias wurde nicht gelöscht."
			
			break;;
		*)  echo
			echo "Antoworte mit y oder n";;
	esac
	done
	echoEnd



#----- Remove MOTD
	while IFS= read -n1 -r -p "Möchtest du den MOTD-Eintrag entfernen? [y]es|[n]o: " && [[ $REPLY != q ]]; do
	case $REPLY in
		y)  echo
			#--- Remove Alias
				start_spinner "Lösche MOTD-Eintrag..."
					sed -i '/^Docker-System-Prune + Trim:/d' /etc/motd
					sed -i '/^        DSPtrim/d' /etc/motd
					sed -i '/^Cron-Check Docker:/d' /etc/motd
					sed -i '/^        ccDocker/d' /etc/motd
				stop_spinner $?

			break;;
		n)  echo
			echo "MOTD-Eintrag wurde nicht gelöscht."
			
			break;;
		*)  echo
			echo "Antoworte mit y oder n";;
	esac
	done
	echoEnd





#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#