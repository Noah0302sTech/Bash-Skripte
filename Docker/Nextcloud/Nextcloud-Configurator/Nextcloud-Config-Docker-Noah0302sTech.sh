#!/bin/bash
#	Made by Noah0302sTech
#	chmod +x Nextcloud-Config-Docker-Noah0302sTech.sh && sudo bash Nextcloud-Config-Docker-Noah0302sTech.sh

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
						delay=0.25

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



	#----- End of -----#
			function echoEnd {
				echo
				echo
				echo
			}



	#----- Refresh Packages
		start_spinner "Aktualisiere Package-Listen..."
			apt update > /dev/null 2>&1
		stop_spinner $?
		echo
		echo



	#----- Variables
		urlVar=https://raw.githubusercontent.com/Noah0302sTech/Bash-Skripte/master/Docker/Nextcloud/


		parentFolder="Docker"
			subFolder="Nextcloud"
				fullInstallerFolder="Full-Installer"
					fullInstaller="Nextcloud-Install-Docker-Debian-Noah0302sTech.sh"
				bashConfiguratorFolder="Configurator"
					bashConfigurator="Nextcloud-Config-Docker-Noah0302sTech.sh"
				dockerComposeFolder="Docker-Compose"
					dockerComposeFile="docker-compose.yml"
				unInstallerFolder="Uninstaller"
					unInstaller="Docker-SystemPrune-UnInstaller-Noah0302sTech.sh"


		parentFolderPath="/home/$SUDO_USER/Noah0302sTech/$parentFolder"
			subFolderPath="/home/$SUDO_USER/Noah0302sTech/$parentFolder/$subFolder"
				fullInstallerFolderPath="/home/$SUDO_USER/Noah0302sTech/$parentFolder/$subFolder/$fullInstallerFolder"
					fullInstallerPath="/home/$SUDO_USER/Noah0302sTech/$parentFolder/$subFolder/$fullInstallerFolder/$fullInstaller"
				bashConfiguratorFolderPath="/home/$SUDO_USER/Noah0302sTech/$parentFolder/$subFolder/$bashConfiguratorFolder"
					bashConfiguratorPath="/home/$SUDO_USER/Noah0302sTech/$parentFolder/$subFolder/$bashConfiguratorFolder/$bashConfigurator"
				dockerComposeFolderPath="/home/$SUDO_USER/Noah0302sTech/$parentFolder/$subFolder/$dockerComposeFolder"
					dockerComposeFilePath="/home/$SUDO_USER/Noah0302sTech/$parentFolder/$subFolder/$dockerComposeFolder/$dockerComposeFile"
				unInstallerFolderPath="/home/$SUDO_USER/Noah0302sTech/$parentFolder/$subFolder/$unInstallerFolder"
					unInstallerPath="/home/$SUDO_USER/Noah0302sTech/$parentFolder/$subFolder/$unInstallerFolder/$unInstaller"

#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#





#----- Change Config
	nextcloud_dataPath=inputFromInstaller
	nano $nextcloud_dataPath/config/config.php



#----- Restart Docker
	while IFS= read -n1 -r -p "Möchtest du die Docker-Container jetzt neustarten, um die Änderungen zu übernehmen? Y/N: " && [[ $REPLY != q ]]; do
	case $REPLY in
		y)  echo
			#--- Curl Java-Updater
				start_spinner "Starte Docker-Container neu... "
						docker restart $SUDO_USER-nextcloud > /dev/null 2>&1
						docker restart $SUDO_USER-mariadb > /dev/null 2>&1
				stop_spinner $?
			break;;

			n)  echo
			break;;

			*)  echo
			echo "Antoworte mit y oder n";;
	esac
	done

	docker ps

	echoEnd





#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#