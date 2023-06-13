#!/bin/bash
#	Made by Noah0302sTech
#	chmod +x Docker-SystemPrune-Installer-Noah0302sTech.sh && sudo bash Docker-SystemPrune-Installer-Noah0302sTech.sh

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
			apt update -y > /dev/null 2>&1
		stop_spinner $?
		echoEnd

	#----- Variables
		urlVar="https://raw.githubusercontent.com/Noah0302sTech/Bash-Skripte/testing/Docker/System-Prune/System-Prune-Executer/Docker-SystemPrune-Executer-Noah0302sTech.sh"

		parentFolder="Docker"
			subFolder="Docker-System-Prune"
				fullInstaller="Full-Installer"
					fullInstaller="Docker-SystemPrune-Installer-Noah0302sTech.sh"
				folder2="System-Prune-Executer"
					bashExecuter="Docker-SystemPrune-Executer-Noah0302sTech.sh"
				cronCheck="Cron-Check.txt"

		parentFolderPath="/home/$SUDO_USER/Noah0302sTech/$parentFolder"
			subFolderPath="/home/$SUDO_USER/Noah0302sTech/$parentFolder/$subFolder"
				fullInstallerPath="/home/$SUDO_USER/Noah0302sTech/$parentFolder/$subFolder/$fullInstaller"
					fullInstallerPath="/home/$SUDO_USER/Noah0302sTech/$parentFolder/$subFolder/$fullInstaller/$bashExecuter"
				folder2Path="/home/$SUDO_USER/Noah0302sTech/$parentFolder/$subFolder/$folder2"
					bashExecuterPath="/home/$SUDO_USER/Noah0302sTech/$parentFolder/$subFolder/$folder2/$fullInstaller"
				cronCheckPath="/home/$SUDO_USER/Noah0302sTech/$parentFolder/$subFolder/$cronCheck"

#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#





#----- Docker Prune Script
	#--- Install WGET
		start_spinner "Installiere WGET..."
			apt install wget -y > /dev/null 2>&1
		stop_spinner $?

	#--- Downloade File
		start_spinner "Downloade $bashExecuter..."
			wget $urlVar > /dev/null 2>&1
		stop_spinner $?

	#--- Make $bashExecuter executable
		start_spinner "Mache $bashExecuter ausführbar..."
			chmod +x $bashExecuter > /dev/null 2>&1
		stop_spinner $?
	echoEnd



#----- Cron-Job
	#--- Variable
		cronVariable="0 22 * * SUN"

	#--- Ask for Cron-Job
		read -p "Möchtest du einen Cron-Job hinzufügen? (y/N): " choice
		if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
			#--- Prompt for custom values
				read -p "Passe den Cron-Job an [default 22 Uhr Sonntags: $cronVariable]: " input
				cronVariable=${input:-$cronVariable}

			#--- Create Cron-Check.txt
				start_spinner "Erstelle Cron-Check.txt..."
					touch Cron-Check.txt > /dev/null 2>&1
				stop_spinner $?
			
			#--- Create Cron-Job
				start_spinner "Erstelle Crontab..."
					echo "Erstelle Crontab..."
					touch /etc/cron.d/docker-System-Prune-Noah0302sTech
					echo "#Docker System Prune & Trim by Noah0302sTech
$cronVariable root $fullInstallerPath" > /etc/cron.d/docker-System-Prune-Noah0302sTech
				stop_spinner $?

			#--- Echo Commands into Pihole-Updater.sh
				start_spinner "Passe $bashExecuter an..."
					echo "Passe $bashExecuter an..."
					echo "

#Cron-Check
	echo "" >> '$cronCheckPath'
	echo "Job lief am:" >> '$cronCheckPath'
	date >> '$cronCheckPath'
	echo $dockerPruneOutput >> '$cronCheckPath'
	echo $fstrimOutput >> '$cronCheckPath'" >> $bashExecuter
				stop_spinner $?

		else
			echo "Cron-Job wurde nicht erstellt."
		fi
	echoEnd



#----- Ask for Execute
	while IFS= read -n1 -r -p "Möchtest du DSPtrim jetzt ausführen? [y]es|[n]o: " && [[ $REPLY != q ]]; do
	case $REPLY in
		y)  echo
			#--- Docker
				if command -v docker &> /dev/null
				then
					if [[ -z "$(docker ps -q -f status=exited)" ]]; then
						start_spinner "Alle Docker Container laufen, führe Docker-System-Prune aus..."
							dockerPruneOutput=$(docker system prune -f 2>&1)
						stop_spinner $?
						echo $dockerPruneOutput
					else
						echo "Es wurden gestoppte Container gefunden:"
						docker ps -f "status=exited"
					fi	
				else
					echo "Docker ist nicht installiert, überspringe Docker System Prune"
				fi
				echo
				echo

			#--- Trim
				start_spinner "Trimme Filesystem..."
					fstrimOutput=$(/sbin/fstrim -av 2>&1)
				stop_spinner $?
				echo $fstrimOutput
				echo
				echo

			break;;
		n)  echo
			
			break;;
		*)  echo
			echo "Antoworte mit y oder n";;
	esac
	done
	echoEnd



#----- Create Alias
    if grep -q "^alias DSPtrim=" /home/$SUDO_USER/.bashrc; then
		echo "Der Alias existiert bereits in /home/$SUDO_USER/.bashrc"
	else
		start_spinner "Erstelle Alias..."
			echo "Erstelle Alias..."
			echo "


#Alias Docker-System-Prune and Trim
alias DSPtrim='sudo bash /home/$SUDO_USER/Noah0302sTech/Docker/System-Prune/$bashExecuter'
alias ccDocker='cat /home/$SUDO_USER/Noah0302sTech/Docker/System-Prune/Cron-Check.txt'
"  >> /home/$SUDO_USER/.bashrc
		stop_spinner $?
	fi
	echoEnd



#----- Create MOTD
	if grep -q "^Docker-System-Prune" /etc/motd; then
		echo "Der MOTD Eintrag exisitert bereits in /etc/motd"
	else
		start_spinner "Passe MOTD an..."
			echo "Passe MOTD an..."
			echo "
Docker-System-Prune + Trim:
	DSPtrim
Cron-Check Docker:
	ccDocker
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

					#--- Docker-System-Prune
						if [ ! -d $subFolderPath ]; then
							mkdir $subFolderPath > /dev/null 2>&1
						else
							echo "Ordner $subFolderPath bereits vorhanden!"
						fi

						#--- Full-Installer
							if [ ! -d $fullInstallerPath ]; then
								mkdir $fullInstallerPath > /dev/null 2>&1
							else
								echo "Ordner $fullInstallerPath bereits vorhanden!"
							fi

						#--- System-Prune-Executer
							if [ ! -d $folder2Path ]; then
								mkdir $folder2Path > /dev/null 2>&1
							else
								echo "Ordner $folder2Path bereits vorhanden!"
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

				#--- Update-Executer
					if [ ! -f $bashExecuterPath ]; then
						mv /home/$SUDO_USER/$bashExecuter $folder2Path > /dev/null 2>&1
					else
						echo "Die Datei $bashExecuter ist bereits in $folder2Path vorhanden!"
					fi

			#--- Cron-Check.txt
				if [ ! -f $cronCheckPath ]; then
					mv /home/$SUDO_USER/$cronCheck $cronCheckPath > /dev/null 2>&1
				else
					echo "Die Datei $cronCheck ist bereits in $cronCheckPath vorhanden!"
				fi
		stop_spinner $?