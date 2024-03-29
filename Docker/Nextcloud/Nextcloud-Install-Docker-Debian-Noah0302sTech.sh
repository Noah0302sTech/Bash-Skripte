#!/bin/bash
#	Made by Noah0302sTech
#	chmod +x Nextcloud-Install-Docker-Debian-Noah0302sTech.sh && sudo bash Nextcloud-Install-Docker-Debian-Noah0302sTech.sh
#	wget https://raw.githubusercontent.com/Noah0302sTech/Bash-Skripte/master/Docker/Nextcloud/Nextcloud-Install-Docker-Debian-Noah0302sTech.sh && sudo bash Nextcloud-Install*

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
		echoEnd



	#----- Variables
		urlVar=https://raw.githubusercontent.com/Noah0302sTech/Bash-Skripte/master/Docker/Nextcloud/Nextcloud-Configurator/Nextcloud-Config-Docker-Noah0302sTech.sh


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

	#--- Install Apparmor (Only needed on specific Systems like Hetzner VServer)
		start_spinner "Installiere Apparmor, falls benötigt..."
			apt install apparmor -y > /dev/null 2>&1
		stop_spinner $?
	echoEnd



#----- Docker-Compose
	#--- Set default values for Docker-Compose
		mysqlRootVar=sqlrootpassword
		mysqlPasswordVar=sqlpassword
		nextcloud_dataVar=/var/www/html
		mariaDB_dataVar=/var/lib/mysql

	#--- Prompt user for custom values
		read -p "MariaDB-Root-Passwort eigeben [default: $mysqlRootVar]: " input
		mysqlRootVar=${input:-$mysqlRootVar}
		read -p "MariaDB-Passwort eigeben [default: $mysqlPasswordVar]: " input
		mysqlPasswordVar=${input:-$mysqlPasswordVar}
		echo "Der Speicherpfad von Nextcloud-Data und Maria-DB darf nicht der selbe Ordner sein!"
		read -p "Nextcloud-Data Speicherpfad eigeben [default: $nextcloud_dataVar]: " input
		nextcloud_dataVar=${input:-$nextcloud_dataVar}
		read -p "Maria-DB Speicherpfad eigeben [default: $mariaDB_dataVar]: " input
		mariaDB_dataVar=${input:-$mariaDB_dataVar}

			#- Check if the directories exist
				if [ ! -d "$nextcloud_dataVar" ]; then
					echo "Erstelle $nextcloud_dataVar..."
					mkdir -p "$nextcloud_dataVar"
					chown -R www-data:www-data "$nextcloud_dataVar"
				fi

				if [ ! -d "$mariaDB_dataVar" ]; then
					echo "Erstelle $mariaDB_dataVar..."
					mkdir -p "$mariaDB_dataVar"
					chown -R $SUDO_USER:$SUDO_USER "$mariaDB_dataVar"
				fi

	#--- Create a Docker Compose file
		start_spinner "Erstelle Docker-Compose-File..."
			touch docker-compose.yml > /dev/null 2>&1
		echo "version: '3'
services:
  db:
    image: mariadb:latest
    container_name: $SUDO_USER-mariadb
    environment:
      - MYSQL_ROOT_PASSWORD=$mysqlRootVar
      - MYSQL_PASSWORD=$mysqlPasswordVar
      - MYSQL_DATABASE=nextclouddb
      - MYSQL_USER=nextcloud
    volumes:
      - db_data:/var/lib/mysql
    restart: unless-stopped

  nextcloud:
    image: nextcloud:latest
    container_name: $SUDO_USER-nextcloud
    ports:
      - 8080:80
    environment:
      - MYSQL_HOST=db
      - MYSQL_USER=nextcloud
      - MYSQL_PASSWORD=$mysqlPasswordVar
      - MYSQL_DATABASE=nextclouddb
    volumes:
      - nextcloud_data:/var/www/html
    restart: unless-stopped
    depends_on:
      - db

volumes:
  db_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: $mariaDB_dataVar

  nextcloud_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: $nextcloud_dataVar
" > docker-compose.yml
		stop_spinner $?
	echoEnd



#----- Start the Nextcloud server
	start_spinner "Starte Nextcloud-Server..."
		docker-compose up -d > /dev/null 2>&1
	stop_spinner $?
	docker ps
	echoEnd



#----- Configure the Nextcloud Server
	start_spinner "Erstelle Nextcloud-Config-Skript..."
		apt install wget -y > /dev/null 2>&1
		wget $urlVar > /dev/null 2>&1
		sed -i -e 's#inputFromInstaller#'"$nextcloud_dataVar"'#g' "$bashConfigurator"
		chmod +x $bashConfigurator > /dev/null 2>&1
	stop_spinner $?
	echoEnd



#----- Create Alias
    if grep -q "^alias nextcloudConfigure=" /home/$SUDO_USER/.bashrc; then
		echo "Der Alias existiert bereits in /home/$SUDO_USER/.bashrc"
	else
		start_spinner "Erstelle Alias..."
			echo "
#Nextcloud-Docker
alias nextcloudConfigure='sudo bash $bashConfiguratorPath'"  >> /home/$SUDO_USER/.bashrc
		stop_spinner $?
	fi
	echoEnd



#----- Create MOTD
	if grep -q "^Nextcloud" /etc/motd; then
		echo "Der MOTD Eintrag exisitert bereits in /etc/motd"
	else
		start_spinner "Passe MOTD an..."
			echo "----- Nextcloud -----
Configure config.php:   nextcloudConfigure
" >> /etc/motd
		stop_spinner $?
	fi
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

				#--- Docker
					if [ ! -d $parentFolderPath ]; then
						mkdir $parentFolderPath > /dev/null 2>&1
					else
						echo "Ordner $parentFolderPath bereits vorhanden!"
					fi

					#--- Nextcloud
						if [ ! -d $subFolderPath ]; then
							mkdir $subFolderPath > /dev/null 2>&1
						else
							echo "Ordner $subFolderPath bereits vorhanden!"
						fi

						#--- Full-Installer
							if [ ! -d $fullInstallerFolderPath ]; then
								mkdir $fullInstallerFolderPath > /dev/null 2>&1
							else
								echo "Ordner $fullInstallerFolderPath bereits vorhanden!"
							fi

						#--- Configurator
							if [ ! -d $bashConfiguratorFolderPath ]; then
								mkdir $bashConfiguratorFolderPath > /dev/null 2>&1
							else
								echo "Ordner $bashConfiguratorFolderPath bereits vorhanden!"
							fi

						#--- Docker-Compose
							if [ ! -d $dockerComposeFolderPath ]; then
								mkdir $dockerComposeFolderPath > /dev/null 2>&1
							else
								echo "Ordner $dockerComposeFolderPath bereits vorhanden!"
							fi

						#--- Uninstaller
							if [ ! -d $unInstallerFolderPath ]; then
								mkdir $unInstallerFolderPath > /dev/null 2>&1
							else
								echo "Ordner $unInstallerFolderPath bereits vorhanden!"
							fi

		stop_spinner $?

	#----- Move Files
		start_spinner "Verschiebe Files..."
				#--- Full-Installer
					if [ ! -f $fullInstallerPath ]; then
						mv /home/$SUDO_USER/$fullInstaller $fullInstallerFolderPath > /dev/null 2>&1
					else
						echo "Die Datei $fullInstaller ist bereits in $fullInstallerFolderPath vorhanden!"
					fi

				#--- Configurator
					if [ ! -f $bashConfiguratorPath ]; then
						mv /home/$SUDO_USER/$bashConfigurator $bashConfiguratorFolderPath > /dev/null 2>&1
					else
						echo "Die Datei $bashConfigurator ist bereits in $bashConfiguratorFolderPath vorhanden!"
					fi

				#--- Uninstaller
					if [ ! -f $unInstallerPath ]; then
						mv /home/$SUDO_USER/$unInstaller $unInstallerFolderPath > /dev/null 2>&1
					else
						echo "Die Datei $unInstaller ist bereits in $unInstallerFolderPath vorhanden!"
					fi

				#--- Docker-Compose
					if [ ! -f $dockerComposeFilePath ]; then
						mv /home/$SUDO_USER/$dockerComposeFile $dockerComposeFolderPath > /dev/null 2>&1
					else
						echo "Die Datei $dockerComposeFile ist bereits in $dockerComposeFolderPath vorhanden!"
					fi

		stop_spinner $?
		echoEnd




#----- Info for Configurator
	echo "Um NACH DER INSTALLATION  über das Webinterface die Nextcloud-Config anzupassen, starte das Nextcloud-Config-Skript mit:"
	echo "sudo bash $bashConfiguratorPath, oder nextcloudConfigure nach einer Neuverbindung per SSH"
	echo "ERST NACH DER INSTALLATION MÖGLICH!"