#!/bin/bash
#	Made by Noah0302sTech
#	chmod +x Docker-SystemPrune-Installer-Noah0302sTech.sh && sudo bash Docker-SystemPrune-Installer-Noah0302sTech.sh

#TODO:	Fix echo into Cron-Job sometimes not working correctly?
#		Fix check for Trim-Command

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
		urlVar="https://raw.githubusercontent.com/Noah0302sTech/Bash-Skripte/master/Docker/System-Prune/System-Prune-Executer/Docker-SystemPrune-Executer-Noah0302sTech.sh"
		cronJobAdded=false

		parentFolder="Docker"
			subFolder="System-Prune"
				fullInstallerFolder="Full-Installer"
					fullInstaller="Docker-SystemPrune-Installer-Noah0302sTech.sh"
				bashExecuterFolder="System-Prune-Executer"
					bashExecuter="Docker-SystemPrune-Executer-Noah0302sTech.sh"
				cronCheck="Cron-Check.txt"

		parentFolderPath="/home/$SUDO_USER/Noah0302sTech/$parentFolder"
			subFolderPath="/home/$SUDO_USER/Noah0302sTech/$parentFolder/$subFolder"
				fullInstallerFolderPath="/home/$SUDO_USER/Noah0302sTech/$parentFolder/$subFolder/$fullInstallerFolder"
					fullInstallerPath="/home/$SUDO_USER/Noah0302sTech/$parentFolder/$subFolder/$fullInstaller/$fullInstaller"
				bashExecuterFolderPath="/home/$SUDO_USER/Noah0302sTech/$parentFolder/$subFolder/$bashExecuterFolder"
					bashExecuterPath="/home/$SUDO_USER/Noah0302sTech/$parentFolder/$subFolder/$bashExecuterFolder/$bashExecuter"
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
	echo "----- Cron-Job -----"
	#--- Variable
		cronVariable="0 22 * * SUN"

	#--- Ask for Cron-Job
	while IFS= read -n1 -r -p "Möchtest du einen Cron-Job hinzufügen? [y]es|[n]o: " && [[ $REPLY != q ]]; do
	case $REPLY in
		y)  echo
			#--- Prompt for custom values
				read -p "Passe den Cron-Job an [default 22 Uhr Sonntags: $cronVariable]: " input
				cronVariable=${input:-$cronVariable}

			#--- Create $cronCheck
				start_spinner "Erstelle $cronCheck..."
					touch $cronCheck > /dev/null 2>&1
				stop_spinner $?
			
			#--- Create Cron-Job
				start_spinner "Erstelle Crontab..."
					touch /etc/cron.d/docker-System-Prune-Noah0302sTech
					echo "#Docker System Prune & Trim by Noah0302sTech
$cronVariable root $bashExecuterPath" > /etc/cron.d/docker-System-Prune-Noah0302sTech
				stop_spinner $?

			#--- Echo Commands into Pihole-Updater.sh
				start_spinner "Passe $bashExecuter an..."
					echo "Passe $bashExecuter an..."
					echo "

#Cron-Check
	echo "" >> $cronCheckPath
	echo "Job lief am:" >> $cronCheckPath
	date >> $cronCheckPath
	echo "'$dockerPruneOutput'" >> $cronCheckPath
	echo "'$fstrimOutput'" >> $cronCheckPath" >> $bashExecuter

			#--- Modify Variable
				cronJobAdded="true"
				stop_spinner $?

			break;;
		n)  echo
			echo "Cron-Job wurde nicht erstellt."
			
			break;;
		*)  echo
			echo "Antoworte mit y oder n";;
	esac
	done
	echoEnd



#----- Ask for Execute
	echo "----- DSP-Trim -----"
	while IFS= read -n1 -r -p "Möchtest du DSPtrim jetzt ausführen? [y]es|[n]o: " && [[ $REPLY != q ]]; do
	case $REPLY in
		y)  echo
			#--- Execute downloaded Bash-File
				bash $bashExecuter

			break;;
		n)  echo
			echo "DSPtrim wurde nicht erstellt."
			
			break;;
		*)  echo
			echo "Antoworte mit y oder n";;
	esac
	done
	echoEnd



#--- Create Alias
	echo "----- Alias -----"
    if grep -q "^alias DSPtrim=" /home/$SUDO_USER/.bashrc; then
		echo "Der Alias existiert bereits in /home/$SUDO_USER/.bashrc"
	else
		start_spinner "Erstelle Alias..."
			echo "Erstelle Alias..."
			echo "


#Alias Docker-System-Prune and Trim
alias DSPtrim='sudo bash $bashExecuterPath'"  >> /home/$SUDO_USER/.bashrc

		if $cronJobAdded == true; then
			echo "alias ccDocker='cat $cronCheckPath'
" >> /home/$SUDO_USER/.bashrc
		fi
		stop_spinner $?
	fi
	echoEnd



#----- Create MOTD
	echo "----- MOTD -----"
	if grep -q "^Docker-System-Prune" /etc/motd; then
		echo "Der MOTD Eintrag exisitert bereits in /etc/motd"
	else
		start_spinner "Passe MOTD an..."
			echo "Passe MOTD an..."
			echo "
Docker-System-Prune + Trim:
	DSPtrim" >> /etc/motd

		if $cronJobAdded == true; then
			echo "Cron-Check Docker:
	ccDocker
" >> /etc/motd
		fi
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
							if [ ! -d $fullInstallerFolderPath ]; then
								mkdir $fullInstallerFolderPath > /dev/null 2>&1
							else
								echo "Ordner $fullInstallerFolderPath bereits vorhanden!"
							fi

						#--- System-Prune-Executer
							if [ ! -d $bashExecuterFolderPath ]; then
								mkdir $bashExecuterFolderPath > /dev/null 2>&1
							else
								echo "Ordner $bashExecuterFolderPath bereits vorhanden!"
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
						mv /home/$SUDO_USER/$bashExecuter $bashExecuterFolderPath > /dev/null 2>&1
					else
						echo "Die Datei $bashExecuter ist bereits in $bashExecuterFolderPath vorhanden!"
					fi

			#--- Cron-Check.txt
				if $cronJobAdded == true; then
					if [ ! -f $cronCheckPath ]; then
						mv /home/$SUDO_USER/$cronCheck $cronCheckPath > /dev/null 2>&1
					else
						echo "Die Datei $cronCheck ist bereits in $cronCheckPath vorhanden!"
					fi
				fi

		stop_spinner $?