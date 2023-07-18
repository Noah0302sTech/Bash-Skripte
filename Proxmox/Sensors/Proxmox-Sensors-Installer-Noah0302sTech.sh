#!/bin/bash
# Made by Noah0302sTech
# chmod +x Proxmox-Sensors-Installer-Noah0302sTech.sh && bash Proxmox-Sensors-Installer-Noah0302sTech.sh
#	wget https://raw.githubusercontent.com/Noah0302sTech/Bash-Skripte/testing/Proxmox/Sensors/Proxmox-Sensors-Installer-Noah0302sTech.sh && bash Proxmox-Sensors-Installer-Noah0302sTech.sh

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
			apt update > /dev/null 2>&1
		stop_spinner $?
		echo
		echo

	#----- Variables
		url="https://raw.githubusercontent.com/Noah0302sTech/Bash-Skripte/master/Proxmox/Update-Upgrade/Proxmox-UpdateUpgrade-Noah0302sTech.sh"
		folderVar=Proxmox
			subFolderVar=Sensors
				folder1=Installer
					bashInstaller=Proxmox-Sensors-Installer-Noah0302sTech.sh

#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#





#----- LM-Sensors
	start_spinner "Installiere lm-sensors..."
		apt install lm-sensors -y > /dev/null 2>&1
	stop_spinner $?

#----- Detect Sensors
	echo "Erkenne Sensoren..."
	sleep 1
		sensors-detect

#----- Watch Sensors
	echo "Watche Sensoren..."
	sleep 1
		watch sensors



#----- Question Install htop
	while IFS= read -n1 -r -p "Möchtest du auch 'htop' installieren? [y]es|[n]o: " && [[ $REPLY != q ]]; do
	case $REPLY in
		y)  echo
				start_spinner "Installiere htop..."
					apt install htop -y > /dev/null 2>&1
				stop_spinner $?

			break;;
		n)  echo
				echo "Htop wurde NICHT installiert!"
				
			break;;
		*)  echo
				echo "Antoworte mit y oder n";;
	esac
	done



#----- Create Alias
    if grep -q "^alias watchSensors=" /root/.bashrc; then
		echo "Der Alias existiert bereits in /root/.bashrc"
	else
		start_spinner "Erstelle Alias..."
			echo "


#Sensors
alias watchSensors='watch sensors'
"  >> /root/.bashrc
		stop_spinner $?
	fi
	echo
	echo



#----- Create MOTD
	if grep -q "^Sensors" /etc/motd; then
		echo "Der MOTD Eintrag exisitert bereits in /etc/motd"
	else
		start_spinner "Passe MOTD an..."
			echo "
Show Sensor-Temps:	watchSensors
-----
s" >> /etc/motd
		stop_spinner $?
	fi
	echo
	echo





#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#

#----- Create Folders
	start_spinner "Erstelle Verzeichnisse..."
		#--- /root/Noah0302sTech
			if [ ! -d /root/Noah0302sTech ]; then
				mkdir /root/Noah0302sTech > /dev/null 2>&1
			else
				echo "Ordner /root/Noah0302sTech bereits vorhanden!"
			fi

			#--- Proxmox
				if [ ! -d /root/Noah0302sTech/$folderVar ]; then
					mkdir /root/Noah0302sTech/$folderVar > /dev/null 2>&1
				else
					echo "Ordner /root/Noah0302sTech/$folderVar bereits vorhanden!"
				fi

				#--- Installer
					if [ ! -d /root/Noah0302sTech/$folderVar/$subFolderVar ]; then
						mkdir /root/Noah0302sTech/$folderVar/$subFolderVar > /dev/null 2>&1
					else
						echo "Ordner /root/Noah0302sTech/$folderVar/$subFolderVar bereits vorhanden!"
					fi

					#--- Sensors
						if [ ! -d /root/Noah0302sTech/$folderVar/$subFolderVar/$folder1 ]; then
							mkdir /root/Noah0302sTech/$folderVar/$subFolderVar/$folder1 > /dev/null 2>&1
						else
							echo "Ordner /root/Noah0302sTech/$folderVar/$subFolderVar/$folder1 bereits vorhanden!"
						fi
	stop_spinner $?

#----- Move Bash-Script
	start_spinner "Verschiebe Bash-Skript..."
		#--- Bash Installer
			if [ ! -f /root/Noah0302sTech/$folderVar/$subFolderVar/$folder1/$bashInstaller ]; then
				mv /root/$bashInstaller /root/Noah0302sTech/$folderVar/$subFolderVar/$folder1/$bashInstaller > /dev/null 2>&1
			else
				echo "Die Datei /root/Noah0302sTech/$folderVar/$subFolderVar/$bashInstaller ist bereits vorhanden!"
			fi
	stop_spinner $?