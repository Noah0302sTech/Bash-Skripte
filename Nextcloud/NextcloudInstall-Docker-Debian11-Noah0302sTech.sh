#!/bin/bash
# Made by Noah0302sTech
# chmod +x NextcloudInstall-Docker-Debian11-Noah0302sTech.sh && sudo ./NextcloudInstall-Docker-Debian11-Noah0302sTech.sh



#----- Check for administrative privileges
  if [[ $EUID -ne 0 ]]; then
    echo "Das Skript muss mit Admin-Privilegien ausgeführt werden! (sudo)"
    exit 1
  fi



#----- System Update
  echo "Update das System, bitte warten... "
  sudo apt update -y &> /dev/null &
  PID=$!
  i=1
  sp="/-\|"
  echo -n ' '
  while [ -d /proc/$PID ]
    do
    printf "\b${sp:i++%${#sp}:1}"
  done
  echo
  printf "\xE2\x9C\x94 \n"
  echo
  echo



#----- Install Docker
  echo "Installiere Docker, bitte warten... "
  sudo apt install -y docker.io &> /dev/null &
  PID=$!
  i=1
  sp="/-\|"
  echo -n ' '
  while [ -d /proc/$PID ]
    do
    printf "\b${sp:i++%${#sp}:1}"
  done
  echo
  printf "\xE2\x9C\x94 \n"
  echo
  echo



#----- Install Docker Compose
  echo "Installiere Docker Compose, bitte warten... "
  sudo usermod -aG docker $SUDO_USER
  sudo apt install -y docker-compose &> /dev/null &
  PID=$!
  i=1
  sp="/-\|"
  echo -n ' '
  while [ -d /proc/$PID ]
    do
    printf "\b${sp:i++%${#sp}:1}"
  done
  echo
  printf "\xE2\x9C\x94 \n"
  echo
  echo



#----- Create a folder for Nextcloud
  echo "Erstelle Nextcloud-Ordner, bitte warten... "
  mkdir nextcloud
  if [ -d /home/$SUDO_USER/nextcloud ]; then
    cd /home/$SUDO_USER/nextcloud
  else
    echo "Fehler beim Erstellen des Ordners!"
    exit 1
  fi
  cd nextcloud &> /dev/null &
  PID=$!
  i=1
  sp="/-\|"
  echo -n ' '
  while [ -d /proc/$PID ]
    do
    printf "\b${sp:i++%${#sp}:1}"
  done
  echo
  printf "\xE2\x9C\x94 \n"
  echo
  echo



#----- Set default values for Docker-Compose
  MYSQL_ROOT_PASSWORD=sqlrootpassword
  MYSQL_PASSWORD=sqlpassword

#----- Prompt user for custom values
  read -p "MariaDB-Root-Passwort eigeben [default: $MYSQL_ROOT_PASSWORD]: " input
  MYSQL_ROOT_PASSWORD=${input:-$MYSQL_ROOT_PASSWORD}
  read -p "MariaDB-Passwort eigeben [default: $MYSQL_PASSWORD]: " input
  MYSQL_PASSWORD=${input:-$MYSQL_PASSWORD}
  echo
  echo



#----- Create a Docker Compose file
  echo "Erstelle Docker-Compose-File, bitte warten... "
  touch docker-compose.yml
  echo "version: '3'
services:
  db:
    image: mariadb
    environment:
      - MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD
      - MYSQL_PASSWORD=$MYSQL_PASSWORD
      - MYSQL_DATABASE=nextclouddb
      - MYSQL_USER=nextcloud
    restart: unless-stopped
  nextcloud:
    image: nextcloud
    ports:
      - 8080:80
    volumes:
      - nextcloud_data:/var/www/html
    environment:
      - MYSQL_HOST=db
      - MYSQL_USER=nextcloud
      - MYSQL_PASSWORD=$MYSQL_PASSWORD
      - MYSQL_DATABASE=nextclouddb
    restart: unless-stopped
    depends_on:
      - db
volumes:
  nextcloud_data:
" >> docker-compose.yml
  printf "\xE2\x9C\x94 \n"
  echo
  echo



#----- Start the Nextcloud server
  echo "Starte Nextcloud-Server, bitte warten... "
  docker-compose up -d &> /dev/null &
  PID=$!
  i=1
  sp="/-\|"
  echo -n ' '
  while [ -d /proc/$PID ]
    do
    printf "\b${sp:i++%${#sp}:1}"
  done
  echo
  printf "\xE2\x9C\x94 \n"
  echo
  echo

  sudo docker ps
  echo
  echo



#----- Configure the Nextcloud Server
  cd /home/$SUDO_USER
  sudo wget https://raw.githubusercontent.com/Noah0302sTech/Bash-Skripte/master/Nextcloud/NextcloudConfig-Docker-Noah0302sTech.sh
  sudo chmod +x NextcloudConfig-Docker-Noah0302sTech.sh
  echo "Um NACH DER INSTALLATION die Nextcloud-Config-Datei anzupassen, folgendes Skript:"
  echo "sudo ./NextcloudConfig-Docker-Noah0302sTech.sh"
  echo
  echo