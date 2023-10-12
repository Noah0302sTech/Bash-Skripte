#!/bin/bash
#	Made by Noah0302sTech
#	chmod +x Pihole-Updater-Installer-Debian-Noah0302sTech.sh && sudo bash Pihole-Updater-Installer-Debian-Noah0302sTech.sh

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
			sudo apt update -y > /dev/null 2>&1
		stop_spinner $?
		echo
		echo



	#----- Variables
		folderVar=Pihole
			subFolderVar=Updater
				installerFolderVar=Updater-Installer
					shPrimaryVar=Pihole-Updater-Installer-Debian-Noah0302sTech.sh
				shSecondaryVar=Pihole-Updater.sh
				shTertiaryVar=Cron-Check.txt

#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#





#----- Create Bash-File
	start_spinner "Erstelle Pihole-Updater Files..."
		touch Pihole-Updater.sh
		touch Cron-Check.txt
	stop_spinner $?

	#--- Echo Commands into Pihole-Updater.sh
		echo "#!/bin/bash

#Pihole Update
	echo "Update Pihole..."
		sleep 1
		"'piholeUpdateOutput=$(pihole -up 2>&1)'"
	echo "'$piholeUpdateOutput'"
	echo
	echo



#Pihole Gravity
	echo "Update Gravity..."
		sleep 1
		"'piholeGravityOutput=$(pihole -g 2>&1)'"
	echo "'$piholeGravityOutput'"
	echo
	echo

#Debug
	echo "----------" >> /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolderVar/Cron-Check.txt
	echo "'Pihole-Updater Cron-Job ran @'" >> /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolderVar/Cron-Check.txt
	date >> /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolderVar/Cron-Check.txt
	echo "Update Pihole..." >> /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolderVar/Cron-Check.txt
		echo "'$piholeUpdateOutput'" >> /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolderVar/Cron-Check.txt
	echo "Update Gravity..." >> /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolderVar/Cron-Check.txt
		echo "'$piholeGravityOutput'" >> /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolderVar/Cron-Check.txt
	echo "----------" >> /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolderVar/Cron-Check.txt
	echo '' >> /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolderVar/Cron-Check.txt" > /home/$SUDO_USER/$shSecondaryVar

	#--- Make Pihole-Updater.sh executable
		start_spinner "Mache Pihole-Updater.sh ausführbar..."
			chmod +x Pihole-Updater.sh
		stop_spinner $?
	echo
	echo



#----- Create Crontab
	start_spinner "Erstelle Crontab..."
		touch /etc/cron.d/pihole-updater-Noah0302sTech
	stop_spinner $?

	#--- Variables
		cronVariable="0 8 * * *"

		#- Prompt for custom values
			read -p "Passe den Cron-Job an [default 8 Uhr täglich: $cronVariable]: " input
			cronVariable=${input:-$cronVariable}
	
	#--- Adjust Schedule
		start_spinner "Passe Crontab an..."
			echo "#Update for Pihole by Noah0302sTech
"'PATH="/usr/local/bin:/usr/bin:/bin"'"
$cronVariable root /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolderVar/Pihole-Updater.sh" > /etc/cron.d/pihole-updater-Noah0302sTech
		stop_spinner $?
	echo
	echo



#----- Create Alias
    if grep -q "^alias ccPiholeUpdater=" /home/$SUDO_USER/.bashrc; then
		echo "Der Alias existiert bereits in /home/$SUDO_USER/.bashrc"
	else
		start_spinner "Erstelle Alias..."
			echo "


#Pihole-Updater by Noah0302sTech
alias piholeUpdater='sudo /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolderVar/Pihole-Updater.sh'
alias ccPiholeUpdater='cat /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolderVar/Cron-Check.txt'
"  >> /home/$SUDO_USER/.bashrc
		stop_spinner $?
	fi
	echo
	echo



#----- Create MOTD
	if grep -q "^Pihole" /etc/motd; then
		echo "Der MOTD Eintrag exisitert bereits in /etc/motd"
	else
		start_spinner "Passe MOTD an..."
			echo "----- Pihole -----
Manual-Run:	piholeUpdater
Cron-Check:	ccPiholeUpdater
" >> /etc/motd
		stop_spinner $?
	fi
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

		#--- Folder Variable
			if [ ! -d /home/$SUDO_USER/Noah0302sTech/$folderVar ]; then
				mkdir /home/$SUDO_USER/Noah0302sTech/$folderVar > /dev/null 2>&1
			else
				echo "Ordner /home/$SUDO_USER/Noah0302sTech/$folderVar bereits vorhanden!"
			fi

		#--- Sub Folder Variable
			if [ ! -d /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolderVar ]; then
				mkdir /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolderVar > /dev/null 2>&1
			else
				echo "Ordner /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolderVar bereits vorhanden!"
			fi

		#--- Installer Folder Variable
			if [ ! -d /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolderVar/$installerFolderVar ]; then
				mkdir /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolderVar/$installerFolderVar > /dev/null 2>&1
			else
				echo "Ordner /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolderVar/$installerFolderVar bereits vorhanden!"
			fi
	stop_spinner $?

#----- Move Bash-Script
	start_spinner "Verschiebe Bash-Skript..."
		#--- Primary Script Variable
			if [ ! -f /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolderVar/$shPrimaryVar/$installerFolderVar ]; then
				mv /home/$SUDO_USER/$shPrimaryVar /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolderVar/$installerFolderVar/$shPrimaryVar > /dev/null 2>&1
			else
				echo "Die Datei /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolderVar/$shPrimaryVar ist bereits vorhanden!"
			fi

		#--- Secondary Script Variable
			if [ ! -f /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolderVar/$shSecondaryVar ]; then
				mv /home/$SUDO_USER/$shSecondaryVar /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolderVar/$shSecondaryVar > /dev/null 2>&1
			else
				echo "Die Datei /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolderVar/$shSecondaryVar ist bereits vorhanden!"
			fi

		#--- Tertiary Script Variable
			if [ ! -f /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolderVar/$shTertiaryVar ]; then
				mv /home/$SUDO_USER/$shTertiaryVar /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolderVar/$shTertiaryVar > /dev/null 2>&1
			else
				echo "Die Datei /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolderVar/$shTertiaryVar ist bereits vorhanden!"
			fi
	stop_spinner $?