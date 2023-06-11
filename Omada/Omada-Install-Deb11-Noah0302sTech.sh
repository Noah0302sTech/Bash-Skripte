#!/bin/bash
#	Made by Noah0302sTech
#	chmod +x Omada-Install-Deb11-Noah0302sTech.sh && sudo bash Omada-Install-Deb11-Noah0302sTech.sh

#TODO:	Check downloaded File, if its a .deb
#		Add Folder Structure
#		Add Java-Updater

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
		javaUpdaterUrl="https://raw.githubusercontent.com/Noah0302sTech/Bash-Skripte/testing/Omada/Java-Updater/Java-Updater-Installer-Debian-Noah0302sTech.sh"

		folderVar=Omada
			subFolderVar=Java-Updater
				folder1=Updater-Installer
					bashInstaller=Java-Updater-Installer-Debian-Noah0302sTech.sh
				folder2=Updater
					bashExecuter=Java-Updater-Debian-Noah0302sTech.sh
				cronCheck=Cron-Check.txt
		bashInstallerPath="/home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolderVar/$folder1/$bashInstaller"
		bashExecuterPath="/home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolderVar/$folder2/$bashExecuter"
		cronCheckPath="/home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolderVar/$cronCheck"

#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#





#----- Install Java
	#--- Add Sid-Main-Repo
		#-		Note: I add the Debian-Unstable-Repo, since OpenJDK-8 does not come with the Standard-Debian-11-Repository.
		#-		Sadly the Omada-Controller does not yet support newer OpenJDK Versions, so I have to do it that way...
		#-		Hopefully I can skip this step with future Releases!
		echo
		start_spinner "Füge Sid-Main-Repo hinzu, bitte warten..."
			echo "deb http://deb.debian.org/debian/ sid main" | tee -a /etc/apt/sources.list > /dev/null 2>&1
		stop_spinner $?

	#--- Refresh Packages
		start_spinner "Aktualisiere Package-Listen, bitte warten..."
			apt update > /dev/null 2>&1
		stop_spinner $?

	#--- Install OpenJDK-8-Headless
		start_spinner "Installiere OpenJDK-8, bitte warten..."
			DEBIAN_FRONTEND=noninteractive apt install openjdk-8-jre-headless -y > /dev/null 2>&1
		stop_spinner $?

	#--- Remove Sid-Main-Repo
		#-		Note: I remove the Repo here after installing it, so Debian does not upgrade all other Packages to the Unstable-Release.
		#-		With that, Java will not be updated with apt update && apt upgrade, since its missing in the Stable-Repository...ss
		#-		But you can just run the first part of the Script again to update Java.
		#-		I plan on adding a Script that you can run, to check for OpenJDK-8 Updates!
		start_spinner "Entferne Sid-Main-Repo, bitte warten..."
			sed -i '\%^deb http://deb.debian.org/debian/ sid main%d' /etc/apt/sources.list > /dev/null 2>&1
		stop_spinner $?

	#--- Install Java-Updater
		while IFS= read -n1 -r -p "Möchtest du Java-Updater installieren? [y]es|[n]o: " && [[ $REPLY != q ]]; do
		case $REPLY in
			y)  #--- Curl Java-Updater
					start_spinner "Installiere Java-Updater..."
						wget $javaUpdaterUrl > /dev/null 2>&1
					stop_spinner $?
					bash ./Java-Updater-Installer-Debian-Noah0302sTech.sh
				break;;

			n)  echo
				break;;

			*)  echo
				echo "Antoworte mit y oder n";;

		esac
		done
		echo
		echo
		echo
		echo
		echo



#----- Install jsvc curl gnupg2
	#--- Refresh Packages
		start_spinner "Aktualisiere Package-Listen, bitte warten..."
			apt update > /dev/null 2>&1
		stop_spinner $?

	#--- Install jsvc curl gnupg2
		start_spinner "Installiere jsvc curl gnupg2, bitte warten..."
			apt install jsvc curl gnupg2 -y > /dev/null 2>&1
		stop_spinner $?

	echo
	echo



#----- Install MongoDB
	#--- Add apt key
		start_spinner "Füge MongoDB Apt-Key hinzu, bitte warten..."
			curl -fsSL https://www.mongodb.org/static/pgp/server-4.4.asc | apt-key add -  > /dev/null 2>&1
		stop_spinner $?

	#--- Configure sources.list
		start_spinner "Füge MongoDB-Repo hinzu, bitte warten..."
			echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-4.4.list > /dev/null 2>&1
		stop_spinner $?

	#--- Refresh Packages
		start_spinner "Aktualisiere Package-Listen, bitte warten..."
			apt update > /dev/null 2>&1
		stop_spinner $?

	#--- Install MongoDB
		start_spinner "Installiere Mongo-DB, bitte warten..."
			apt install mongodb-org -y > /dev/null 2>&1
		stop_spinner $?

	#--- Enable MongoDB and show Status
		start_spinner "Aktiviere Mongo-DB, bitte warten..."
			systemctl enable mongod --now > /dev/null 2>&1
			systemctl status mongod > /dev/null 2>&1
		stop_spinner $?

	echo
	echo



#----- Install Omada
	#--- Create directory
		start_spinner "Erstelle Omada-Directory, bitte warten..."
			mkdir /home/$SUDO_USER/Omada > /dev/null 2>&1
			if [ -d /home/$SUDO_USER/Omada ]; then
				cd /home/$SUDO_USER/Omada
			else
				echo "Failed to create directory for Omada"
				exit 1
			fi
		stop_spinner $?

	#--- Prompt user for the Omada download URL or use the default if left blank
		read -t 10 -p "Füge die Download-URL für Omada_SDN_Controller_vX.X.X_Linux_x64.deb hier ein (Leer oder warte 10 Sekunden für v5.9.9): " omada_url
		if [ -z "$omada_url" ]; then
			omada_url="https://static.tp-link.com/upload/software/2023/202303/20230321/Omada_SDN_Controller_v5.9.31_Linux_x64.deb"
		fi
		echo "Gewählte Version: $omada_url"

	#--- Download selcted Omada-Version
		start_spinner "Downloade Omada-Controller, bitte warten..."
			apt install wget -y > /dev/null 2>&1
			wget "$omada_url" > /dev/null 2>&1
		stop_spinner $?

	#--- Install downloaded Omada-Version
		echo
		#start_spinner "Installiere Omada-Controller, bitte warten..."
		apt install ./*.deb
		#stop_spinner $?
		echo


	#----- Moving Bash-Script
		mv /home/$SUDO_USER/Omada-Install-Deb11-Noah0302sTech.sh /home/$SUDO_USER/Omada/Omada-Install-Deb11-Noah0302sTech.sh > /dev/null 2>&1

	echo
	echo



#----- Install Java-Updater
