#!/bin/bash
# Made by Noah0302sTech
# chmod +x Host-SMB-Share-Debian-Noah0302sTech.sh && sudo bash Host-SMB-Share-Debian-Noah0302sTech.sh
#	wget https://raw.githubusercontent.com/Noah0302sTech/Bash-Skripte/testing/SMB/Client/Host-SMB-Share-Debian-Noah0302sTech.sh && sudo bash Host-SMB-Share-Debian-Noah0302sTech.sh



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

		parentFolder="SMB"
			subFolder="Host"
				fullInstallerFolder="Installer"
					fullInstaller="Host-SMB-Share-Debian-Noah0302sTech.sh"
				folder1="SMB-Share-Folder"

		parentFolderPath="/home/$SUDO_USER/Noah0302sTech/$parentFolder"
			fullInstallerFolderPath="/home/$SUDO_USER/Noah0302sTech/$parentFolder/$fullInstallerFolder"
				fullInstallerPath="/home/$SUDO_USER/Noah0302sTech/$parentFolder/$fullInstallerFolder/$fullInstaller"
			subFolderPath="/home/$SUDO_USER/Noah0302sTech/$parentFolder/$subFolder"
				folder1Path="/home/$SUDO_USER/Noah0302sTech/$parentFolder/$subFolder/$folder1"
					updaterInstallerPath="/home/$SUDO_USER/Noah0302sTech/$parentFolder/$subFolder/$folder1/$bashInstaller"
				folder2Path="/home/$SUDO_USER/Noah0302sTech/$parentFolder/$subFolder/$folder2"
					updaterExecuterPath="/home/$SUDO_USER/Noah0302sTech/$parentFolder/$subFolder/$folder2/$updaterExecuter"
				cronCheckPath="/home/$SUDO_USER/Noah0302sTech/$parentFolder/$subFolder/$cronCheck"

#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#



#----- Install SMB-Utils
    start_spinner "Installiere SMB-Utilities..."
        apt install samba > /dev/null 2>&1
    stop_spinner $?

	echoEnd



#----- Set default values
    shareName="SMB-Share"
    shareComment="Beschreibung für Share"
    sharePath=$folder1Path
	smbUser=$SUDO_USER


#----- Prompt for custom values
    read -p "Gib den Namen für den SMB-Share ein [default: $shareName]: " input
    shareName=${input:-$shareName}
    read -p "Gib eine Beschreibung für den SMB-Share an [default: $shareComment]: " input
    shareComment=${input:-$shareComment}
    read -p "Gib den Pfad für den Ordner an, der geschared werden soll [default: $sharePath]: " input
    sharePath=${input:-$sharePath}
    read -p "Gib den User ein, der Zugriff auf den Share haben soll [default: $smbUser]: " input
    smbUser=${input:-$smbUser}

	echoEnd



#----- Create Files
	echo "
[$shareName]
comment= $shareComment
path = $sharePath
browseable  = yes
Read only = no
guest  ok = no
valid users = $smbUser" >> /etc/samba/smb.conf
    systemctl restart smbd
	smbpasswd -a $smbUser

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

					#--- SMB Share Folder
						if [ ! -d $folder1Path ]; then
							mkdir $folder1Path > /dev/null 2>&1
						else
							echo "Ordner $folder1Path bereits vorhanden!"
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
	stop_spinner $?