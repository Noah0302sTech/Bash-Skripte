#!/bin/bash
#	Made by Noah0302sTech
# 	chmod +x Part3-PBS-Resume-Operation.sh && bash Part3-PBS-Resume-Operation.sh
#	wget https://raw.githubusercontent.com/Noah0302sTech/Bash-Skripte/testing/Proxmox/PBS/PBS-2to3/Part3-PBS-Resume-Operation.sh && bash Part3-PBS-Resume-Operation.sh



#----------- Init
	#----- echoEnd
		function echoEnd {
			echo
			echo
			echo
		}

	#----- Variables
		url="https://raw.githubusercontent.com/Noah0302sTech/Bash-Skripte/testing/Proxmox/PBS/PBS-2to3/Part3-PBS-Resume-Operation.sh"



#Move Bash-Script
	mv Part3-PBS-Resume-Operation.sh PBS-2to3/Part3-PBS-Resume-Operation.sh

	echoEnd



#Check Services
	echo "----- Check Version -----"
		echo "ACHTUNG, die die PBS-Service müssen wieder ordnungsgemäß laufen 'active (running)'!"
		systemctl status proxmox-backup-proxy.service proxmox-backup.service
		while IFS= read -n1 -r -p "Ist der Status 'active (running)'? [y]es|[n]o: " && [[ $REPLY != q ]]; do
		case $REPLY in
			y)  echo
					echo "Führe Skript weiter aus!"

				break;;
			n)  echo
					echo "Skript wird abgebrochen!"
					echo "Die Services MÜSSEN laufen!"
				
				exit 0;;
			*)  echo
					echo "Antoworte mit y oder n";;
		esac
		done

	echoEnd



#Check Version
	echo "----- Check Version -----"
		echo "ACHTUNG, die Version MUSS nun '3.x-x' oder höher anzeigen!"
		proxmox-backup-manager versions
		while IFS= read -n1 -r -p "Ist die Version höher als '3.x-x'? [y]es|[n]o: " && [[ $REPLY != q ]]; do
		case $REPLY in
			y)  echo
					echo "Führe Skript weiter aus!"

				break;;
			n)  echo
					echo "Skript wird abgebrochen!"
					echo "Upgrade kann nicht durchgeführt werden, wenn die Version nicht mindestens '3.x-x' oder höher ist"
				
				exit 0;;
			*)  echo
					echo "Antoworte mit y oder n";;
		esac
		done

	echoEnd



#Update to latest 3.x-x
	echo "----- Update to latest 3.x-x -----"
		apt update && apt dist-upgrade

	echoEnd



#Disable Maintanance Mode
	echo "----- Maintanance-Mode -----"
		echo "ACHTUNG, ohne den Maintanance-Mode zu deaktivieren, können die Backups NICHT fuktionieren!"
		while IFS= read -n1 -r -p "Maintanance-Mode jetzt deaktivieren? [y]es|[n]o: " && [[ $REPLY != q ]]; do
		case $REPLY in
			y)  echo
					#List of all Datastores
						proxmox-backup-manager datastore list

					#Variable for Datastore ID
						datastoreID="PBS01-Storage01"
							read -p "Gib die Datastore ID ein: [default: $datastoreID]: " input
							datastoreID=${input:-$datastoreID}

					#Disable Maintanance Mode
						proxmox-backup-manager datastore update $datastoreID --delete maintenance-mode

					#Multiple Datastores
						while IFS= read -n1 -r -p "Weitere Datastores aus dem Maintanance-Mode befreien? [y]es|[n]o: " && [[ $REPLY != q ]]; do
						case $REPLY in
							y)  echo
									#List of all Datastores
										proxmox-backup-manager datastore list

									#Variable for Datastore ID
										datastoreID="PBS01-Storage01"
											read -p "Gib die Datastore ID ein: [default: $datastoreID]: " input
											datastoreID=${input:-$datastoreID}

									#Disable Maintanance Mode
										proxmox-backup-manager datastore update $datastoreID --delete maintenance-mode

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
					echo "Maintanance-Mode wurde nicht deaktiviert!"
				
				break;;
			*)  echo
					echo "Antoworte mit y oder n";;
		esac
		done
		
	echoEnd



#Reboot Node
	echo "----- Reboot Node -----"
		echo "Optionaler Reboot!"
		while IFS= read -n1 -r -p "Jetzt Node rebooten? [y]es|[n]o: " && [[ $REPLY != q ]]; do
		case $REPLY in
			y)  echo
					echo "Starte in 15 Sekunden neu!"
					echoEnd
					sleep 15
					systemctl reboot

				break;;
			n)  echo
					echo "Node wurde nicht rebotet!"
				
				break;;
			*)  echo
					echo "Antoworte mit y oder n";;
		esac
		done

	echoEnd