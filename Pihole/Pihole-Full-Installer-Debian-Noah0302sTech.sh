#!/bin/bash
#	Made by Noah0302sTech
#	chmod +x Pihole-Full-Installer-Debian-Noah0302sTech.sh && sudo bash Pihole-Full-Installer-Debian-Noah0302sTech.sh
#	 wget https://raw.githubusercontent.com/Noah0302sTech/Bash-Skripte/master/Pihole/Pihole-Full-Installer-Debian-Noah0302sTech.sh && sudo bash Pihole-Full-Installer-Debian-Noah0302sTech.sh

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



		#----- echoEnd
				function echoEnd {
					echo
					echo
					echo
				}



	#----- Refresh Packages
		start_spinner "Aktualisiere Package-Listen..."
			sudo apt update > /dev/null 2>&1
		stop_spinner $?
		echoEnd

#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#





#----- Install Curl
	start_spinner "Installiere Curl..."
		apt install curl -y > /dev/null 2>&1
	stop_spinner $?



#----- Install Pihole
	echo "Pihole....."
	sleep 3

	#--- Curl Pihole
		echo "Installiere Pihole..."
		sleep 1
		curl -sSL https://install.pi-hole.net | bash

	#--- Change Pihole Password
		echo
		echo "Gib ein neues Pihole-Passwort ein:"
		pihole -a -p
	echoEnd
	echoEnd


#----- Install Pihole-Updater
	echo "Pihole-Updater....."

	while IFS= read -n1 -r -p "Möchtest du Pihole-Updater installieren? [y]es|[n]o: " && [[ $REPLY != q ]]; do
	case $REPLY in
		y)  #--- Curl Pihole-Updater
				start_spinner "Installiere Pihole-Updater..."
					wget https://raw.githubusercontent.com/Noah0302sTech/Bash-Skripte/master/Pihole/Updater/Pihole-Updater-Installer-Debian-Noah0302sTech.sh > /dev/null 2>&1
				stop_spinner $?
				bash ./Pihole-Updater-Installer-Debian-Noah0302sTech.sh

			break;;
		n)  echo
			
			break;;
		*)  echo
			echo "Antoworte mit y oder n";;
	esac
	done
	echoEnd
	echoEnd



#----- Install Unbound
	echo "Unbound....."

	while IFS= read -n1 -r -p "Möchtest du Unbound installieren? [y]es|[n]o: " && [[ $REPLY != q ]]; do
	case $REPLY in
		y)  #--- Curl Unbound-Installer
				start_spinner "Installiere Unbound..."
					wget https://raw.githubusercontent.com/Noah0302sTech/Bash-Skripte/master/Pihole/Unbound/Unbound-Installer-Noah0302sTech.sh > /dev/null 2>&1
				stop_spinner $?
				bash ./Unbound-Installer-Noah0302sTech.sh

			break;;
		n)  echo
			
			break;;
		*)  echo
			echo "Antoworte mit y oder n";;
	esac
	done
	echoEnd
	echoEnd



#----- Install KeepAliveD
	echo "KeepAliveD....."

	while IFS= read -n1 -r -p "Möchtest du KeepAliveD installieren? [y]es|[n]o: " && [[ $REPLY != q ]]; do
	case $REPLY in
		y)  #--- Curl Unbound-Installer
				start_spinner "Installiere KeepAliveD..."
					wget https://raw.githubusercontent.com/Noah0302sTech/Bash-Skripte/master/Pihole/KeepAliveD/KeepAliveD-Installer-Noah0302sTech.sh > /dev/null 2>&1
				stop_spinner $?
				bash ./KeepAliveD-Installer-Noah0302sTech.sh

			break;;
		n)  echo
			
			break;;
		*)  echo
			echo "Antoworte mit y oder n";;
	esac
	done
	echoEnd
	echoEnd





#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#

#----- Variables
	folderVar=Pihole
		subFolderVar=Full-Installer
			shPrimaryVar=Pihole-Full-Installer-Debian-Noah0302sTech.sh
		subFolder2Var=Updater
			sh2Var=Pihole-Updater-Installer-Debian-Noah0302sTech.sh
		subFolder3Var=Unbound
			sh3Var=Unbound-Installer-Noah0302sTech.sh
		subFolder4Var=KeepAlived
			sh4Var=KeepAliveD-Installer-Noah0302sTech.sh

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

		#--- Sub Folder2 Variable
			if [ ! -d /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolder2Var ]; then
				mkdir /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolder2Var > /dev/null 2>&1
			else
				echo "Ordner /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolder2Var bereits vorhanden!"
			fi

		#--- Sub Folder3 Variable
			if [ ! -d /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolder3Var ]; then
				mkdir /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolder3Var > /dev/null 2>&1
			else
				echo "Ordner /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolder3Var bereits vorhanden!"
			fi

		#--- Sub Folder4 Variable
			if [ ! -d /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolder4Var ]; then
				mkdir /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolder4Var > /dev/null 2>&1
			else
				echo "Ordner /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolder4Var bereits vorhanden!"
			fi
	stop_spinner $?

#----- Move Bash-Script
	start_spinner "Verschiebe Bash-Skript..."
		#--- Primary Script Variable
			if [ ! -f /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolderVar/$shPrimaryVar ]; then
				mv /home/$SUDO_USER/$shPrimaryVar /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolderVar/$shPrimaryVar > /dev/null 2>&1
			else
				echo "Die Datei /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolderVar/$shPrimaryVar ist bereits vorhanden!"
			fi

		#--- sh2Var Script Variable
			if [ ! -f /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolder2Var/$sh2Var ]; then
				mv /home/$SUDO_USER/$sh2Var /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolder2Var/$sh2Var > /dev/null 2>&1
			else
				echo "Die Datei /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolder2Var/$sh2Var ist bereits vorhanden!"
			fi

		#--- sh3Var Script Variable
			if [ ! -f /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolder3Var/$sh3Var ]; then
				mv /home/$SUDO_USER/$sh3Var /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolder3Var/$sh3Var > /dev/null 2>&1
			else
				echo "Die Datei /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolder3Var/$sh3Var ist bereits vorhanden!"
			fi

		#--- sh4Var Script Variable
			if [ ! -f /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolder4Var/$sh4Var ]; then
				mv /home/$SUDO_USER/$sh4Var /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolder4Var/$sh4Var > /dev/null 2>&1
			else
				echo "Die Datei /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolder4Var/$sh4Var ist bereits vorhanden!"
			fi
	stop_spinner $?