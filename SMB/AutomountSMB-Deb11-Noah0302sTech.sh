#!/bin/bash
# Made by Noah0302sTech
# chmod +x AutomountSMB-Deb11-Noah0302sTech.sh && sudo ./AutomountSMB-Deb11-Noah0302sTech.sh



#----- Install SMB-Utils
    echo "Installiere SMB-Utilities..."
    sudo apt install cifs-utils -y &> /dev/null &
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
    echo "Erstelle benötigte Files..."

    #----- Password-File
        sudo touch /root/.$FILENAME
        sudo echo "username=$USERNAME
        password=$PASSWORD" > /root/.$FILENAME
        
            #----- Permissions
            sudo chmod 400 /root/.$FILENAME

    #----- SMB-Mount Folder
    sudo mkdir /media/$FOLDERNAME
    echo
    echo



#----- FSTAB
    echo "Erstelle FStab"
    sudo touch /etc/fstab
    sudo echo "//$SHARE /media/$FOLDERNAME cifs vers=3.0,credentials=/root/.$FILENAME" > /etc/fstab



#----- Mount SMB-Share
    echo "Mounte das Netzlaufwerk..."
    sudo mount -t cifs -o rw,vers=3.0,credentials=/root/.$FILENAME //$SHARE /media/$FOLDERNAME