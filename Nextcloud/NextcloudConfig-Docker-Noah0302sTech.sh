#!/bin/bash
# Made by Noah0302sTech
# chmod +x NextcloudConfig-Noah0302sTech.sh && sudo ./NextcloudConfig-Noah0302sTech.sh

#----- Check for administrative privileges
  if [[ $EUID -ne 0 ]]; then
    echo "Das Skript muss mit Admin-Privilegien ausgeführt werden! (sudo)"
    exit 1
  fi

#----- Anpassen der Config
    sudo nano /var/lib/docker/volumes/nextcloud_nextcloud_data/_data/config/config.php

#----- Docker neu starten
    while true; do
        read -p "Möchtest du die Docker-Container jetzt neustarten [empfohlen]? Y/N: " yn
        case $yn in
            [Yy]* ) echo "Starte Docker-Container neu, bitte warten... " && sudo docker restart $(docker ps -q) &> /dev/null &
                    PID=$!
                    i=1
                    sp="/-\|"
                    echo -n ' '
                    while [ -d /proc/$PID ]
                      do
                      printf "\b${sp:i++%${#sp}:1}"
                    done
                    echo
                    printf "\xE2\x9C\x94 \n"; break;;
            [Nn]* ) exit;;
            * ) echo "Bitte gib Y/y für Ja, oder N/n für Nein ein.";;
        esac
    done
    echo
    echo
    sudo docker ps
    echo
    echo