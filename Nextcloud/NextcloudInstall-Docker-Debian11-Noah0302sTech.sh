#!/bin/bash
# Made by Noah0302sTech
# chmod +x NextcloudInstall-Docker-Debian11-Noah0302sTech.sh && sudo ./NextcloudInstall-Docker-Debian11-Noah0302sTech.sh



#----- Check for administrative privileges
  if [[ $EUID -ne 0 ]]; then
    echo "Das Skript muss mit Admin-Privilegien ausgeführt werden! (sudo)"
    exit 1
  fi



#----- Source of Spinner-Function: https://github.com/tlatsas/bash-spinner
    function _spinner() {
        # $1 start/stop
        #
        # on start: $2 display message
        # on stop : $2 process exit status
        #           $3 spinner function pid (supplied from stop_spinner)

        local on_success="DONE"
        local on_fail="FAIL"
        local white="\e[1;37m"
        local green="\e[1;32m"
        local red="\e[1;31m"
        local nc="\e[0m"

        case $1 in
            start)
                # calculate the column where spinner and status msg will be displayed
                let column=$(tput cols)-${#2}-8
                # display message and position the cursor in $column column
                echo -ne ${2}
                printf "%${column}s"

                # start spinner
                i=1
                sp='\|/-'
                delay=${SPINNER_DELAY:-0.15}

                while :
                do
                    printf "\b${sp:i++%${#sp}:1}"
                    sleep $delay
                done
                ;;
            stop)
                if [[ -z ${3} ]]; then
                    echo "spinner is not running.."
                    exit 1
                fi

                kill $3 > /dev/null 2>&1

                # inform the user uppon success or failure
                echo -en "\b["
                if [[ $2 -eq 0 ]]; then
                    echo -en "${green}${on_success}${nc}"
                else
                    echo -en "${red}${on_fail}${nc}"
                fi
                echo -e "]"
                ;;
            *)
                echo "invalid argument, try {start/stop}"
                exit 1
                ;;
        esac
    }

    function start_spinner {
        # $1 : msg to display
        _spinner "start" "${1}" &
        # set global spinner pid
        _sp_pid=$!
        disown
    }

    function stop_spinner {
        # $1 : command exit status
        _spinner "stop" $1 $_sp_pid
        unset _sp_pid
    }





#----- Refresh Packages
  start_spinner "Aktualisiere Package-Listen..."
    sudo apt update -y > /dev/null 2>&1
  stop_spinner $?

  echo
  echo



#----- Docker
  #--- Install Docker
    start_spinner "Installiere docker.io..."
      sudo apt install -y docker.io > /dev/null 2>&1
    stop_spinner $?
    echo

  #--- Install Docker Compose
    start_spinner "Installiere Docker-Compose..."
      sudo apt install -y docker-compose > /dev/null 2>&1
    stop_spinner $?
    echo

  #--- Install Docker
    start_spinner "Füge $SUDO_USER zu Docker-Gruppe hinzu..."
      sudo usermod -aG docker $SUDO_USER > /dev/null 2>&1
    stop_spinner $?

  echo
  echo



#----- Create a folder for Nextcloud
  start_spinner "Erstelle Nextcloud-Ordner..."
    mkdir nextcloud
    if [ -d /home/$SUDO_USER/nextcloud ]; then
      cd /home/$SUDO_USER/nextcloud
    else
      echo "Fehler beim Erstellen des Ordners!"
      exit 1
    fi
    cd nextcloud > /dev/null 2>&1&
  stop_spinner $?

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
  echo "Erstelle Docker-Compose-File... "
  sudo touch docker-compose.yml
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

  echo
  echo



#----- Start the Nextcloud server
  start_spinner "Starte Nextcloud-Server... "
    docker-compose up -d > /dev/null 2>&1&
  stop_spinner $?
  sudo docker ps

  echo
  echo



#----- Configure the Nextcloud Server
  start_spinner "Erstelle Nextcloud-Config-Skript... "
    cd /home/$SUDO_USER > /dev/null 2>&1&
    sudo wget https://raw.githubusercontent.com/Noah0302sTech/Bash-Skripte/master/Nextcloud/NextcloudConfig-Docker-Noah0302sTech.sh > /dev/null 2>&1&
    sudo chmod +x NextcloudConfig-Docker-Noah0302sTech.sh > /dev/null 2>&1&
  stop_spinner $?
  echo "Um NACH DER INSTALLATION die Nextcloud-Config anzupassen, starte das Nextcloud-Config-Skript mit:"
  echo "sudo ./NextcloudConfig-Docker-Noah0302sTech.sh"

  echo
  echo