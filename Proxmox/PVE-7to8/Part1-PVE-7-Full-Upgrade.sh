#!/bin/bash
#	Made by Noah0302sTech
# 	chmod +x Part1-PVE-7-Full-Upgrade.sh && bash Part1-PVE-7-Full-Upgrade.sh
#	wget https://raw.githubusercontent.com/Noah0302sTech/Bash-Skripte/master/Proxmox/PVE-7to8/Part1-PVE-7-Full-Upgrade.sh && bash Part1-PVE-7-Full-Upgrade.sh



#----------- Init
	#----- echoEnd
		function echoEnd {
			echo
			echo
			echo
			echo
			echo
		}

	#----- Variables
		url="https://raw.githubusercontent.com/Noah0302sTech/Bash-Skripte/master/Proxmox/PVE-7to8/Part2-PVE-7to8.sh"



#Create Folder
	mkdir PVE-7to8

	echoEnd



#Move Bash-Script
	mv Part1-PVE-7-Full-Upgrade.sh PVE-7to8/Part1-PVE-7-Full-Upgrade.sh

	echoEnd



#Ceph
	echo "----- Ceph -----"
		while IFS= read -n1 -r -p "Ist Ceph installiert? [y]es|[n]o: " && [[ $REPLY != q ]]; do
		case $REPLY in
			y)  echo
					echo "ACHTUNG, wenn Ceph installiert ist, muss es MINDESTENS 'Ceph-Quincy (17.x.x) sein!"
						ceph tell osd.* version
						while IFS= read -n1 -r -p "Ist auf Version '17.x.x'? [y]es|[n]o: " && [[ $REPLY != q ]]; do
						case $REPLY in
							y)  echo
									echo "Skript wird fortgeführt!"

								break;;
							n)  echo
									echo "Upgrade kann nicht durchgeführt werden, wenn die Ceph-Version nicht mindestens '17.x.x' oder höher ist"
									echo "Skript wird abgebrochen!"

								exit 0;;
							*)  echo
									echo "Antoworte mit y oder n";;
						esac
						done

				break;;
			n)  echo
					echo "Skript wird fortgeführt!"

				break;;
			*)  echo
					echo "Antoworte mit y oder n";;
		esac
		done

	echoEnd



#Outcomment Enterprise Repo
	echo "----- Enterprise Repo -----"
		echo "ACHTUNG, nur benötigt, wenn keine Lizenz vorhanden ist!"
		while IFS= read -n1 -r -p "Enterprise Repo jetzt deaktivieren? [y]es|[n]o: " && [[ $REPLY != q ]]; do
		case $REPLY in
			y)  echo
					echo "#deb https://enterprise.proxmox.com/debian/pve bullseye pve-enterprise" > /etc/apt/sources.list.d/pve-enterprise.list

				break;;
			n)  echo
					echo "Enterprise-Repo wurde nicht deaktiviert!"

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
					file="/etc/apt/sources.list"
					search_string="pve-no-subscription"

					if grep -q "$search_string\$" "$file"; then
						echo "Already present"
					else
						echo -e "\n#No-Subscription" >> "$file"
						echo "deb http://download.proxmox.com/debian/pve bullseye $search_string" >> "$file"
						echo "Lines appended to $file"
					fi

				break;;
			n)  echo
					echo "No-Subscription-Repo wurde nicht aktiviert!"

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



#Check Version
	echo "----- Check Version -----"
		echo "ACHTUNG, die Version MUSS nun '7.4-15' oder höher anzeigen!"
		pveversion
		while IFS= read -n1 -r -p "Ist die Version höher als '7.4-15'? [y]es|[n]o: " && [[ $REPLY != q ]]; do
		case $REPLY in
			y)  echo
					echo "Führe Skript weiter aus!"

				break;;
			n)  echo
					echo "Skript wird abgebrochen!"
					echo "Upgrade kann nicht durchgeführt werden, wenn die Version nicht mindestens '7.4-15' oder höher ist"

				exit 0;;
			*)  echo
					echo "Antoworte mit y oder n";;
		esac
		done

	echoEnd



#Reboot Node
	echo "----- Reboot Node -----"
		echo "Optionaler Reboot des Nodes, wenn kein neuer Kernel installiert wurde!"
		echo "ACHTUNG, erst Node rebooten, wenn keine VM mehr auf diesem Node läuft!"
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