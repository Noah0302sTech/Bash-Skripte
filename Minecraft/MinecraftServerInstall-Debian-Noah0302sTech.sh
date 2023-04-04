#!/bin/bash
# Made by Noah0302sTech
# chmod +x MinecraftServerInstall-Debian11-NoCheck-Noah0302sTech.sh && sudo bash MinecraftServerInstall-Debian11-NoCheck-Noah0302sTech.sh



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


#----- WGET
	start_spinner "Installiere wget..."
		apt install wget -y > /dev/null 2>&1
	stop_spinner $?

	echo
	echo



#----- Java
	start_spinner "Installiere Java..."
		apt install openjdk-17-jdk-headless -y > /dev/null 2>&1
	stop_spinner $?

	echo
	echo



#----- Screen
	start_spinner "Installiere Screen..."
		apt install screen -y  > /dev/null 2>&1
	stop_spinner $?
	echo

	echo
	echo



#----- Minecraft-Server Dir and Download Jar
	#--- Create directory
		start_spinner "Erstelle Minecraft-Directory..."
			mkdir /home/$SUDO_USER/Minecraft-Server  > /dev/null 2>&1
			cd /home/$SUDO_USER/Minecraft-Server
		stop_spinner $?
		echo

	#--- Prompt user for the Server.Jar download URL or use the default if left blank
		read -p "Füge die Download-URL für die Minecraft-Server-Version ein (Leer für 1.19.4): " minecraftserver_url
		if [ -z "$minecraftserver_url" ]; then
			minecraftserver_url="https://piston-data.mojang.com/v1/objects/8f3112a1049751cc472ec13e397eade5336ca7ae/server.jar"
		fi
		echo "Gewählte Version: $minecraftserver_url"
		echo

	#--- Download selcted Minecraft-Server-Version
		start_spinner "Downloade jerver.jar, bitte warten..."
			sudo apt install wget -y > /dev/null 2>&1
			wget "$minecraftserver_url" > /dev/null 2>&1
		stop_spinner $?
		echo

	echo
	echo




#----- Minecraft Server Installation
	#--- Create Start-Script
		#- Set default Values
			min=1024
			max=2048

		#- Input for Custom Values
			echo "Wie viel RAM darf der Server verwenden?"

			# Min
				echo "RAM Minumum (in MB), Default 1024:"
				read -p "min: " min
				min=${min:-1024}

			# Max
				echo "RAM Maximum (in MB), Default 2048:"
				read -p "max: " max
				max=${max:-2048}
			
			echo
		
		#- Summary of Values
			echo "Gewählte RAM-Settings -Xms"$min"M -Xmx"$max"M"
			touch /home/$SUDO_USER/Minecraft-Server/MC-Server-Start-Noah0302sTech.sh
			echo

		#- Create Skript and make is executable
			start_spinner "Start.Skript wird erstellt..."
				echo "java -Xms"$min"M -Xmx"$max"M -jar server.jar nogui" > /home/$SUDO_USER/Minecraft-Server/MC-Server-Start-Noah0302sTech.sh
				chmod +x /home/$SUDO_USER/Minecraft-Server/MC-Server-Start-Noah0302sTech.sh
			stop_spinner $?
			echo

	#--- Start Server and accept EULA
		#- Start Server
			start_spinner "Server wird das erste Mal gestartet..."
				/home/$SUDO_USER/Minecraft-Server/MC-Server-Start-Noah0302sTech.sh > /dev/null 2>&1
			stop_spinner $?
			echo

		#- Accept EULA
			start_spinner "Akzepiere EULA..."
				echo "eula=true" > eula.txt
				sleep 1
			stop_spinner $?
			echo

	echo
	echo



#----- Start Minecraft Server to generate World
	echo "Starte Minecraft-Server..."
	echo "Server mit 'stop' nach Erstellung der Welt beenden"
	sleep 5
	screen /home/$SUDO_USER/Minecraft-Server/MC-Server-Start-Noah0302sTech.sh

	echo
	echo



#----- Creating Services
	start_spinner "Minecaft-System-Service wird erstellt..."

	#--- Create Socket
		sudo touch /etc/systemd/system/minecraftserver.socket
		sudo echo "[Unit]
PartOf=minecraftserver.service

[Socket]
ListenFIFO=%t/minecraftserver.stdin"  > /etc/systemd/system/minecraftserver.socket

	#--- Create Service
		sudo touch /etc/systemd/system/minecraftserver.service
		sudo echo "[Unit]
Description=Minecraft Server

[Service]
Type=simple
WorkingDirectory=/home/$SUDO_USER/Minecraft-Server
ExecStart=java -Xms"$min"M -Xmx"$max"M -jar /home/$SUDO_USER/Minecraft-Server/server.jar nogui
User=$SUDO_USER
Restart=on-failure
Sockets=minecraftserver.socket
StandardInput=socket
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target"  > /etc/systemd/system/minecraftserver.service

	#--- Enabling Service
		sudo systemctl daemon-reload > /dev/null 2>&1
		sudo systemctl start minecraftserver.service > /dev/null 2>&1
		sudo systemctl enable minecraftserver.service > /dev/null 2>&1
		sudo systemctl status minecraftserver.service > /dev/null 2>&1

	stop_spinner $?

	echo
	echo



#----- Create Minecraft-Server-Commands Directory
	start_spinner "Minecaft-Command-Verzeichnis wird erstellt..."
		mkdir /home/$SUDO_USER/Minecraft-Server-Commands > /dev/null 2>&1
	stop_spinner $?

	#--- Move Installer File
				mv MinecraftServerInstall-Debian11-NoCheck-Noah0302sTech.sh /home/$SUDO_USER/Minecraft-Server/ > /dev/null 2>&1

	#--- Downloading Command-Skripts
		start_spinner "Server-Command Skripte werden heruntergeladen..."
			#- Start Minecraft Server
				sudo wget https://raw.githubusercontent.com/Noah0302sTech/Bash-Skripte/master/Minecraft/Minecraft%20Commands/MC-Server-Start-Noah0302sTech.sh -P /home/$SUDO_USER/Minecraft-Server-Commands > /dev/null 2>&1
				sudo chmod +x /home/$SUDO_USER/Minecraft-Server-Commands/MC-Server-Start-Noah0302sTech.sh > /dev/null 2>&1

			#- Stop Minecraft Server
				sudo wget https://raw.githubusercontent.com/Noah0302sTech/Bash-Skripte/master/Minecraft/Minecraft%20Commands/MC-Server-Stop-Noah0302sTech.sh -P /home/$SUDO_USER/Minecraft-Server-Commands > /dev/null 2>&1
				sudo chmod +x /home/$SUDO_USER/Minecraft-Server-Commands/MC-Server-Stop-Noah0302sTech.sh > /dev/null 2>&1

			#- Restart Minecraft Server
				sudo wget https://raw.githubusercontent.com/Noah0302sTech/Bash-Skripte/master/Minecraft/Minecraft%20Commands/MC-Server-Restart-Noah0302sTech.sh -P /home/$SUDO_USER/Minecraft-Server-Commands > /dev/null 2>&1
				sudo chmod +x /home/$SUDO_USER/Minecraft-Server-Commands/MC-Server-Restart-Noah0302sTech.sh > /dev/null 2>&1

			#- Command Minecraft Server
				sudo wget https://raw.githubusercontent.com/Noah0302sTech/Bash-Skripte/master/Minecraft/Minecraft%20Commands/MC-Server-Command-Noah0302sTech.sh -P /home/$SUDO_USER/Minecraft-Server-Commands > /dev/null 2>&1
				sudo chmod +x /home/$SUDO_USER/Minecraft-Server-Commands/MC-Server-Command-Noah0302sTech.sh > /dev/null 2>&1

			#- Command Host Restart 
				sudo wget https://raw.githubusercontent.com/Noah0302sTech/Bash-Skripte/master/Minecraft/Minecraft%20Commands/MC-Host-Restart-Noah0302sTech.sh -P /home/$SUDO_USER/Minecraft-Server-Commands > /dev/null 2>&1
				sudo chmod +x /home/$SUDO_USER/Minecraft-Server-Commands/MC-Host-Restart-Noah0302sTech.sh > /dev/null 2>&1

		stop_spinner $?
	
	echo
	echo
			


#----- Create Bash-Alias
	echo "
#Minecraft-Server Commands
alias reboot='sudo bash /home/$SUDO_USER/Minecraft-Server-Commands/MC-Host-Restart-Noah0302sTech.sh'
alias mcstatus='sudo systemctl status minecraftserver.service'
alias mcrestart='sudo bash /home/$SUDO_USER/Minecraft-Server-Commands/MC-Server-Restart-Noah0302sTech.sh'
alias mcstart='sudo bash /home/$SUDO_USER/Minecraft-Server-Commands/MC-Server-Start-Noah0302sTech.sh'
alias mcstop='sudo bash /home/$SUDO_USER/Minecraft-Server-Commands/MC-Server-Stop-Noah0302sTech.sh'
alias mccommand='sudo bash /home/$SUDO_USER/Minecraft-Server-Commands/MC-Server-Command-Noah0302sTech.sh'"  >> /home/$SUDO_USER/.bashrc



#----- Change permissions of MC-Folders
	start_spinner "Permissions für Minecraft-Direcories anpassen..."
		sudo chown -R $SUDO_USER:$SUDO_USER /home/$SUDO_USER/Minecraft-Server > /dev/null 2>&1
		sudo chown -R $SUDO_USER:$SUDO_USER /home/$SUDO_USER/Minecraft-Server-Commands > /dev/null 2>&1
	stop_spinner $?

	echo
	echo



#----- Add new MOTD
	start_spinner "Füge MOTD hinzu..."
		sudo echo "
-----   MOTD MC-Server-Commands by Noah0302sTech    -----

Status des Mincraft-Servers anzeigen:
mcstatus

Server stoppen:
mcstop

Server starten:
mcstart

Server neu starten:
mcrestart

Um Befehle einzugeben:
mccommand

Um der kompletten Host neu zu starten:
reboot

-----   MOTD MC-Server-Commands by Noah0302sTech    -----
" > /etc/motd
	stop_spinner $?

	echo
	echo



#----- Finished + User Advice
	echo "Server-Commands wurden in die MOTD hinzugefügt."
	echo
	echo "Achtung, diese Befehle funktionieren erst nach einer Neuverbindung per SSH!"
	echo
	echo
	printf "\xE2\x9C\x94 \n"
