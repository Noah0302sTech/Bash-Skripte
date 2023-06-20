#!/bin/bash
#	Made by Noah0302sTech
# 	chmod +x Part1-PVE-6-Full-Upgrade.sh && bash Part1-PVE-6-Full-Upgrade.sh



#Create Folder
	mkdir PVE-6to7

	echo
	echo
	echo

#Move Bash-Script
	mv Part1-PVE-6-Full-Upgrade.sh PVE-6to7/Part1-PVE-6-Full-Upgrade.sh

	echo
	echo
	echo

#Delete Enterprise Repo
	echo "----- Delete Enterprise Repo -----"
	rm /etc/apt/sources.list.d/pve-enterprise.list

	echo
	echo
	echo

#Add No-Subscription Repo
	echo "----- Add No-Subscription Repo -----"
	echo "
deb http://download.proxmox.com/debian/pve buster pve-no-subscription" >> /etc/apt/sources.list

	echo
	echo
	echo

#Update to latest 6.4-X
	echo "----- Update to latest 6.4-X -----"
	apt update && apt dist-upgrade

	echo
	echo
	echo

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

	echo
	echo
	echo