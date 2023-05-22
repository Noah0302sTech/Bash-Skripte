#!/bin/bash
# Made by Noah0302sTech
# chmod +x Proxmox-UpdateUpgrade-Installer-Noah0302sTech.sh && bash Proxmox-UpdateUpgrade-Installer-Noah0302sTech.sh

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
		url="https://raw.githubusercontent.com/Noah0302sTech/Bash-Skripte/master/Proxmox/Update-Upgrade/Proxmox-UpdateUpgrade-Noah0302sTech.sh"
		folderVar=Proxmox
			subFolderVar=Update-Upgrade
				folder1=Installer
					bashInstaller=Proxmox-UpdateUpgrade-Installer-Noah0302sTech.sh
				folder2=Updater
					bashExecuter=Proxmox-UpdateUpgrade-Noah0302sTech.sh
				cronCheck=Cron-Check.txt

#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#





#----- Create Bash-File
	start_spinner "Erstelle Proxmox-Updater Bash-File..."
		touch /root/Proxmox-UpdateUpgrade-Installer-Noah0302sTech.sh
		touch /root/Cron-Check.txt
	stop_spinner $?



#----- Variables
	cronVariable="0 6 * * *"



#----- Prompt for custom values
	read -p "Passe den Cron-Job an [default 6 Uhr täglich: $cronVariable]: " input
	cronVariable=${input:-$cronVariable}
	echo
	echo

	#--- Echo Commands into Proxmox-UpdateUpgrade-Noah0302sTech.sh
		echo "#!/bin/bash
# Made by Noah0302sTech

#Update
	"'upgradeOutput=$(apt-get update && apt-get dist-upgrade -y 2>&1)'"

#Debug
	echo "Proxmox-Updater Cron-Job ran @" >> /root/Noah0302sTech/$folderVar/$subFolderVar/$cronCheck
	date >> /root/Noah0302sTech/$folderVar/$subFolderVar/$cronCheck
	echo "'$upgradeOutput'" >> /root/Noah0302sTech/$folderVar/$subFolderVar/$cronCheck
	echo '' >> /root/Noah0302sTech/$folderVar/$subFolderVar/$cronCheck" >> /root/Proxmox-UpdateUpgrade-Noah0302sTech.sh

	#--- Make Proxmox-UpdateUpgrade-Installer-Noah0302sTech.sh executable
		start_spinner "Mache Proxmox-UpdateUpgrade-Noah0302sTech.sh ausführbar..."
			chmod +x /root/Proxmox-UpdateUpgrade-Noah0302sTech.sh
		stop_spinner $?
	echo
	echo



#----- Create Crontab
	start_spinner "Erstelle Crontab..."
		touch /etc/cron.d/apt-UpdateUpgrade-Noah0302sTech
		echo "#Update && Upgrade for APT by Noah0302sTech
$cronVariable root /root/Noah0302sTech/$folderVar/$subFolderVar/$folder2/$bashExecuter" > /etc/cron.d/apt-UpdateUpgrade-Noah0302sTech
	stop_spinner $?
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

			#--- Folder
				if [ ! -d /root/Noah0302sTech/$folderVar ]; then
					mkdir /root/Noah0302sTech/$folderVar > /dev/null 2>&1
				else
					echo "Ordner /root/Noah0302sTech/$folderVar bereits vorhanden!"
				fi

			#--- Sub Folder
				if [ ! -d /root/Noah0302sTech/$folderVar/$subFolderVar ]; then
					mkdir /root/Noah0302sTech/$folderVar/$subFolderVar > /dev/null 2>&1
				else
					echo "Ordner /root/Noah0302sTech/$folderVar/$subFolderVar bereits vorhanden!"
				fi

				#--- Folder1
					if [ ! -d /root/Noah0302sTech/$folderVar/$subFolderVar/$folder1 ]; then
						mkdir /root/Noah0302sTech/$folderVar/$subFolderVar/$folder1 > /dev/null 2>&1
					else
						echo "Ordner /root/Noah0302sTech/$folderVar/$subFolderVar/$folder1 bereits vorhanden!"
					fi


				#--- Folder2
					if [ ! -d /root/Noah0302sTech/$folderVar/$subFolderVar/$folder2 ]; then
						mkdir /root/Noah0302sTech/$folderVar/$subFolderVar/$folder2 > /dev/null 2>&1
					else
						echo "Ordner /root/Noah0302sTech/$folderVar/$subFolderVar/$folder2 bereits vorhanden!"
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

		#--- Bash Executer
			if [ ! -f /root/Noah0302sTech/$folderVar/$subFolderVar/$folder2/$bashExecuter ]; then
				mv /root/$bashExecuter /root/Noah0302sTech/$folderVar/$subFolderVar/$folder2/$bashExecuter > /dev/null 2>&1
			else
				echo "Die Datei /root/Noah0302sTech/$folderVar/$subFolderVar/$folder2/$bashExecuter ist bereits vorhanden!"
			fi

		#--- Cron Check
			if [ ! -f /root/Noah0302sTech/$folderVar/$subFolderVar/$cronCheck ]; then
				mv /root/$cronCheck /root/Noah0302sTech/$folderVar/$subFolderVar/$cronCheck > /dev/null 2>&1
			else
				echo "Die Datei /root/Noah0302sTech/$folderVar/$subFolderVar/$cronCheck ist bereits vorhanden!"
			fi
	stop_spinner $?