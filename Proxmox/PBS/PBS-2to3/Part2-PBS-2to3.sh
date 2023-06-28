#!/bin/bash
#	Made by Noah0302sTech
# 	chmod +x Part2-PBS-2to3.sh && bash Part2-PBS-2to3.sh
#	wget https://raw.githubusercontent.com/Noah0302sTech/Bash-Skripte/testing/Proxmox/PBS/PBS-2to3/Part2-PBS-2to3.sh && bash Part2-PBS-2to3.sh



#----------- Init
	#----- echoEnd
		function echoEnd {
			echo
			echo
			echo
		}

	#----- Variables
		url="https://raw.githubusercontent.com/Noah0302sTech/Bash-Skripte/testing/Proxmox/PBS/PBS-2to3/Part2-PBS-2to3.sh"



#Move Bash-Script
	mv Part2-PBS-2to3.sh PBS-2to3/Part2-PBS-2to3.sh

	echoEnd



#Update to latest 2.x-x
	echo "----- Update to latest 2.x-x -----"
		apt update && apt dist-upgrade

	echoEnd



#Update the configured APT repositories
	echo "----- Update the configured APT repositories -----"
		sed -i 's/bullseye/bookworm/g' /etc/apt/sources.list
		sed -i -e 's/bullseye/bookworm/g' /etc/apt/sources.list.d/*.list

	echoEnd



#Update Package-List
	echo "----- Update Package-List -----"
		apt update

	echoEnd



#Upgrade System
	echo "----- Upgrade System -----"
		echo "ACHTUNG, Upgrade erst ausführen, wenn die vorherigen Steps keine Fehler anzeigten!"
		while IFS= read -n1 -r -p "Jetzt das Upgrade ausführen? [y]es|[n]o: " && [[ $REPLY != q ]]; do
		case $REPLY in
			y)  echo
					apt dist-upgrade

				break;;
			n)  echo
					echo "Proxmox Backup Server wurde nicht auf PBS 3.x geupgraded!"
					echo "Falls du das später machen möchtest, gebe folgenden Befehl ein:"
					echo "apt dist-upgrade"
				
				exit 0;;
			*)  echo
					echo "Antoworte mit y oder n";;
		esac
		done

	echoEnd

#Reboot Node
	echo "----- Reboot Node -----"
		echo "ACHTUNG, erst Node rebooten, wenn alle Steps erfolgreich durchlaufen sind!"
		while IFS= read -n1 -r -p "Jetzt Node rebooten? [y]es|[n]o: " && [[ $REPLY != q ]]; do
		case $REPLY in
			y)  echo
					echo "Starte in 15 Sekunden neu!"
					echoEnd
					sleep 15
					systemctl reboot

				break;;
			n)  echo
					echo "Node wurde nicht rebotet! Neue Kernel-Version noch nicht aktiv!"
				
				break;;
			*)  echo
					echo "Antoworte mit y oder n";;
		esac
		done

	echoEnd