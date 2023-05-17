#!/bin/bash
#	Made by Noah0302sTech
#	chmod +x KeepAliveD-Installer-Noah0302sTech.sh && sudo bash KeepAliveD-Installer-Noah0302sTech.sh

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

#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#





#----- Variables
	ifaceName="eth0"
	uniSrc="192.168.6.4"
	uniPeer="192.168.6.5"
	virtIP="192.168.6.3/24"
	unboundPwd="Unb0und1!"
	prio="50"



#----- Prompt for custom values
	#--- Interface Name
		read -p "Gib den Interface-Namen an [default: $ifaceName]: " input
		ifaceName=${input:-$ifaceName}

	#--- Unicast Source
		read -p "Gib die Unicast-Source-IP an [default: $uniSrc]: " input
		uniSrc=${input:-$uniSrc}

	#--- Unicast Destination
		read -p "Gib die Unicast-Destination-IP an [default: $uniPeer]: " input
		uniPeer=${input:-$uniPeer}

	#--- Virtual IP
		read -p "Gib die virtuelle KeepAliveD-IP an [default: $virtIP]: " input
		virtIP=${input:-$virtIP}

	#--- Unbound PW
		read -p "Gib das Unbound-Passwort an [default: $unboundPwd]: " input
		unboundPwd=${input:-$unboundPwd}

	#--- Priority
		read -p "Gib die Priorität an (Höher=Primary) [default: $prio]: " input
		prio=${input:-$prio}
	echo
	echo


#----- KeepAliveD
	#--- Install KeepAliveD
		start_spinner "Installiere KeepAliveD..."
			apt install keepalived -y > /dev/null 2>&1
		stop_spinner $?

	#--- Install KeepAliveD
		start_spinner "Konfiguriere KeepAliveD-Config..."
			echo "" > /etc/keepalived/keepalived.conf
			echo '#Primary
vrrp_instance VI_1 {
  state MASTER
  interface '$ifaceName'
  virtual_router_id 55
  priority '$prio'
  advert_int 1
  unicast_src_ip '$uniSrc'
  unicast_peer {
    '$uniPeer'
  }

  authentication {
    auth_type PASS
    auth_pass '$unboundPwd'
  }

  virtual_ipaddress {
    '$virtIP'
  }
}' | tee -a /etc/keepalived/keepalived.conf > /dev/null 2>&1
			stop_spinner $?

	#--- Enable
		start_spinner "Aktiviere KeepAliveD..."
			systemctl enable --now keepalived.service > /dev/null 2>&1
		stop_spinner $?

	#--- Status
		start_spinner "KeepAliveD Status..."
			systemctl status keepalived.service
		stop_spinner $?
	echo
	echo





#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#
#-----	-----#	#-----	-----#	#-----	-----#

#----- Variables
	folderVar=Pihole
	subFolderVar=KeepAlived
	shPrimaryVar=KeepAlived-Installer.sh

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
	stop_spinner $?

#----- Move Bash-Script
	start_spinner "Verschiebe Bash-Skript..."
		#--- Primary Script Variable
			if [ ! -f /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolderVar/$shPrimaryVar ]; then
				mv /home/$SUDO_USER/$shPrimaryVar /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolderVar/$shPrimaryVar > /dev/null 2>&1
			else
				echo "Die Datei /home/$SUDO_USER/Noah0302sTech/$folderVar/$subFolderVar/$shPrimaryVar ist bereits vorhanden!"
			fi
	stop_spinner $?