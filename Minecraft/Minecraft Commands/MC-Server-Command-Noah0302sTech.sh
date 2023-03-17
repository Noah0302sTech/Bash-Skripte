#!/bin/bash
#   Made by Noah0302sTech
#   chmod +x MC-Server-Command-Noah0302sTech.sh && sudo ./MC-Server-Command-Noah0302sTech.sh

#----- Check for administrative privileges
  if [[ $EUID -ne 0 ]]; then
    echo "Das Skript muss mit Admin-Privilegien ausgeführt werden! (sudo)"
    exit 1
  fi



#----- Set default values
    COMMAND="say Hallo!"



#----- Prompt for custom values
    COMMAND="$@"



#----- Execute
    sudo echo $COMMAND > /run/minecraftserver.stdin