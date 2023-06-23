#!/bin/bash
#	Made by Noah0302sTech
# 	chmod +x Part1-PVE-7-Full-Upgrade.sh && bash Part1-PVE-7-Full-Upgrade.sh
#	wget https://raw.githubusercontent.com/Noah0302sTech/Bash-Skripte/testing/Proxmox/PVE-7to8/Part1-PVE-7-Full-Upgrade.sh && bash Part1-PVE-7-Full-Upgrade.sh



#----------- Init
	#----- echoEnd
		function echoEnd {
			echo
			echo
			echo
		}

	#----- Variables
		url="https://raw.githubusercontent.com/Noah0302sTech/Bash-Skripte/testing/Proxmox/PVE-7to8/Part2-PVE-7to8.sh"



#Create Folder
	mkdir PVE-7to8

	echoEnd



#Move Bash-Script
	mv Part1-PVE-7-Full-Upgrade.sh PVE-7to8/Part1-PVE-7-Full-Upgrade.sh

	echoEnd



#Outcomment Enterprise Repo
	echo "----- Enterprise Repo -----"
		echo "ACHTUNG, nur benötigt, wenn keine Lizenz vorhanden ist!"
		while IFS= read -n1 -r -p "Enterprise Repo jetzt deaktivieren? [y]es|[n]o: " && [[ $REPLY != q ]]; do
		case $REPLY in
			y)  echo
					echo "# deb https://enterprise.proxmox.com/debian/pve bookworm pve-enterprise" > /etc/apt/sources.list.d/pve-enterprise.list

				break;;
			n)  echo
					echo "Node wurde nicht rebotet! Neue Kernel-Version noch nicht aktiv!"
				
				break;;
			*)  echo
					echo "Antoworte mit y oder n";;
		esac
		done
	echoEnd



#Add No-Subscription Repo for latest 7.4.x
	echo "----- Add No-Subscription Repo -----"
		echo "ACHTUNG, nur benötigt, wenn keine Lizenz vorhanden ist und die No-Subscription nicht aktiviert ist!"
		while IFS= read -n1 -r -p "No-Subscription Repo jetzt aktivieren? [y]es|[n]o: " && [[ $REPLY != q ]]; do
		case $REPLY in
			y)  echo
							echo "


#PVE-No-Subscription
deb http://download.proxmox.com/debian/pve bullseye pve-no-subscription" >> /etc/apt/sources.list

				break;;
			n)  echo
					echo "Node wurde nicht rebotet! Neue Kernel-Version noch nicht aktiv!"
				
				break;;
			*)  echo
					echo "Antoworte mit y oder n";;
		esac
		done

	echoEnd



#Update to latest 7.4.x
	echo "----- Update to latest 7.4.x -----"
		apt update && apt dist-upgrade

	echoEnd



#Reboot Node
	echo "----- Reboot Node -----"
		echo "Optionaler Reboot des Nodes"
		echo "ACHTUNG, erst Node rebooten, wenn keine VM mehr auf diesem Node läuft!"
		while IFS= read -n1 -r -p "Jetzt Node rebooten? [y]es|[n]o: " && [[ $REPLY != q ]]; do
		case $REPLY in
			y)  echo
					echo "Starte in 15 Sekunden neu!"
					echoEnd
					sleep 15
					reboot

				break;;
			n)  echo
					echo "Node wurde nicht rebotet! Neue Kernel-Version ggf. noch nicht aktiv!"
				
				break;;
			*)  echo
					echo "Antoworte mit y oder n";;
		esac
		done

	echoEnd