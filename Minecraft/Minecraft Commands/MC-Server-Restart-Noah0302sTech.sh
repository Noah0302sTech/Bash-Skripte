#!/bin/bash
#   Made by Noah0302sTech
#   chmod +x MC-Server-Restart-Noah0302sTech.sh && sudo ./MC-Server-Restart-Noah0302sTech.sh

#----- Check for administrative privileges
  if [[ $EUID -ne 0 ]]; then
    echo "Das Skript muss mit Admin-Privilegien ausgeführt werden! (sudo)"
    exit 1
  fi



#----- Restart Server
  sudo echo 'say Server will be restarted in 5 Seconds...' > /run/minecraftserver.stdin
  sleep 5
  sudo systemctl restart minecraftserver.service