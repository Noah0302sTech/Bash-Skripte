#!/bin/bash
#   Made by Noah0302sTech
#   chmod +x MC-Server-Start-Noah0302sTech.sh && sudo ./MC-Server-Start-Noah0302sTech.sh

#----- Check for administrative privileges
	if [[ $EUID -ne 0 ]]; then
		echo "Das Skript muss mit Admin-Privilegien ausgeführt werden! (sudo)"
		exit 1
	fi



#----- Check for MC-Status
	status="$(systemctl is-active minecraftserver.service)"
	if [ "${status}" = "active" ]; then
		echo "Der Service hat des Status: $status"
	elif [ "${status}" = "dead" ]; then
		echo "Der Service hat des Status: $status"
	elif [ "${status}" = "inactive" ]; then
		#--- Restart Server
		sudo systemctl restart minecraftserver.service
	else
		echo "Der Service hat des Status: $status"
	fi