#!/bin/bash
# Made by Noah0302sTech

#Update
	upgradeOutput=$(apt-get update && apt-get dist-upgrade -y 2>&1)

#Debug
	echo "Proxmox-Updater Cron-Job ran @" >> /root/Noah0302sTech/$folderVar/Cron-Debug.txt
	date >> /root/Noah0302sTech/$folderVar/Cron-Debug.txt 
	echo $upgradeOutput >> /root/Noah0302sTech/$folderVar/Cron-Debug.txt 
	echo '' >> /root/Noah0302sTech/$folderVar/Cron-Debug.txt" > /root/Proxmox-UpdateUpgrade-Noah0302sTech.sh