#!/bin/bash
#	Made by Noah0302sTech
# 	chmod +x Part2-Restart-Ceph-Daemons.sh && bash Part2-Restart-Ceph-Daemons.sh
#	curl -sSL https://raw.githubusercontent.com/Noah0302sTech/Bash-Skripte/testing/Proxmox/Ceph-15to16/Part2-Restart-Ceph-Daemons.sh | bash



#----------- Init
	#----- echoEnd
		function echoEnd {
			echo
			echo
			echo
		}

	#----- Variables
		url="XXXXXXXXXX"



#Move Bash-Script
	mv Part2-Restart-Ceph-Daemons.sh Ceph-15to16/Part2-Restart-Ceph-Daemons.sh

	echoEnd



#Restart the monitor daemon
	echo "----- Restart the monitor daemon -----"
		systemctl restart ceph-mon.target

	echoEnd



#Restart the manager daemons on all nodes
	echo "ACHTUNG, erst Ceph-Manager-Daemons neu starten, wenn alle Ceph-Monitore geupgraded sind! [min_mon_release 16 (pacific)]"
		ceph mon dump | grep min_mon_release
		while IFS= read -n1 -r -p "Sind alle Ceph-Monitore geupgraded? [y]es|[n]o: " && [[ $REPLY != q ]]; do
		case $REPLY in
			y)  echo
				systemctl restart ceph-mgr.target

				break;;

			n)  echo

				echo "Warte 5 weitere Sekunden..."
				sleep 5
				ceph mon dump | grep min_mon_release
				echo;;

			*)  echo
				echo "Antoworte mit y oder n";;
				
		esac
		done

	echoEnd



#Restart the OSD daemon on all nodes
	echo "ACHTUNG, erst alle Ceph-OSDs neu starten, wenn alle Ceph-Manager geupgraded sind! [HEALTH_OK]"
		ceph status
		while IFS= read -n1 -r -p "Sind alle Ceph-Monitore geupgraded? [y]es|[n]o: " && [[ $REPLY != q ]]; do
		case $REPLY in
			y)  echo
				systemctl restart ceph-osd.target

				break;;
			n)  echo
				sleep 5
				ceph status;;

			*)  echo
				echo "Antoworte mit y oder n";;
				
		esac
		done

	echoEnd



#Disallow pre-Pacific OSDs and enable all new Pacific-only functionality
	echo "ACHTUNG, allow Pacific-only functionality sollten erst aktiviert werden, wenn ALLE OSDs des CLUSTERs geupgraded sind!"
		ceph status
		while IFS= read -n1 -r -p "Sind alle Ceph-Monitore geupgraded? [y]es|[n]o: " && [[ $REPLY != q ]]; do
		case $REPLY in
			y)  echo
				ceph osd require-osd-release pacific

				break;;
			n)  echo
				sleep 5
				ceph tell osd.* version;;

			*)  echo
				echo "Antoworte mit y oder n";;
				
		esac
		done

	echoEnd



#Upgrade all CephFS MDS daemons
	echo "ACHTUNG, allow CephFS-MDS sollten erst geupgraded werden, wenn ALLE non-zero ranks deaktiviert sind!"
		ceph status
		while IFS= read -n1 -r -p "Sind alle Ceph-Monitore geupgraded? [y]es|[n]o: " && [[ $REPLY != q ]]; do
		case $REPLY in
			y)  echo
				ceph osd require-osd-release pacific

				break;;
			n)  echo
				sleep 5
				ceph status;;

			*)  echo
				echo "Antoworte mit y oder n";;
				
		esac
		done

	echoEnd