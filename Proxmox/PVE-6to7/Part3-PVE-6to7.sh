#!/bin/bash
#	Made by Noah0302sTech
# 	chmod +x Part3-PVE-6to7.sh && bash Part3-PVE-6to7.sh



#Move Bash-Script
	mv Part3-PVE-6to7.sh PVE-6to7/Part3-PVE-6to7.sh

	echo
	echo
	echo

#Update to latest 6.4-X
	echo "----- Update to latest 6.4-X -----"
	apt update && apt upgrade

	echo
	echo
	echo

#Update the configured APT repositories
	echo "----- Update the configured APT repositories -----"
	echo "deb http://ftp.de.debian.org/debian bullseye main contrib

deb http://ftp.de.debian.org/debian bullseye-updates main contrib

# security updates
deb http://security.debian.org bullseye-security main contrib

deb http://download.proxmox.com/debian/pve bullseye pve-no-subscription" > /etc/apt/sources.list

	echo
	echo
	echo

#Change Ceph Repo
	echo "----- Change Ceph Repo -----"
	echo "deb http://download.proxmox.com/debian/ceph-octopus bullseye main" > /etc/apt/sources.list.d/ceph.list

	echo
	echo
	echo

#Update Package-List
	echo "----- Update Package-List -----"
	apt update

	echo
	echo
	echo

#Upgrade System
	echo "----- Upgrade System -----"
	echo "ACHTUNG, Upgrade erst ausführen, wenn 'pve6to7' keine Fehler mehr aufzeigt!"
	echo
	pve6to7
	echo
	echo "ACHTUNG, Upgrade erst ausführen, wenn 'pve6to7' keine Fehler mehr aufzeigt!"
	echo
	while IFS= read -n1 -r -p "Jetzt das Upgrade ausführen? [y]es|[n]o: " && [[ $REPLY != q ]]; do
	case $REPLY in
		y)  echo
			apt dist-upgrade

			break;;
		n)  echo
			echo "Proxmox wurde nicht auf PVE 7.x geupgraded!"
			echo "Falls du das später machen möchtest, gebe folgenden Befehl ein:"
			echo "apt dist-upgrade"
			
			break;;
		*)  echo
			echo "Antoworte mit y oder n";;
	esac
	done

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