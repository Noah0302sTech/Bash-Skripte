#!/bin/bash
#	Made by Noah0302sTech
# 	chmod +x Part2-PVE-7to8.sh && bash Part2-PVE-7to8.sh
#	wget https://raw.githubusercontent.com/Noah0302sTech/Bash-Skripte/master/Proxmox/PVE-7to8/Part2-PVE-7to8.sh && bash Part2-PVE-7to8.sh



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



#Move Bash-Script
	mv Part2-PVE-7to8.sh PVE-6to7/Part2-PVE-7to8.sh

	echoEnd



#Update to latest 7.4.x
	echo "----- Update to latest 7.4.x -----"
		apt update && apt dist-upgrade

	echoEnd



#Update the configured APT repositories
	echo "----- Update the configured APT repositories -----"
		sed -i 's/bullseye/bookworm/g' /etc/apt/sources.list

		file="/etc/apt/sources.list.d/pve-install-repo.list"
		if [ -e "$file" ]; then
			sed -i -e 's/bullseye/bookworm/g' /etc/apt/sources.list.d/pve-install-repo.list
		fi


	echoEnd



#Change Ceph Repo
	echo "----- Change Ceph Repo -----"
		while IFS= read -n1 -r -p "Ist Ceph installiert? [y]es|[n]o: " && [[ $REPLY != q ]]; do
		case $REPLY in
			y)  echo
					echo "ACHTUNG, wenn Ceph installiert ist, muss es MINDESTENS 'Ceph-Quincy (17.x.x) sein!"
						ceph tell osd.* version
						while IFS= read -n1 -r -p "Ist auf Version '17.x.x'? [y]es|[n]o: " && [[ $REPLY != q ]]; do
						case $REPLY in
							y)  echo
									echo "deb http://download.proxmox.com/debian/ceph-quincy bookworm no-subscription" > /etc/apt/sources.list.d/ceph.list
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
					ceph_list="/etc/apt/sources.list.d/ceph.list"
					content="deb http://download.proxmox.com/debian/ceph-quincy bookworm no-subscription"
						if [[ -f "$ceph_list" ]]; then
							echo "$content" > "$ceph_list"
						fi
					echo "Skript wird fortgeführt!"

				break;;
			*)  echo
					echo "Antoworte mit y oder n";;
		esac
		done

	echoEnd



#Update Package-List
	echo "----- Update Package-List -----"
		apt update

	echoEnd



#Upgrade System
	echo "----- Upgrade System -----"
		echo "ACHTUNG, Upgrade erst ausführen, wenn 'pve7to8' keine Fehler mehr aufzeigt!"
		echo
		pve7to8 -full
		echo
		echo "ACHTUNG, Upgrade erst ausführen, wenn 'pve7to8' keine Fehler mehr aufzeigt!"
		echo
		while IFS= read -n1 -r -p "Jetzt das Upgrade ausführen? [y]es|[n]o: " && [[ $REPLY != q ]]; do
		case $REPLY in
			y)  echo
					apt dist-upgrade

				break;;
			n)  echo
					echo "Proxmox wurde nicht auf PVE 8.x geupgraded!"
					echo "Falls du das später machen möchtest, gebe folgenden Befehl ein:"
					echo "apt dist-upgrade"

				break;;
			*)  echo
					echo "Antoworte mit y oder n";;
		esac
		done

	echoEnd



#PVE-Version Check
	echo "----- PVE-Version Check -----"
		echo "ACHTUNG, die Proxmox-Version muss nun '8.0.3' oder höher sein!"
		pveversion
		while IFS= read -n1 -r -p "Ist die PVE-Version '8.0.3' oder höher? [y]es|[n]o: " && [[ $REPLY != q ]]; do
		case $REPLY in
			y)  echoEnd
					#Reboot Node
						echo "----- Reboot Node -----"
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
										echo "Node wurde nicht rebotet! Neue Kernel-Version noch nicht aktiv!"

									break;;
								*)  echo
										echo "Antoworte mit y oder n";;
							esac
							done

					echoEnd

				break;;
			n)  echo
					echo "Das PVE-Upgrade wurde nicht ordnungsgemäß durchgefüht!"
					echo "Prüfe nach möglichen Error-Logs!"
					echo
					echo "Mögliche Lösungswege:"
					echo "apt -o Debug::pkgProblemResolver=yes install qemu-server
apt -o Debug::pkgProblemResolver=yes install pve-manager"

				break;;
			*)  echo
					echo "Antoworte mit y oder n";;
		esac
		done

	echoEnd