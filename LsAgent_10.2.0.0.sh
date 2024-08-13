#!/bin/zsh

SERVICE='LsAgent'
LsAgent_URL="https://cdn.lansweeper.com/download/10.2.0/0/LsAgent-osx.dmg"
LsAgent_ini="/Applications/LansweeperAgent/LsAgent.ini"
x=0
temp="/tmp/Installer_LS"

#Cleaning
if test -s $temp/mount
then
	hdiutil detach $temp/mount
	rm -rf $temp
fi


# Check that LanSweeper agent is working correctly
if ! test -s $LsAgent_ini; then  x=1;echo "File not exist/is empty"; fi
if ! [ $(grep "Version=10.2.0.0" $LsAgent_ini) ]; then x=1; grep "Version=" $LsAgent_ini; fi
if ! [ $(grep "Status=Running" $LsAgent_ini) ]; then x=1; grep "Status=" $LsAgent_ini; fi
if ! [ $(grep "Enabled=1" $LsAgent_ini) ]; then x=1; grep "Enabled=" $LsAgent_ini; fi
if ! [ $(grep "AgentKey=xxx-xxx-xxx" $LsAgent_ini) ]; then x=1; echo "AgentKey="; fi
if ! [ ${$(grep "LastScan=" $LsAgent_ini)//'LastScan='} ]; then x=1; grep "LastScan=" $LsAgent_ini; fi
if ! [ ${$(grep "LastSent=" $LsAgent_ini)//'LastSent='} ]; then x=1; grep "LastSent=" $LsAgent_ini; fi
if [ ${$(grep "Server=" $LsAgent_ini)//'Server='} ]; then x=1; grep "Server=" $LsAgent_ini; fi

# echo $x
# Check installed version
if [ "$x" -eq 0 ]
then
	echo "OK."
	LsAgent_ver_end=$(cat $LsAgent_ini | grep Version)
	echo "End: $LsAgent_ver_end"
	exit 0
else
	mkdir -p $temp/mount
	curl -Ss $LsAgent_URL > $temp/2.dmg
	hdiutil attach -noverify -nobrowse -mountpoint $temp/mount $temp/2.dmg
	echo "Install."
	$temp/mount/LsAgent-osx.app/Contents/MacOS/installbuilder.sh --mode unattended --agentkey 'xxx-xxx-xxx'
	hdiutil detach $temp/mount
	rm -rf $temp
	LsAgent_ver_end=$(cat $LsAgent_ini | grep Version)
	echo "end: $LsAgent_ver_end"
	exit 0
fi

if ps ax | grep -v grep | grep $SERVICE &> /dev/null
                    then
                        echo "$App ON."
                        exit 0
                    else
                        echo "$App OFF."
                fi