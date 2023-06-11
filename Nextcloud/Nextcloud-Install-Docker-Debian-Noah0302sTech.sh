#!/bin/bash
#	Made by Noah0302sTech
#	chmod +x Nextcloud-Install-Docker-Debian-Noah0302sTech.sh && sudo bash Nextcloud-Install-Docker-Debian-Noah0302sTech.sh

#---------- Initial Checks & Functions
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
			apt update -y > /dev/null 2>&1
		stop_spinner $?
		echo
		echo



	#----- Variables
		url="https://raw.githubusercontent.com/Noah0302sTech/Bash-Skripte/master/Nextcloud/Nextcloud-Config-Docker-Noah0302sTech.sh"
		folderVar=Docker
			subFolderVar=Nextcloud
				folder1=Installer
					bashInstaller=Nextcloud-Install-Docker-Debian-Noah0302sTech.sh
				folder2=Configurator
					bashExecuter=Nextcloud-Config-Docker-Noah0302sTech.sh
				folder3=Docker-Compose
					composeFile=docker-compose.yml

#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#


#----- Docker
	#--- Install Docker
		start_spinner "Installiere docker.io..."
		apt install -y docker.io > /dev/null 2>&1
		stop_spinner $?
		echo

	#--- Install Docker Compose
		start_spinner "Installiere Docker-Compose..."
		apt install -y docker-compose > /dev/null 2>&1
		stop_spinner $?
		echo

	#--- Add User to Docker-Group
		start_spinner "Füge $SUDO_USER zu Docker-Gruppe hinzu..."
		usermod -aG docker $SUDO_USER > /dev/null 2>&1
		stop_spinner $?

	#--- Install Apparmor (Only needed on specific Systems like Hetzner VServer)
		start_spinner "Installiere Apparmor, falls benötigt..."
		apt install apparmor -y > /dev/null 2>&1
		stop_spinner $?

	echo
	echo





#----- Set default values for Docker-Compose
	MYSQL_ROOT_PASSWORD=sqlrootpassword
	MYSQL_PASSWORD=sqlpassword

#----- Prompt user for custom values
	read -p "MariaDB-Root-Passwort eigeben [default: $MYSQL_ROOT_PASSWORD]: " input
	MYSQL_ROOT_PASSWORD=${input:-$MYSQL_ROOT_PASSWORD}
	read -p "MariaDB-Passwort eigeben [default: $MYSQL_PASSWORD]: " input
	MYSQL_PASSWORD=${input:-$MYSQL_PASSWORD}
	
	echo
	echo



#----- Create a Docker Compose file
	start_spinner "Erstelle Docker-Compose-File..."
		touch docker-compose.yml
		echo "version: '3'
services:
  db:
    image: mariadb
    environment:
      - MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD
      - MYSQL_PASSWORD=$MYSQL_PASSWORD
      - MYSQL_DATABASE=nextclouddb
      - MYSQL_USER=nextcloud
    restart: unless-stopped
  nextcloud:
    image: nextcloud
    ports:
      - 8080:80
    volumes:
      - nextcloud_data:/var/www/html
    environment:
      - MYSQL_HOST=db
      - MYSQL_USER=nextcloud
      - MYSQL_PASSWORD=$MYSQL_PASSWORD
      - MYSQL_DATABASE=nextclouddb
    restart: unless-stopped
    depends_on:
      - db
volumes:
  nextcloud_data:
" >> docker-compose.yml
	stop_spinner $?

	echo
	echo



#----- Start the Nextcloud server
	start_spinner "Starte Nextcloud-Server..."
		docker-compose up -d > /dev/null 2>&1
	stop_spinner $?
	docker ps

	echo
	echo



#----- Configure the Nextcloud Server
	start_spinner "Erstelle Nextcloud-Config-Skript..."
		apt install wget -y > /dev/null 2>&1
		wget $url > /dev/null 2>&1
		chmod +x Nextcloud-Config-Docker-Noah0302sTech.sh
	stop_spinner $?
	echo "Um NACH DER INSTALLATION die Nextcloud-Config anzupassen, starte das Nextcloud-Config-Skript mit:"
	echo "sudo bash /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolderVar/$folder2/$bashExecuter"

	echo
	echo





#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#

#----- Create Folders
	start_spinner "Erstelle Verzeichnisse..."
		#--- /home/$SUDO_USER/Noah0302sTech
			if [ ! -d /home/$SUDO_USER/Noah0302sTech ]; then
				mkdir /home/$SUDO_USER/Noah0302sTech > /dev/null 2>&1
			else
				echo "Ordner /home/$SUDO_USER/Noah0302sTech bereits vorhanden!"
			fi

			#--- Folder
				if [ ! -d /home/$SUDO_USER/Noah0302sTech/$folderVar ]; then
					mkdir /home/$SUDO_USER/Noah0302sTech/$folderVar > /dev/null 2>&1
				else
					echo "Ordner /home/$SUDO_USER/Noah0302sTech/$folderVar bereits vorhanden!"
				fi

			#--- Sub Folder
				if [ ! -d /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolderVar ]; then
					mkdir /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolderVar > /dev/null 2>&1
				else
					echo "Ordner /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolderVar bereits vorhanden!"
				fi

				#--- Folder1
					if [ ! -d /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolderVar/$folder1 ]; then
						mkdir /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolderVar/$folder1 > /dev/null 2>&1
					else
						echo "Ordner /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolderVar/$folder1 bereits vorhanden!"
					fi


				#--- Folder2
					if [ ! -d /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolderVar/$folder2 ]; then
						mkdir /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolderVar/$folder2 > /dev/null 2>&1
					else
						echo "Ordner /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolderVar/$folder2 bereits vorhanden!"
					fi

				#--- Folder3
					if [ ! -d /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolderVar/$folder3 ]; then
						mkdir /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolderVar/$folder3 > /dev/null 2>&1
					else
						echo "Ordner /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolderVar/$folder3 bereits vorhanden!"
					fi
	stop_spinner $?

#----- Move Bash-Script
	start_spinner "Verschiebe Bash-Skript..."
		#--- Bash Installer
			if [ ! -f /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolderVar/$folder1/$bashInstaller ]; then
				mv /home/$SUDO_USER/$bashInstaller /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolderVar/$folder1/$bashInstaller > /dev/null 2>&1
			else
				echo "Die Datei /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolderVar/$bashInstaller ist bereits vorhanden!"
			fi

		#--- Bash Executer
			if [ ! -f /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolderVar/$folder2/$bashExecuter ]; then
				mv /home/$SUDO_USER/$bashExecuter /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolderVar/$folder2/$bashExecuter > /dev/null 2>&1
			else
				echo "Die Datei /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolderVar/$folder2/$bashExecuter ist bereits vorhanden!"
			fi

		#--- Docker Compose
			if [ ! -f /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolderVar/$folder3/$composeFile ]; then
				mv /home/$SUDO_USER/$composeFile /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolderVar/$folder3/$composeFile > /dev/null 2>&1
			else
				echo "Die Datei /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolderVar/$folder3/$composeFile ist bereits vorhanden!"
			fi
	stop_spinner $?