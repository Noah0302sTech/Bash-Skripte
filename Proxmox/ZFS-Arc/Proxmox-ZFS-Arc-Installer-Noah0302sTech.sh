#!/bin/bash
# Made by Noah0302sTech
# chmod +x Proxmox-ZFS-Arc-Installer-Noah0302sTech.sh && bash Proxmox-ZFS-Arc-Installer-Noah0302sTech.sh

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

#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#





#----- UpdateZFS Function
	function updateZfsConf {
		start_spinner "Passe zfs.conf an..."
			echo "options zfs zfs_arc_min=$zfsMinimumRounded
options zfs zfs_arc_max=$zfsMaximumRounded" > /etc/modprobe.d/zfs.conf
		stop_spinner $?

		start_spinner "Update InitramFS..."
			update-initramfs -u > /dev/null 2>&1
		stop_spinner $?

		echo "Neue ZFS-Arc-Size:"
		cat /etc/modprobe.d/zfs.conf
    }



#----- UpdateZFS-NonP Function
	function updateZfsConfNonP {
		echo "$zfsMinimumRounded" >> /sys/module/zfs/parameters/zfs_arc_min;
		echo "$zfsMaximumRounded" >> /sys/module/zfs/parameters/zfs_arc_max;

		echo "Neue ZFS-Arc-Size:"
		cat /proc/spl/kstat/zfs/arcstats | grep -w c_min
		cat /proc/spl/kstat/zfs/arcstats | grep -w c_max
    }





#----- Update Packages
	start_spinner "Update Package-Listen..."
		apt update -y > /dev/null 2>&1
	stop_spinner $?
	echo
	echo



#----- Variables
	zfsMultiplier=1073741824
	zfsMinimum=1.0
	zfsMaximum=8.0



#----- Prompt for custom values
	read -p "Gib ZFS-Arc-Minimum in GB an [default: $zfsMinimum]: " input
	zfsMinimum=${input:-$zfsMinimum}
	read -p "Gib ZFS-Arc-Maximum in GB an [default: $zfsMaximum]: " input
	zfsMaximum=${input:-$zfsMinimum}
	echo
	echo


#----- Calculation
	zfsMinimumCalculated=$(echo "$zfsMinimum*$zfsMultiplier" | bc)
	zfsMaximumCalculated=$(echo "$zfsMaximum*$zfsMultiplier" | bc)
	zfsMinimumRounded=$(printf "%.0f" "$zfsMinimumCalculated")
	zfsMaximumRounded=$(printf "%.0f" "$zfsMaximumCalculated")



#----- Ask for Commit
	while true; do
		read -p "Möchtest du die Änderungen jetzt anwenden? (Y/N)" yn
		case $yn in
			[Yy]* ) updateZfsConf;
					break;;
			[Nn]* )	break;;
			* ) echo "Ja (Y/y) oder nein (N/n)";;
		esac
	done
	echo
	echo



#----- Ask for Reboot
	while true; do
		read -p "Möchtest du jetzt neu starten, um die Änderungen anzuwenden? (Y/N)" yn
		case $yn in
			[Yy]* ) echo "Reboot in 10 Sekunden! (STRG+C zum abbrechen)"
					sleep 10;
					reboot;
					break;;
			[Nn]* )	break;;
			* ) echo "Ja (Y/y) oder nein (N/n)";;
		esac
	done
	echo
	echo



#----- Configure Non-Persistant
	while true; do
		read -p "Möchtest du die Änderungen schon vor dem Neustart anwenden? (Y/N)" yn
		case $yn in
			[Yy]* ) updateZfsConfNonP;
					break;;
			[Nn]* ) break;;
			* ) echo "Ja (Y/y) oder nein (N/n)";;
		esac
	done
	echo
	echo



#----- Download ZFS-Config-Script
	#--- Install WGET
		start_spinner "Installiere WGET..."
			apt install wget -y > /dev/null 2>&1
		stop_spinner $?

	#--- Download Script File
		start_spinner "Downloade Proxmox-ZFS-Arc-Config-Noah0302sTech.sh..."
			wget https://raw.githubusercontent.com/Noah0302sTech/Bash-Skripte/master/Proxmox/ZFS-Arc/Proxmox-ZFS-Arc-Config-Noah0302sTech.sh > /dev/null 2>&1
		stop_spinner $?





#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#

#----- Variables
	folderVar=Proxmox
	subFolderVar=ZFS-Arc
	shPrimaryVar=Proxmox-ZFS-Arc-Installer-Noah0302sTech.sh
	shSecondaryVar=Proxmox-ZFS-Arc-Config-Noah0302sTech.sh

#----- Create Folders
	start_spinner "Erstelle Verzeichnisse..."
		#--- /root/Noah0302sTech
			if [ ! -d /root/Noah0302sTech ]; then
				mkdir /root/Noah0302sTech > /dev/null 2>&1
			else
				echo "Ordner /root/Noah0302sTech bereits vorhanden!"
			fi

		#--- Folder Variable
			if [ ! -d /root/Noah0302sTech/$folderVar ]; then
				mkdir /root/Noah0302sTech/$folderVar > /dev/null 2>&1
			else
				echo "Ordner /root/Noah0302sTech/$folderVar bereits vorhanden!"
			fi

		#--- Sub Folder Variable
			if [ ! -d /root/Noah0302sTech/$folderVar/$subFolderVar ]; then
				mkdir /root/Noah0302sTech/$folderVar/$subFolderVar > /dev/null 2>&1
			else
				echo "Ordner /root/Noah0302sTech/$folderVar/$subFolderVar bereits vorhanden!"
			fi
	stop_spinner $?

#----- Move Bash-Script
	start_spinner "Verschiebe Bash-Skript..."
		#--- Primary Script Variable
			if [ ! -f /root/Noah0302sTech/$folderVar/$subFolderVar/$shPrimaryVar ]; then
				mv /root/$shPrimaryVar /root/Noah0302sTech/$folderVar/$subFolderVar/$shPrimaryVar > /dev/null 2>&1
			else
				echo "Die Datei /root/Noah0302sTech/$folderVar/$subFolderVar/$shPrimaryVar ist bereits vorhanden!"
			fi

		#--- Secondary Script Variable
			if [ ! -f /root/Noah0302sTech/$folderVar/$subFolderVar/$shSecondaryVar ]; then
				mv /root/$shSecondaryVar /root/Noah0302sTech/$folderVar/$subFolderVar/$shSecondaryVar > /dev/null 2>&1
			else
				echo "Die Datei /root/Noah0302sTech/$folderVar/$subFolderVar/$shSecondaryVar ist bereits vorhanden!"
			fi
	stop_spinner $?