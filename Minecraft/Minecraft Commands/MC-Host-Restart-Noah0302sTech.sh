#!/bin/bash
#   Made by Noah0302sTech
#   chmod +x MC-Host-Restart-Noah0302sTech.sh && sudo bash MC-Host-Restart-Noah0302sTech.sh

#----- Check for administrative privileges
  if [[ $EUID -ne 0 ]]; then
    echo "Das Skript muss mit Admin-Privilegien ausgeführt werden! (sudo)"
    exit 1
  fi





#----- Check for MC-Status
  status="$(systemctl is-active minecraftserver.service)"
  if [ "${status}" = "active" ]; then
    #--- Restart Server
      sudo echo 'say Server wird in 5 Sekunden gestoppt...' > /run/minecraftserver.stdin
      sleep 5
      sudo echo 'stop' > /run/minecraftserver.stdin
  elif [ "${status}" = "dead" ]; then
    echo "Der Service hat des Status: $status"
  elif [ "${status}" = "inactive" ]; then
    echo "Der Service hat des Status: $status"
  else
    echo "Der Service hat des Status: $status"
  fi



#----- Check for MC-Status
  status="$(systemctl is-active minecraftserver.service)"
  if [ "${status}" = "active" ]; then
    sleep 5
  elif [ "${status}" = "dead" ]; then
    shutdown -r 1
  elif [ "${status}" = "inactive" ]; then
    echo "Der Service hat des Status: $status"
  else
    echo "Der Service hat des Status: $status"
  fi