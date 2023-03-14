#!/bin/bash
#   Made by Noah0302sTech
#   chmod +x MC-Server-Start-Noah0302sTech.sh && sudo ./MC-Server-Start-Noah0302sTech.sh

#----- Check for administrative privileges
  if [[ $EUID -ne 0 ]]; then
    echo "Das Skript muss mit Admin-Privilegien ausgeführt werden! (sudo)"
    exit 1
  fi



#----- Restart Server
  sudo systemctl restart minecraftserver.service