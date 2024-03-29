#!/bin/bash
#	Made by Noah0302sTech
#	chmod +x $folder1bashScript && sudo bash $folder1bashScript

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
			apt update > /dev/null 2>&1
		stop_spinner $?
		echoEnd



	#----- Variables
		urlVar="https://raw.githubusercontent.com/Noah0302sTech/"

		parentFolder="XXXXXXXXXX"
			subFolder="XXXXXXXXXX"
				fullInstallerFolder="XXXXXXXXXX"
					fullInstaller="XXXXXXXXXX"
				folder1="XXXXXXXXXX"
					folder1bashScript="XXXXXXXXXX"
				folder2="XXXXXXXXXX"
					folder2bashScript="XXXXXXXXXX"
				cronCheck="XXXXXXXXXX"

		parentFolderPath="/home/$SUDO_USER/Noah0302sTech/$parentFolder"
			subFolderPath="/home/$SUDO_USER/Noah0302sTech/$parentFolder/$subFolder"
				fullInstallerFolderPath="/home/$SUDO_USER/Noah0302sTech/$parentFolder/$subFolder/$fullInstallerFolder"
					fullInstallerPath="/home/$SUDO_USER/Noah0302sTech/$parentFolder/$fullInstallerFolder/$fullInstaller"
				folder1Path="/home/$SUDO_USER/Noah0302sTech/$parentFolder/$subFolder/$folder1"
					folder1bashScriptPath="/home/$SUDO_USER/Noah0302sTech/$parentFolder/$subFolder/$folder1/$folder1bashScript"
				folder2Path="/home/$SUDO_USER/Noah0302sTech/$parentFolder/$subFolder/$folder2"
					folder2bashScriptPath="/home/$SUDO_USER/Noah0302sTech/$parentFolder/$subFolder/$folder2/$folder2bashScript"
				cronCheckPath="/home/$SUDO_USER/Noah0302sTech/$parentFolder/$subFolder/$cronCheck"

#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#





#----- XXXXXXXXXX
	start_spinner "XXXXXXXXXX..."
		XXXXXXXXXX > /dev/null 2>&1
	stop_spinner $?
	
	echoEnd





#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#

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

					#--- Folder 1
						if [ ! -d $folder1Path ]; then
							mkdir $folder1Path > /dev/null 2>&1
						else
							echo "Ordner $folder1Path bereits vorhanden!"
						fi

					#--- Folder2
						if [ ! -d $folder2Path ]; then
							mkdir $folder2Path > /dev/null 2>&1
						else
							echo "Ordner $folder2Path bereits vorhanden!"
						fi
	stop_spinner $?

#----- Move Files
	start_spinner "Verschiebe Files..."
		#--- Full-Installer
			if [ ! -f $fullInstallerFolderPath ]; then
				mv /home/$SUDO_USER/$fullInstaller $fullInstallerFolderPath > /dev/null 2>&1
			else
				echo "Die Datei $fullInstallerFolderPath ist bereits vorhanden!"
			fi

		#--- Folder 1 Bash Script
			if [ ! -f $folder1bashScriptPath ]; then
				mv /home/$SUDO_USER/$folder1bashScript $folder1bashScriptPath > /dev/null 2>&1
			else
				echo "Die Datei $folder1bashScriptPath ist bereits vorhanden!"
			fi

		#--- Folder 2 Bash Script
			if [ ! -f $folder2bashScriptPath ]; then
				mv /home/$SUDO_USER/$folder2bashScript $folder2bashScriptPath > /dev/null 2>&1
			else
				echo "Die Datei $folder2bashScriptPath ist bereits vorhanden!"
			fi

		#--- Cron-Check.txt
			if [ ! -f $cronCheckPath ]; then
				mv /home/$SUDO_USER/$cronCheck $cronCheckPath > /dev/null 2>&1
			else
				echo "Die Datei $cronCheckPath ist bereits vorhanden!"
			fi
	stop_spinner $?