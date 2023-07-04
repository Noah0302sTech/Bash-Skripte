#!/bin/bash
#	Made by Noah0302sTech
# 	chmod +x Part1-PBS-2-Full-Upgrade.sh && bash Part1-PBS-2-Full-Upgrade.sh
#	wget https://raw.githubusercontent.com/Noah0302sTech/Bash-Skripte/master/Proxmox/PBS/PBS-2to3/Part1-PBS-2-Full-Upgrade.sh && bash Part1-PBS-2-Full-Upgrade.sh



#----------- Init
	#----- echoEnd
		function echoEnd {
			echo
			echo
			echo
		}

	#----- Variables
		url="https://raw.githubusercontent.com/Noah0302sTech/Bash-Skripte/master/Proxmox/PBS/PBS-2to3/Part2-PBS-2to3.sh"



#Create Folder
	mkdir PBS-2to3

	echoEnd



#Move Bash-Script
	mv Part1-PBS-2-Full-Upgrade.sh PBS-2to3/Part1-PBS-2-Full-Upgrade.sh

	echoEnd



#Enable Maintanance Mode
	echo "----- Maintanance-Mode -----"
		echo "ACHTUNG, dieser Step ist optional! Wenn keine Backups laufen, ist es nicht zwingend nötig!"
		while IFS= read -n1 -r -p "Maintanance-Mode jetzt aktivieren? [y]es|[n]o: " && [[ $REPLY != q ]]; do
		case $REPLY in
			y)  echo
					#List of all Datastores
						proxmox-backup-manager datastore list

					#Variable for Datastore ID
						datastoreID="PBS01-Storage01"
							read -p "Gib die Datastore ID ein: [default: $datastoreID]: " input
							datastoreID=${input:-$datastoreID}

					#Enable Maintanance Mode
						proxmox-backup-manager datastore update $datastoreID --maintenance-mode read-only

					#Multiple Datastores
						while IFS= read -n1 -r -p "Weitere Datastores in Maintanance-Mode versetzen? [y]es|[n]o: " && [[ $REPLY != q ]]; do
						case $REPLY in
							y)  echo
									#List of all Datastores
										proxmox-backup-manager datastore list

									#Variable for Datastore ID
										datastoreID="PBS01-Storage01"
											read -p "Gib die Datastore ID ein: [default: $datastoreID]: " input
											datastoreID=${input:-$datastoreID}

									#Enable Maintanance Mode
										proxmox-backup-manager datastore update $datastoreID --maintenance-mode read-only

								echo;;
							n)  echo
									echo "Keine weiteren Datastores!"
								
								break;;
							*)  echo
									echo "Antoworte mit y oder n";;
						esac
						done

				break;;
			n)  echo
					echo "Maintanance-Mode wurde nicht aktiviert!"
				
				break;;
			*)  echo
					echo "Antoworte mit y oder n";;
		esac
		done
		
	echoEnd



#Outcomment Enterprise Repo
	echo "----- Enterprise Repo -----"
		echo "ACHTUNG, nur benötigt, wenn keine Lizenz vorhanden ist!"
		while IFS= read -n1 -r -p "Enterprise-Repo jetzt deaktivieren? [y]es|[n]o: " && [[ $REPLY != q ]]; do
		case $REPLY in
			y)  echo
					echo "#deb https://enterprise.proxmox.com/debian/pbs bullseye pbs-enterprise" > /etc/apt/sources.list.d/pbs-enterprise.list

				break;;
			n)  echo
					echo "Enterprise-Repo wurde nicht deaktiviert!"
				
				break;;
			*)  echo
					echo "Antoworte mit y oder n";;
		esac
		done

	echoEnd



#Add No-Subscription Repo for latest 2.x-x
	echo "----- Add No-Subscription-Repo -----"
		echo "ACHTUNG, nur benötigt, wenn keine Lizenz vorhanden ist und die No-Subscription nicht aktiviert ist!"
		while IFS= read -n1 -r -p "No-Subscription Repo jetzt aktivieren? [y]es|[n]o: " && [[ $REPLY != q ]]; do
		case $REPLY in
			y)  echo
							echo "deb http://ftp.de.debian.org/debian bullseye main contrib

deb http://ftp.de.debian.org/debian bullseye-updates main contrib

# security updates
deb http://security.debian.org bullseye-security main contrib

deb http://download.proxmox.com/debian/pbs bullseye pbs-no-subscription" > /etc/apt/sources.list

				break;;
			n)  echo
					echo "No-Subscription-Repo wurde nicht aktiviert!"
				
				break;;
			*)  echo
					echo "Antoworte mit y oder n";;
		esac
		done

	echoEnd



#Update to latest 2.x-x
	echo "----- Update to latest 2.x-x -----"
		apt update && apt dist-upgrade

	echoEnd



#Check Version
	echo "----- Check Version -----"
		echo "ACHTUNG, die Version MUSS nun '2.4-2' oder höher anzeigen!"
		proxmox-backup-manager versions
		while IFS= read -n1 -r -p "Ist die Version höher als '2.4-2'? [y]es|[n]o: " && [[ $REPLY != q ]]; do
		case $REPLY in
			y)  echo
					echo "Führe Skript weiter aus!"

				break;;
			n)  echo
					echo "Skript wird abgebrochen!"
					echo "Upgrade kann nicht durchgeführt werden, wenn die Version nicht mindestens '2.4-2' oder höher ist"
				
				exit 0;;
			*)  echo
					echo "Antoworte mit y oder n";;
		esac
		done

	echoEnd



#Reboot Node
	echo "----- Reboot Node -----"
		echo "Optionaler Reboot des Nodes, wenn kein neuer Kernel installiert wurde!"
		echo "ACHTUNG, erst Node rebooten, wenn kein Backup-Job mehr auf diesem Node läuft!"
		while IFS= read -n1 -r -p "Jetzt Node rebooten? [y]es|[n]o: " && [[ $REPLY != q ]]; do
		case $REPLY in
			y)  echo
					echo "Starte in 15 Sekunden neu!"
					echoEnd
					sleep 15
					systemctl reboot

				break;;
			n)  echo
					echo "Node wurde nicht rebotet! Neue Kernel-Version ggf. noch nicht aktiv!"
				
				break;;
			*)  echo
					echo "Antoworte mit y oder n";;
		esac
		done

	echoEnd