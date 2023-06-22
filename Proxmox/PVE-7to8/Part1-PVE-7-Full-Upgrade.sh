#!/bin/bash
#	Made by Noah0302sTech
# 	chmod +x Part2-PVE-7to8.sh && bash Part2-PVE-7to8.sh



#----------- Init
	#----- echoEnd
		function echoEnd {
			echo
			echo
			echo
		}

	#----- Variables
		url="https://raw.githubusercontent.com/Noah0302sTech/Bash-Skripte/testing/Proxmox/Ceph-15to16/Part2-Restart-Ceph-Daemons.sh"



#Create Folder
	mkdir PVE-7to8

	echoEnd

#Move Bash-Script
	mv Part2-PVE-7to8.sh PVE-7to8/Part2-PVE-7to8.sh

	echoEnd

#Delete Enterprise Repo
	echo "----- Delete Enterprise Repo -----"
		rm /etc/apt/sources.list.d/pve-enterprise.list

	echoEnd

#Add No-Subscription Repo
	echo "----- Add No-Subscription Repo -----"
	echo "
deb http://download.proxmox.com/debian/pve buster pve-no-subscription" >> /etc/apt/sources.list

	echoEnd

#Update to latest 6.4-X
	echo "----- Update to latest 6.4-X -----"
	apt update && apt dist-upgrade

	echoEnd

#Reboot Node
	echo "----- Reboot Node -----"
	echo "ACHTUNG, erst Node rebooten, wenn keine VM mehr auf diesem Node läuft!"
	while IFS= read -n1 -r -p "Jetzt Node rebooten? [y]es|[n]o: " && [[ $REPLY != q ]]; do
	case $REPLY in
		y)  echo

			echo "Starte in 15 Sekunden neu!"
			echo
			echo
			echo
			sleep 15
			reboot

			break;;
		n)  echo
			echo "Node wurde nicht rebotet! Neue Kernel-Version noch nicht aktiv!"
			
			break;;
		*)  echo
			echo "Antoworte mit y oder n";;
	esac
	done

	echoEnd