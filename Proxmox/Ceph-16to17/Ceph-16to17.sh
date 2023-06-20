#!/bin/bash
#	Made by Noah0302sTech
# 	chmod +x Ceph-16to17.sh && bash Ceph-16to17.sh



#Move Bash-Script
	mv Ceph-16to17.sh Ceph-16to17/Ceph-16to17.sh

	echo
	echo
	echo

#Update to latest 6.4-X
	echo "----- Update to latest 6.4-X -----"
	apt update && apt upgrade

	echo
	echo
	echo

#Change the current Ceph repositories from Nautilus to Octopus
	echo "----- Change the current Ceph repositories from Nautilus to Octopus -----"
	sed -i 's/nautilus/octopus/' /etc/apt/sources.list.d/ceph.list

	echo
	echo
	echo

#Set the noout flag for the duration of the upgrade (optional, but recommended)
	echo "----- Set the noout flag for the duration of the upgrade (optional, but recommended) -----"
	ceph osd set noout

	echo
	echo
	echo

#Upgrade on each Ceph cluster node
	echo "----- Upgrade on each Ceph cluster node -----"
	apt update && apt full-upgrade
	
	echo
	echo
	echo

#Restart the monitor daemon
	echo "----- Restart the monitor daemon -----"
	systemctl restart ceph-mon.target

	echo
	echo
	echo

#Restart the manager daemon
	echo "----- Restart the manager daemon -----"
	systemctl restart ceph-mgr.target

	echo
	echo
	echo

#Restart the OSD daemon
	echo "----- Restart the OSD daemon-----"
	systemctl restart ceph-osd.target

	echo
	echo
	echo

#Status Ceph
	echo "----- Status Ceph -----"
	ceph status

	echo
	echo
	echo

#Restart the Meta-Data-Servers
	echo "ACHTUNG, die MDS sollten erst neu gestartet werden, wenn alle OSDs des HOSTs geupgraded sind!"
	while IFS= read -n1 -r -p "Jetzt die Meta-Data-Server neu starten? [y]es|[n]o: " && [[ $REPLY != q ]]; do
	case $REPLY in
		y)  echo
			systemctl restart ceph-mds.target

			break;;
		n)  echo
			echo "Meta-Data-Server wurden nicht neu gestartet!"
			echo "Falls du das später machen möchtest, gebe folgenden Befehl ein:"
			echo "systemctl restart ceph-mds.target"
			
			break;;
		*)  echo
			echo "Antoworte mit y oder n";;
	esac
	done

	echo
	echo
	echo

#Info Disallow pre-Octopus OSDs and enable all new Octopus-only functionality
	echo "ACHTUNG, allow Octopus-only functionality sollten erst aktiviert werden, wenn ALLE OSDs des CLUSTERs geupgraded sind!"
	while IFS= read -n1 -r -p "Jetzt Octopus-only functionality aktivieren? [y]es|[n]o: " && [[ $REPLY != q ]]; do
	case $REPLY in
		y)  echo
			ceph osd require-osd-release octopus

			break;;
		n)  echo
			echo "Octopus-only functionality wurde nicht aktiviert!"
			echo "Falls du das später machen möchtest, gebe folgenden Befehl ein:"
			echo "ceph osd require-osd-release octopus"
			
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
			echo "Node wurde nicht rebotet!"
			
			break;;
		*)  echo
			echo "Antoworte mit y oder n";;
	esac
	done

	echo
	echo
	echo