#!/bin/sh

## Introduction
#The Zoom Version Checker Script is a shell script designed for macOS systems to automate the process of checking the installed version of the Zoom application and updating it if necessary. The script performs the following key functions:
#1. **Checks if Zoom is Installed**: It verifies whether the Zoom application is present in the `/Applications` directory.
#2. **Checks the Installed Version**: It retrieves the currently installed version of Zoom.
#3. **Checks for a Newer Version**: It queries the Zoom server to determine if a newer version is available for download.
#4. **Checks Lock Screen Status**: It ensures that the screen is unlocked before proceeding with the installation, preventing interruptions during the update process.
#5. **Installs Zoom**: If a newer version is available and the application is not currently running, it downloads and installs the latest version of Zoom.

function screenIsUnlock { [ "$(/usr/libexec/PlistBuddy -c "print :IOConsoleUsers:0:CGSSessionScreenIsLocked" /dev/stdin 2>/dev/null <<< "$(ioreg -n Root -d1 -a)")" != "true" ] && return 0 || return 1; }

# Checking that it is installed
if ls /Applications | grep zoom.us.app &> /dev/null
    then
        z_inst=0
    else
        echo "Z not exist."
        exit 0
fi

#Install Zoom
function installZoom () {
    COUNTER=0
    while screenIsUnlock
    do 
        COUNTER=$((COUNTER+5))
        sleep 5
    done
    COUNTER=$((COUNTER/60))
    echo "Screen was locked: " $COUNTER "min."
    echo "Installing Zoom."
    temp="/tmp/Installer_Zoom"
    rm -rf $temp
    mkdir -p $temp
    cd $temp
    curl $url_downl > $temp/zoom.pkg || exit 5
    sudo installer -pkg zoom.pkg -target /
    killall zoom.us
    cd ..
    rm -r $temp
}



#Checking the installed version
foo=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" /Applications/zoom.us.app/Contents/Info.plist)
foo=${foo//' ('/.}
ZoomInsVer=${foo//')'/}
#echo "inst: "$ZoomInsVer | LC_ALL=C cat -vt

#Checking the web version & downloading the link
echo "sprawdzanie wersji url."
a=$(curl -I --http2 "https://zoom.us/client/latest/Zoom.pkg" | grep location) || exit 1
echo "sprawdzona wersja url."
prefix="location: https://cdn.zoom.us/prod/"
suffix="/Zoom.pkg" 
b=${a:10}
echo "b: "$b

url_downl="${b//$'\r'}" # Kasuje ^M który jest na końcu zmiennej
echo "url_down: " $url_downl
ZoomWebVer=$(echo $a | cut -c$((${#prefix}+1))- | rev | cut -c$((${#suffix}+2))- | rev)
#echo "web: "$ZoomWebVer | LC_ALL=C cat -vt
#echo "Link do najnowszej wersji: ""'$url_downl'" | LC_ALL=C cat -vt

#Checking whether it is running
if ps ax | grep -v grep | grep zoom.us &> /dev/null
    then
        #echo "Z ON."
        z_serv=0
    else
        #echo "Z OFF."
        z_serv=1  
fi

##Check if the lower version is on the web! (autopudate from the application)
if [ "$ZoomInsVer" == "$ZoomWebVer" ]
    then
    #echo "Ta sama wersja."
    compare_ver=0
    else
    #echo "Róźne wersje."
    compare_ver=1
fi

#Possible installation
if [ "$compare_ver" -eq 1 ]
    then 
        if [ "$z_serv" -eq 1 ]
            then
                echo "Będziemy instalować."
                echo "Web: "$ZoomWebVer 
                echo "Inst: "$ZoomInsVer
                installZoom
                exit 0
            else
                echo "Z ON, skip install."
                echo "Web: "$ZoomWebVer 
                echo "Inst: "$ZoomInsVer
                exit 3
        fi
    else
        echo "Ta sama wersja. Skip."
        echo "Web: "$ZoomWebVer 
        echo "Inst: "$ZoomInsVer
        exit 0
fi
