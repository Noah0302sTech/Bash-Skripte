#!/bin/bash
#	Made by Noah0302sTech
# 	chmod +x Part1-Upgrade-Ceph-on-each-Node.sh && bash Part1-Upgrade-Ceph-on-each-Node.sh
#	wget https://raw.githubusercontent.com/Noah0302sTech/Bash-Skripte/testing/Proxmox/Ceph-16to17/Part1-Upgrade-Ceph-on-each-Node.sh && bash Part1-Upgrade-Ceph-on-each-Node.sh



#----------- Init
	#----- echoEnd
		function echoEnd {
			echo
			echo
			echo
		}

	#----- Variables
		url="https://raw.githubusercontent.com/Noah0302sTech/Bash-Skripte/testing/Proxmox/Ceph-16to17/Part2-Restart-Ceph-Daemons.sh"



#Move Bash-Script
	mkdir Ceph-16to17
	mv Part1-Upgrade-Ceph-on-each-Node.sh Ceph-16to17/Part1-Upgrade-Ceph-on-each-Node.sh

	echoEnd



#Update to latest 7.X-X
	echo "----- Update to latest 7.X-X -----"
		apt update && apt dist-upgrade

	echoEnd



#Enable msgrv2 protocol and update Ceph configuration
	echo "----- Enable msgrv2 protocol -----"
		ceph mon enable-msgr2
		ceph mon dump
		echo

		echo "Alle Ceph-Monitore MÜSSEN ein v1 UND eine v2 Addresse haben!"
		while IFS= read -n1 -r -p "Sind v1 UND v2 verfügbar? [y]es|[n]o: " && [[ $REPLY != q ]]; do
		case $REPLY in
			y)  echo

				break;;

			n)  echo

				echo "Warte 5 weitere Sekunden..."
				sleep 5
				ceph mon dump
				echo;;

			*)  echo
				echo "Antoworte mit y oder n";;
				
		esac
		done

	echoEnd



#Change the current Ceph repositories from Pacific to Quincy
	echo "----- Change the current Ceph repositories from Pacific to Quincy -----"
		sed -i 's/pacific/quincy/' /etc/apt/sources.list.d/ceph.list

	echoEnd



#Set the noout flag for the duration of the upgrade (optional, but recommended)
	echo "----- Set the noout flag for the duration of the upgrade (optional, but recommended) -----"
		ceph osd set noout

	echoEnd



#Upgrade on each Ceph cluster node
	echo "----- Upgrade on each Ceph cluster node -----"
		apt update && apt full-upgrade

	echoEnd



#Continue with Part2
	echo "ACHTUNG, erst bei Part2 weitermachen, wenn alle Nodes geupgraded sind!"
		while IFS= read -n1 -r -p "Sind alle Nodes geupgraded? [y]es|[n]o: " && [[ $REPLY != q ]]; do
		case $REPLY in
			y)  echo
				wget $url
				bash Part2-Restart-Ceph-Daemons.sh

				break;;
			n)  echo
				echo "Part 2 wurde noch nicht ausgeführt!"
				wget $url
				
				break;;
			*)  echo
				echo "Antoworte mit y oder n";;

		esac
		done

	echoEnd