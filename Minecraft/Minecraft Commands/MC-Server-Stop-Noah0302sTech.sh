#!/bin/bash
#   Made by Noah0302sTech
#   chmod +x MC-Server-Stop-Noah0302sTech.sh && sudo ./MC-Server-Stop-Noah0302sTech.sh

#----- Check for administrative privileges
  if [[ $EUID -ne 0 ]]; then
    echo "Das Skript muss mit Admin-Privilegien ausgeführt werden! (sudo)"
    exit 1
  fi



#----- Restart Server
  sudo echo 'say Server will be stopped in 5 Seconds...' > /run/minecraftserver.stdin
  sleep 5
  sudo echo 'stop' > /run/minecraftserver.stdin