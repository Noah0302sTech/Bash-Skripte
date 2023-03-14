#!/bin/bash
# Made by Noah0302sTech
# chmod +x MinecraftServerInstall-Debian11-Noah0302sTech.sh && sudo ./MinecraftServerInstall-Debian11-Noah0302sTech.sh



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



#----- Minecraft-Server
	#--- Create directory
		start_spinner "Erstelle Minecraft-Directory..."
			if [ ! -d Minecraft ]; then
				mkdir Minecraft
			else
				echo "Minecraft-Directory ist bereits vorhanden!"
				exit 1
			fi
		cd Minecraft
		stop_spinner $?
		echo

	#--- Prompt user for the Omada download URL or use the default if left blank
		file=server.jar
		if [ ! -e "$file" ]; then
			read -p "Füge die Download-URL für die Minecraft-Server-Version ein (Leer für 1.9.3): " minecraftserver_url
			if [ -z "$minecraftserver_url" ]; then
				minecraftserver_url="https://piston-data.mojang.com/v1/objects/c9df48efed58511cdd0213c56b9013a7b5c9ac1f/server.jar"
			fi
			echo "Gewählte Version: $minecraftserver_url"
		else 
				echo "server.jar  ist bereits vorhanden!"
				exit 1
		fi
		echo

	#--- Download selcted Minecraft-Server-Version
		start_spinner "Downloade jerver.jar, bitte warten..."
			sudo apt install wget -y > /dev/null 2>&1
			wget "$minecraftserver_url" > /dev/null 2>&1
		stop_spinner $?
		echo

	echo
	echo




#-----
	#--- Create Start-Script
		file=startminecraftserver.sh
		if [ ! -e "$file" ]; then

			min=1024
			max=2048
			#echo "-----START-SKRIPT existiert nicht, WIRD erstellt und ausführbar gemacht!-----"
				echo "Wie viel RAM darf der Server verwenden?"
				echo "RAM Minumum (in MB), Default 1024:"
				read -p "min: " min
				min=${min:-1024}
				echo "RAM Maximum (in MB), Default 2048:"
				read -p "max: " max
				max=${max:-2048}
				echo "Gewählte RAM-Settings -Xms"$min"M -Xmx"$max"M"
				touch startminecraftserver.sh
				start_spinner "Start.Skript wird erstellt..."
					echo "java -Xms"$min"M -Xmx"$max"M -jar server.jar nogui" > startminecraftserver.sh
					chmod +x startminecraftserver.sh
				stop_spinner $?
				echo

			#Server das erste Mal starten
				start_spinner "Server wird das erste Mal gestartet..."
					./startminecraftserver.sh > /dev/null 2>&1
				stop_spinner $?
				echo

				#Eula akzeptieren
					start_spinner "Akzepiere EULA..."
						echo "eula=true" > eula.txt
					stop_spinner $?
					echo

		else
			echo "Start.Skript ist bereits vorhanden!"
			exit 1
		fi

	echo
	echo



#----- Starten und Welt generieren
	echo "Starte Minecraft-Server..."
	sleep 3
	screen ./startminecraftserver.sh

	echo
	echo



#----- Creating Services
	start_spinner "Minecaft-System-Service wird erstellt..."
		cd /etc/systemd/system/
		file=minecraftserver.socket
		if [ ! -e "$file" ]; then
			sudo touch /etc/systemd/system/minecraftserver.socket
			sudo echo "[Unit]
PartOf=minecraftserver.service

[Socket]
ListenFIFO=%t/minecraftserver.stdin"  > /etc/systemd/system/minecraftserver.socket
		else 
			echo "minecraftserver.socket existiert bereits!"
		fi

		cd /etc/systemd/system/
		file=minecraftserver.service
			if [ ! -e "$file" ]; then
				sudo touch /etc/systemd/system/minecraftserver.service
				sudo echo "[Unit]
Description=Minecraft Server

[Service]
Type=simple
WorkingDirectory=/home/$SUDO_USER/Minecraft
ExecStart=java -Xms"$min"M -Xmx"$max"M -jar /home/$SUDO_USER/Minecraft/server.jar nogui
User=$SUDO_USER
Restart=on-failure
Sockets=minecraftserver.socket
StandardInput=socket
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target"  > /etc/systemd/system/minecraftserver.service
			else 
				echo "minecraftserver.service existiert bereits!"
				exit 1
			fi

		sudo systemctl daemon-reload
		sudo systemctl start minecraftserver.service
		sudo systemctl enable minecraftserver.service
		sudo systemctl status minecraftserver.service
	stop_spinner $?
	echo

	start_spinner "Minecaft-Befehls-Skripte werden erstellt..."
		mkdir /home/$SUDO_USER/Minecraft-Commands
		touch startminecraftserver.sh
		sudo echo "sudo systemctl restart minecraftserver.service"  > /home/$SUDO_USER/Minecraft-Commands/startminecraftserver.sh
		sudo chmod +x /home/$SUDO_USER/Minecraft-Commands/startminecraftserver.sh
		touch stopminecraftserver.sh
		sudo echo "sudo echo 'say Server will be stopped in 5 Seconds...' > /run/minecraftserver.stdin
sleep 5
sudo echo 'stop' > /run/minecraftserver.stdin"  > /home/$SUDO_USER/Minecraft-Commands/stopminecraftserver.sh
		sudo chmod +x /home/$SUDO_USER/Minecraft-Commands/stopminecraftserver.sh
		touch restartminecraftserver.sh
		sudo echo "sudo echo 'say Server will be restarted in 5 Seconds...' > /run/minecraftserver.stdin
sleep 5
sudo systemctl restart minecraftserver.service"  > /home/$SUDO_USER/Minecraft-Commands/restartminecraftserver.sh
		sudo chmod +x /home/$SUDO_USER/Minecraft-Commands/restartminecraftserver.sh
		touch readme-minecraft-commands.txt
		echo "Status des Mincraft-Servers anzuzeigen:
sudo systemctl status minecraftserver.service 
		
Server stoppen:
sudo /home/$SUDO_USER/Minecraft-Commands/stopminecraftserver.sh

Server starten:
sudo /home/$SUDO_USER/Minecraft-Commands/startminecraftserver.sh

Server neu starten:
sudo /home/$SUDO_USER/Minecraft-Commands/restartminecraftserver.sh

Um Befehle einzugeben:
sudo echo BEFEHLT > /run/minecraftserver.stdin
Beispiel:
sudo echo op USERNAME > /run/minecraftserver.stdin"  > /home/$SUDO_USER/readme-minecraft-commands.txt
	stop_spinner $?
	echo

	echo
	echo



#----- Change permissions of MC-Folders
	start_spinner "Permissions für Minecraft-Direcories anpassen..."
		sudo chown -R $SUDO_USER:$SUDO_USER /home/$SUDO_USER/Minecraft
		sudo chown -R $SUDO_USER:$SUDO_USER /home/$SUDO_USER/Minecraft-Commands
	stop_spinner $?
	echo

	echo
	echo



#----- Finished + User Advice
	echo "Für Infos über Server-Commands, öffne die readme-minecraft-commands.txt:"
	echo "cat readme-minecraft-commands.txt"
	echo
	echo
	echo "Das Skript is ausgeführt!"
	echo