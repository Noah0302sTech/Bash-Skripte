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
		apt install openjdk-17-jdk -y > /dev/null 2>&1
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
			read -p "Füge die Download-URL für die Minecraft-Server-Version ein (Leer für v5.9.9): " minecraftserver_url
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
		file=startMCserver.sh
		if [ ! -e "$file" ]; then

			min=1024
			max=2048
			#echo "-----START-SKRIPT existiert nicht, WIRD erstellt und ausführbar gemacht!-----"
				echo "Wie viel RAM darf der Server verwenden?"
				echo '	RAM Minumum (in MB), Default 1024: '
				read -p "min: " min
				min=${min:-1024}
				echo '	RAM Maximum (in MB), Default 2048: '
				read -p "max: " max
				max=${max:-2048}
				echo "Gewählte RAM-Settings -Xms"$min"M -Xmx"$max"M-----"
				touch startMCserver.sh
				start_spinner "Start.Skript wird erstellt..."
					echo "java -Xms"$min"M -Xmx"$max"M -jar server.jar nogui" > startMCserver.sh
					chmod +x startMCserver.sh
				stop_spinner $?
				echo

			#Server das erste Mal starten
				start_spinner "Server wird das erste Mal gestartet..."
					./startMCserver.sh > /dev/null 2>&1
				stop_spinner $?
				echo

				#Eula akzeptieren
					start_spinner "Akzepiere EULA..."
						echo "eula=true" > eula.txt > /dev/null 2>&1
					stop_spinner $?
					echo

		else
			echo "Start.Skript ist bereits vorhanden!"
			exit 1
		fi




#Starten und Welt generieren
	echo
	echo '-----Starte Minecraft-Server-----'
	echo
	sleep 3
	screen ./startMCserver.sh



#Anweisungen den Server erneut zu starten
	echo
	echo 
	echo
	echo 'Nun wird Service installiert'
	sudo chown -R $SUDO_USER:$SUDO_USER /home/$SUDO_USER/Minecraft
	echo
	echo
	echo





#Installation des Services
	cd /etc/systemd/system/
	file=mcserver.socket
	if [ ! -e "$file" ]; then

		sudo touch /etc/systemd/system/mcserver.socket
		sudo echo "[Unit]
PartOf=mcserver.service

[Socket]
ListenFIFO=%t/mcserver.stdin"  > /etc/systemd/system/mcserver.socket
		
	else 

		echo "mcserver.socket existiert bereits!"

	fi


	cd /etc/systemd/system/
	file=mcserver.service
		if [ ! -e "$file" ]; then

			sudo touch /etc/systemd/system/mcserver.service
			sudo echo "[Unit]
Description=Minecraft Server

[Service]
Type=simple
WorkingDirectory=/home/$SUDO_USER/Minecraft
ExecStart=java -Xms"$min"M -Xmx"$max"M -jar /home/$SUDO_USER/Minecraft/server.jar nogui
User=$SUDO_USER
Restart=on-failure
Sockets=mcserver.socket
StandardInput=socket
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target"  > /etc/systemd/system/mcserver.service
		
		else 

			echo "mcserver.service existiert bereits!"

		fi



	sudo systemctl daemon-reload

	sudo systemctl start mcserver.service

	sudo systemctl enable mcserver.service

	sleep 5 &> /dev/null &
		PID=$!
		i=1
		sp="/-\|"
		echo -n ' '
		while [ -d /proc/$PID ]
			do
			printf "\b${sp:i++%${#sp}:1}"
		done
		echo
		printf "\xE2\x9C\x94 \n"
		echo
	sudo systemctl status mcserver.service

	touch startmcserver.sh
	sudo echo "sudo systemctl restart mcserver.service"  > /home/$SUDO_USER/startmcserver.sh
	sudo chmod +x /home/$SUDO_USER/startmcserver.sh

	touch stopmcserver.sh
	sudo echo "sudo echo "stop" > /run/mcserver.stdin"  > /home/$SUDO_USER/stopmcserver.sh
	sudo chmod +x /home/$SUDO_USER/stopmcserver.sh

	touch restartmcserver.sh
	sudo echo "sudo echo "stop" > /run/mcserver.stdin
sleep 5
sudo systemctl restart mcserver.service"  > /home/$SUDO_USER/restartmcserver.sh
	sudo chmod +x /home/$SUDO_USER/restartmcserver.sh

	echo
	echo
	echo
	echo "Um den Server zu stoppen:"
	echo "sudo ./stopmcserver.sh"
	echo
	echo "Um den Server zu starten:"
	echo "sudo ./startmcserver.sh"
	echo
	echo "Um den Server neu zu starten:"
	echo "sudo ./restartmcserver.sh"
	echo
	echo "Um Befehle einzugeben:"
	echo "sudo echo "BEFEHLT" > /run/mcserver.stdin"
	echo "Beispiel:"
	echo "sudo echo "op Username" > /run/mcserver.stdin"
	echo
	echo
	echo
	echo "Das Skript is ausgeführt!"
	echo
	echo
	echo