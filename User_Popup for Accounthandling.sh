#!/bin/bash

    loggedInUser=$( echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ { print $3 }' )
	jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
	windowType="hud"
	description="Your user Account will be deleted after logout. If you want to keep it saved for 7 days, please press keep."
	FILE='/Users/Shared/usersToDelete.txt'
	button1="Keep"
	button2="OK"
	#icon="/Library/Application Support/JAMF/JamfCustomApps/Company_logo.png"
	title="Account Deletion"
	alignDescription="left" 
	alignHeading="center"
	defaultButton="2"
	timeout="60"
    if [[ ! -d /Users/Shared ]]; then
   				mkdir /Users/Shared
   	fi

	# JAMF Helper window as it appears for targeted computers
    if [[ $loggedInUser == "Admin" ]] || [[ $loggedInUser == "mediaspace" ]] || [[ $loggedInUser == "admenroll" ]] || [[ $loggedInUser == "LabSpace" ]]; then 
    	echo "$loggedInUser is not to be deleted. Skipping dialog."
    else
        userChoice=$("$jamfHelper" -windowType "$windowType" -lockHUD -title "$title" -timeout "$timeout" -defaultButton "$defaultButton" -icon "$icon" -description "$description" -alignDescription "$alignDescription" -alignHeading "$alignHeading" -button1 "$button1" -button2 "$button2")
		# If user selects "Keep"
		if [ "$userChoice" == "0" ]; then
   			echo "User clicked Keep; Doing nothing"
   			exit
		# If user selects "OK"
		elif [ "$userChoice" == "2" ]; then
   			echo "User clicked OK or timeout was reached; adding account to deletion file."
   			if [[ ! -f $FILE ]]; then
   				touch $FILE
   			fi
        	if [[ $loggedInUser == "Admin" ]] || [[ $loggedInUser == "mediaspace" ]] || [[ $loggedInUser == "admenroll" ]] || [[ $loggedInUser == "LabSpace" ]]; then
            	echo "Check 2: $loggedInUser is not added to deletion list"
            else
				grep -xqF -- "$loggedInUser" "$FILE" || echo "$loggedInUser" >> "$FILE"
   				#echo $loggedInUser >> /Users/Shared/usersToDelete.txt
        	fi   
		fi
    fi
	exit