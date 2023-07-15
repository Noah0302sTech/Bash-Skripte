#!/bin/bash
# Made by Noah0302sTech
# chmod +x SMBConsumeFolder-Paperless-Noah0302sTech.sh && sudo bash SMBConsumeFolder-Paperless-Noah0302sTech.sh
#	wget https://raw.githubusercontent.com/Noah0302sTech/Bash-Skripte/testing/Docker/PaperlessNGX/SMBConsumeFolder-Paperless-Noah0302sTech.sh && sudo bash SMBConsumeFolder-Paperless-Noah0302sTech.sh

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

		parentFolder="Docker"
			subFolder="PaperlessNGX"
				folder1="SMB-Consume"
					folder1bashScript="SMBConsumeFolder-Paperless-Noah0302sTech.sh"

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



#----- Install SMB-Utils
    start_spinner "Installiere SMB-Utilities..."
        apt install cifs-utils -y > /dev/null 2>&1
    stop_spinner $?

	echoEnd



#----- Set default values
    FILENAME=smbcreds
    SHARE=192.168.x.x/SMB-Share
    USERNAME=username
    PASSWORD=password1
    smbFolderPath="/mnt/SMB-Share"



#----- Prompt for custom values
    read -p "Gib den Namen für das versteckte Passwort-File ein [default: $FILENAME]: " input
    FILENAME=${input:-$FILENAME}
    read -p "Gib die IP deines Servers ein [default: $SHARE]: " input
    SHARE=${input:-$SHARE}
    read -p "Gib den User-Namen für den SMB-Share ein [default: $USERNAME]: " input
    USERNAME=${input:-$USERNAME}
    read -p "Gib das Passwort für den SMB-Share ein [default: $PASSWORD]: " input
    PASSWORD=${input:-$PASSWORD}
    read -p "Gib den Name für den lokalen SMB-Mount-Folder ein [default: $smbFolderPath]: " input
    smbFolderPath=${input:-$smbFolderPath}

	echoEnd


#----- Create Files

    #--- Password-File
        start_spinner "Erstelle User-Credential-Files..."
            touch /root/.$FILENAME
            echo "username=$USERNAME" > /root/.$FILENAME
            echo "password=$PASSWORD" >> /root/.$FILENAME
        stop_spinner $?
        
        #--- Permissions
            start_spinner "Modifiziere Permissions..."
                chmod 400 /root/.$FILENAME
            stop_spinner $?

    #--- SMB-Mount Folder
		echo "Modifiziere Permissions..."
			if [ ! -d $smbFolderPath ]; then
				mkdir $smbFolderPath
				chown -R root:$SUDO_USER $smbFolderPath
			else
				echo "Ordner $smbFolderPath bereits vorhanden!"
			fi
    
	echoEnd



#----- FSTAB
    start_spinner "Erstelle FStab..."
        touch /etc/fstab
        echo "//$SHARE $smbFolderPath cifs vers=3.0,credentials=/root/.$FILENAME" > /etc/fstab
		systemctl daemon-reload
    stop_spinner $?
    
	echoEnd


#----- Mount SMB-Share
    start_spinner "Mounte das Netzlaufwerk..."
        mount -t cifs -o rw,vers=3.0,credentials=/root/.$FILENAME //$SHARE $smbFolderPath
    stop_spinner $?

	echoEnd



#----- Create Crontab
	start_spinner "Erstelle Crontab..."
		touch /etc/cron.d/paperless-move-Files-to-Consume
	stop_spinner $?

	#--- Variables
		cronVariable="* * * * *"
		paperlessConsume="/home/$SUDO_USER/paperless-ngx/consume"

		#- Prompt for custom values
			read -p "Passe den Cron-Job an [default jede Minute: $cronVariable]: " input
			cronVariable=${input:-$cronVariable}
			read -p "Gib den Paperless-Consume Pfad an: $paperlessConsume]: " input
			paperlessConsume=${input:-$paperlessConsume}
	
	#--- Adjust Schedule
		start_spinner "Passe Crontab an..."
			echo "#Moving of Files from SMB-Share to Paperless-Consume
"'PATH="/usr/local/bin:/usr/bin:/bin"'"
$cronVariable root 'mv $smbFolderPath/*.pdf $paperlessConsume'" > /etc/cron.d/paperless-move-Files-to-Consume
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

					#--- Folder 1
						if [ ! -d $folder1Path ]; then
							mkdir $folder1Path > /dev/null 2>&1
						else
							echo "Ordner $folder1Path bereits vorhanden!"
						fi
	stop_spinner $?

#----- Move Files
	start_spinner "Verschiebe Files..."
		#--- Folder 1 Bash Script
			if [ ! -f $folder1bashScriptPath ]; then
				mv /home/$SUDO_USER/$folder1bashScript $folder1bashScriptPath > /dev/null 2>&1
			else
				echo "Die Datei $folder1bashScriptPath ist bereits vorhanden!"
			fi
	stop_spinner $?