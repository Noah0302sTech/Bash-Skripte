#!/bin/bash
#	Made by Noah0302sTech
#	chmod +x NPM-Installer-Docker-Debian-Noah0302sTech.sh && sudo bash NPM-Installer-Docker-Debian-Noah0302sTech.sh

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
		urlVar="https://raw.githubusercontent.com/Noah0302sTech/"

		parentFolder="Docker"
			subFolder="NGINX-Proxy-Manager"
				fullInstallerFolder="Installer"
					fullInstaller="NPM-Installer-Docker-Debian-Noah0302sTech.sh"
				folder1="Docker-Compose"
					bash1="docker-compose.yml"

		parentFolderPath="/home/$SUDO_USER/Noah0302sTech/$parentFolder"
			subFolderPath="/home/$SUDO_USER/Noah0302sTech/$parentFolder/$subFolder"
				fullInstallerFolderPath="/home/$SUDO_USER/Noah0302sTech/$parentFolder/$subFolder/$fullInstallerFolder"
					fullInstallerPath="/home/$SUDO_USER/Noah0302sTech/$parentFolder/$subFolder/$fullInstallerFolder/$fullInstaller"

				folder1Path="/home/$SUDO_USER/Noah0302sTech/$parentFolder/$subFolder/$folder1"
					bash1Path="/home/$SUDO_USER/Noah0302sTech/$parentFolder/$subFolder/$folder1/$bash1"

#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#





#----- Docker
	#--- Install Docker
		start_spinner "Installiere docker.io..."
			apt install docker.io -y > /dev/null 2>&1
		stop_spinner $?

	#--- Install Docker Compose
		start_spinner "Installiere Docker-Compose..."
			apt install docker-compose -y > /dev/null 2>&1
		stop_spinner $?

	#--- Add User to Docker-Group
		start_spinner "Füge $SUDO_USER zu Docker-Gruppe hinzu..."
			usermod -aG docker $SUDO_USER > /dev/null 2>&1
		stop_spinner $?

	echoEnd



#----- Create NPM
	#--- Create docker-compose.yml
		#- Variables
			webinterfacePort="81"
				read -p "Gib den Port für das Admin-Webinterface an [default: $webinterfacePort]: " input
				webinterfacePort=${input:-$webinterfacePort}

	start_spinner "Erstelle docker-compose.yml..."
		touch docker-compose.yml > /dev/null 2>&1
		echo "version: '3.8'
services:
  app:
    image: 'jc21/nginx-proxy-manager:latest'
    restart: unless-stopped
    ports:
      # These ports are in format <host-port>:<container-port>
      - '80:80' # Public HTTP Port
      - '443:443' # Public HTTPS Port
      - '81:$webinterfacePort' # Admin Web Port
      # Add any other Stream port you want to expose
      # - '21:21' # FTP

    # Uncomment the next line if you uncomment anything in the section
    # environment:
      # Uncomment this if you want to change the location of
      # the SQLite DB file within the container
      # DB_SQLITE_FILE: "/data/database.sqlite"

      # Uncomment this if IPv6 is not enabled on your host
      # DISABLE_IPV6: 'true'

    volumes:
      - ./data:/data
      - ./letsencrypt:/etc/letsencrypt" > docker-compose.yml
	stop_spinner $?

	#--- Start NPM
		start_spinner "Starte NGINX-Proxy-Manager..."
			docker-compose up -d > /dev/null 2>&1
		stop_spinner $?
		docker ps

	echoEnd




#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#

#---------- Creating Files & Folders, moving Files
	#----- Create Folders
		start_spinner "Erstelle Verzeichnisse..."
			#--- Noah0302sTech
				if [ ! -d /home/$SUDO_USER/Noah0302sTech ]; then
					mkdir /home/$SUDO_USER/Noah0302sTech > /dev/null 2>&1
				else
					echo "Ordner /home/$SUDO_USER/Noah0302sTech bereits vorhanden!"
				fi

				#--- Parent Folder
					if [ ! -d $parentFolderPath ]; then
						mkdir $parentFolderPath > /dev/null 2>&1
					else
						echo "Ordner $parentFolderPath bereits vorhanden!"
					fi

					#--- Sub Folder
						if [ ! -d $subFolderPath ]; then
							mkdir $subFolderPath > /dev/null 2>&1
						else
							echo "Ordner $subFolderPath bereits vorhanden!"
						fi

						#--- Full-Installer Folder
							if [ ! -d $fullInstallerFolderPath ]; then
								mkdir $fullInstallerFolderPath > /dev/null 2>&1
							else
								echo "Ordner $fullInstallerFolderPath bereits vorhanden!"
							fi

						#--- Docker-Compose
							if [ ! -d $folder1Path ]; then
								mkdir $folder1Path > /dev/null 2>&1
							else
								echo "Ordner $folder1Path bereits vorhanden!"
							fi
		stop_spinner $?

	#----- Move Files
		start_spinner "Verschiebe Files..."
			#--- Full-Installer
				if [ ! -f $fullInstallerPath ]; then
					mv /home/$SUDO_USER/$fullInstaller $fullInstallerPath > /dev/null 2>&1
				else
					echo "Die Datei $fullInstaller ist bereits vorhanden!"
				fi

				#--- docker-compose.yml
					if [ ! -f $bash1Path ]; then
						mv /home/$SUDO_USER/$bash1 $bash1Path > /dev/null 2>&1
					else
						echo "Die Datei $bash1 ist bereits vorhanden!"
					fi
		stop_spinner $?