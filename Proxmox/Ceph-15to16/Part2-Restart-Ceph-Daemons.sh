#!/bin/bash
#	Made by Noah0302sTech
# 	chmod +x Part2-Restart-Ceph-Daemons.sh && bash Part2-Restart-Ceph-Daemons.sh
#	curl -sSL https://raw.githubusercontent.com/Noah0302sTech/Bash-Skripte/testing/Proxmox/Ceph-15to16/Part2-Restart-Ceph-Daemons.sh | bash

#TODO:	Alles ab Ceph-OSDs neu starten überprüfen

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
				echo
				echo "Falls sie nicht geupgraded sind, kann das auch per GUI gemacht werden!"
				echo;;

			*)  echo
				echo "Antoworte mit y oder n";;
				
		esac
		done

	echoEnd



#Restart the OSD daemon on all nodes
	echo "ACHTUNG, erst alle Ceph-OSDs neu starten, wenn alle Ceph-Manager geupgraded sind! [mon: 3 daemons, quorum...]"
		ceph -s
		while IFS= read -n1 -r -p "Sind alle Ceph-Manager geupgraded? [y]es|[n]o: " && [[ $REPLY != q ]]; do
		case $REPLY in
			y)  echo
				systemctl restart ceph-osd.target

				break;;

			n)  echo
				sleep 5
				ceph -s
				echo
				echo "Falls sie nicht geupgraded sind, kann das auch per GUI gemacht werden!"
				echo;;

			*)  echo
				echo "Antoworte mit y oder n";;
				
		esac
		done

	echoEnd



#Disallow pre-Pacific OSDs and enable all new Pacific-only functionality
	echo "ACHTUNG, allow Pacific-only functionality sollten erst aktiviert werden, wenn ALLE OSDs des CLUSTERs geupgraded sind!"
		ceph tell osd.* version
		while IFS= read -n1 -r -p "Sind alle Ceph-Monitore geupgraded? [y]es|[n]o: " && [[ $REPLY != q ]]; do
		case $REPLY in
			y)  echo
				ceph osd require-osd-release pacific

				break;;

			n)  echo
				sleep 5
				ceph tell osd.* version
				echo
				echo "Falls sie nicht geupgraded sind, kann das auch per GUI gemacht werden!"
				echo;;

			*)  echo
				echo "Antoworte mit y oder n";;
				
		esac
		done

	echoEnd



#Upgrade all CephFS MDS daemons
	echo "ACHTUNG, allow CephFS-MDS sollten erst geupgraded werden, wenn ALLE non-zero ranks deaktiviert sind!"
		ceph status
		while IFS= read -n1 -r -p "Sind ALLE non-zero ranks deaktiviert [y]es|[n]o: " && [[ $REPLY != q ]]; do
		case $REPLY in
			y)  echo
				systemctl restart ceph-mds.target

				break;;

			n)  echo
				sleep 5
				ceph status
				echo
				echo "Falls sie nicht geupgraded sind, kann das auch per GUI gemacht werden!"
				echo;;

			*)  echo
				echo "Antoworte mit y oder n";;
				
		esac
		done

	echoEnd



#Unset the 'noout' flag
	echo "ACHTUNG, noout flag erst deaktivieren, wenn ALLES fertig ist!"
		while IFS= read -n1 -r -p "Sind alle Nodes geupgraded? [y]es|[n]o: " && [[ $REPLY != q ]]; do
		case $REPLY in
			y)  echo
				ceph osd unset noout

				break;;

			n)  echo
				sleep 5;;
				
				
			*)  echo
				echo "Antoworte mit y oder n";;

		esac
		done

	echoEnd