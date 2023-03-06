#!/bin/bash
# Made by Noah0302sTech
# chmod +x AutomountSMB-Deb11-Noah0302sTech.sh && sudo ./AutomountSMB-Deb11-Noah0302sTech.sh



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





#----- Install SMB-Utils
    start_spinner "Installiere SMB-Utilities..."
        sudo apt install cifs-utils -y > /dev/null 2>&1
    stop_spinner $?
    echo
    echo



#----- Set default values
    FILENAME=filename
    SHARE=192.168.x.x/SMB-Share
    USERNAME=username
    PASSWORD=password1
    FOLDERNAME=smbmount



#----- Prompt for custom values
    read -p "Gib den Namen für das versteckte Passwort-File ein [default: $FILENAME]: " input
    FILENAME=${input:-$FILENAME}
    read -p "Gib die IP deines Servers ein [default: $SHARE]: " input
    SHARE=${input:-$SHARE}
    read -p "Gib den User-Namen für den SMB-Share ein [default: $USERNAME]: " input
    USERNAME=${input:-$USERNAME}
    read -p "Gib das Passwort für den SMB-Share ein [default: $PASSWORD]: " input
    PASSWORD=${input:-$PASSWORD}
    read -p "Gib den Name für den lokalen SMB-Mount-Folder ein [default: /media/$FOLDERNAME]: " input
    FOLDERNAME=${input:-$FOLDERNAME}
    echo
    echo


#----- Create Files

    #----- Password-File
        start_spinner "Erstelle User-Credential-Files..."
            sudo touch /root/.$FILENAME
            sudo echo "username=$USERNAME
            password=$PASSWORD" > /root/.$FILENAME
        stop_spinner $?
        
        #----- Permissions
            start_spinner "Modifiziere Permissions..."
                sudo chmod 400 /root/.$FILENAME
            stop_spinner $?

    #----- SMB-Mount Folder
        start_spinner "Modifiziere Permissions..."
            sudo mkdir /media/$FOLDERNAME
        stop_spinner $?
    
    echo
    echo



#----- FSTAB
    start_spinner "Erstelle FStab..."
        sudo touch /etc/fstab
        sudo echo "//$SHARE /media/$FOLDERNAME cifs vers=3.0,credentials=/root/.$FILENAME" > /etc/fstab
    stop_spinner $?
    



#----- Mount SMB-Share
    start_spinner "Mounte das Netzlaufwerk..."
        sudo mount -t cifs -o rw,vers=3.0,credentials=/root/.$FILENAME //$SHARE /media/$FOLDERNAME
    stop_spinner $?

    echo
    echo