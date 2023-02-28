#!/bin/bash
# Made by Noah0302sTech
# chmod +x MinecraftServerInstall-Debian11-Noah0302sTech.sh && sudo ./MinecraftServerInstall-Debian11-Noah0302sTech.sh

echo
echo "Skript von Noah0302sTech"
echo
sleep 1

min=1024
max=2048


#Test für root Rechte
	echo "-----Root?-----"
	if [[ "${UID}" -ne 0 ]]
		then
		echo '-----Root wird benötigt!-----' >&2
 		exit 1
	fi
	sleep 1
	printf "\xE2\x9C\x94 \n"





#MC Server Debian Installation





#Update & Upgrade
	echo
	echo '-----Update && Upgrade-----'
	sleep 1

	apt update -y &> /dev/null &
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

	apt upgrade -y &> /dev/null &
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



#WGET
	echo
	echo
	echo '-----Installiere WGET-----'
	sleep 1
	apt install wget -y &> /dev/null &
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



#Screen
	echo
	echo
	echo '-----Installiere Java-----'
	sleep 1
	apt install openjdk-17-jdk -y &> /dev/null &
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



#Java Installieren
	echo
	echo
	echo '-----Installiere Screen-----'
	sleep 1
	apt install screen -y &> /dev/null &
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



#Minecraft Server Download & Verzeichnis erstellen
	echo
	echo
	echo '-----Erstelle /Minecraft/ und downloade die server.jar-----'
	sleep 1

	if [ ! -d Minecraft ]; then
	
		#echo "-----Minecraft/ existiert NICHT, wird erstellt!-----"
		mkdir Minecraft
		cd Minecraft
		sleep 1
		echo "-----Downloadlink für Server.jar hier einfügen (https://www.minecraft.net/en-us/download/server): "
		read jar
		echo "wget "$jar"-----"
		wget $jar  &> /dev/null &
		PID=$!
		i=1
		sp="/-\|"
		echo -n ' '
		while [ -d /proc/$PID ]
			do
		  	printf "\b${sp:i++%${#sp}:1}"
		done

	else

		cd Minecraft
		file=server.jar
		if [ ! -e "$file" ]; then

 		   	echo "-----SERVER.JAR existiert NICHT!-----"
			echo "-----Link für Server.jar hier einfügen: "
			read jar
			sleep 1
			echo "wget "$jar"-----"
			wget $jar  &> /dev/null &
			PID=$!
			i=1
			sp="/-\|"
			echo -n ' '
			while [ -d /proc/$PID ]
				do
 				printf "\b${sp:i++%${#sp}:1}"
			done
		
		else 
			echo
   			echo "-----SERVER.JAR  existiert bereits! Wird NICHT heruntergeladen!-----"
			echo
			sleep 1
		fi
	fi
	echo
	printf "\xE2\x9C\x94 \n"



#Skript erstellen & Rechte vergeben & Starten & EULA
	echo
	echo
	
	#echo '-----Erstelle das Start-Skript-----'
	sleep 1

	file=startMCserver.sh
	if [ ! -e "$file" ]; then

		#echo "-----START-SKRIPT existiert nicht, WIRD erstellt und ausführbar gemacht!-----"
		sleep 1
		echo "Wie viel RAM darf der Server verwenden?"
		echo 'RAM Minumum (in MB), Default 1024: '
		read -p "min: " min
		min=${min:-1024}
		echo 'RAM Maximum (in MB), Default 2048: '
		read -p "max: " max
		max=${max:-2048}
		#sleep 1
		echo "Gewählte RAM-Settings -Xms"$min"M -Xmx"$max"M-----"
		touch startMCserver.sh
		echo "java -Xms"$min"M -Xmx"$max"M -jar server.jar nogui" > startMCserver.sh
		chmod +x startMCserver.sh
		printf "\xE2\x9C\x94 \n"
	




		#Server das erste Mal starten
			echo
			echo '-----Server wird das erste Mal gestartet-----'
			sleep 3
			./startMCserver.sh  &> /dev/null &
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



	
		#Eula akzeptieren
			echo
			echo '-----Akzepiere EULA-----'
			sleep 1
			echo "eula=true" > eula.txt

	else 

    	echo "-----START-SKRIPT existiert! Wird NICHT erstellt!-----"
		sleep 1
	
	fi
	printf "\xE2\x9C\x94 \n"




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