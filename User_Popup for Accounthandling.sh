#!/bin/zsh
#===============================================================================
# Script Name   : User_Popup for Accounthandling.sh
# Author        : Benjamin Bernert - Senior System Engineer - bbernert@dq-solutions.ch
# Created On    : 2025-01-09
# Version       : 1.1
# Description   : Shows the user a popup window to select if user account should be cept for a few days or should be deleted after usage
#===============================================================================
# Copyright (c) 23 October 2026 - Benjamin Bernert - DQ Solutions
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom it is furnished to do
# so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#===============================================================================
# CHANGELOG:
# 2025-01-09 - Initial creation
# 2026-10-23 - Uploaded to GitHub
#===============================================================================
#
# How to use: 
# - Change Users in Line 56 & 70 to your local user accounts that should not show the popup
# - Change Number of Days in line 43 to the corresponding value from script Remove old user accounts.sh
#
#===============================================================================

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
    if [[ $loggedInUser == "Admin" ]] || [[ $loggedInUser == "user1" ]] || [[ $loggedInUser == "user2" ]] || [[ $loggedInUser == "user3" ]]; then 
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
        	if [[ $loggedInUser == "Admin" ]] || [[ $loggedInUser == "user1" ]] || [[ $loggedInUser == "user2" ]] || [[ $loggedInUser == "user3" ]]; then
            	echo "Check 2: $loggedInUser is not added to deletion list"
            else
				grep -xqF -- "$loggedInUser" "$FILE" || echo "$loggedInUser" >> "$FILE"
   				#echo $loggedInUser >> /Users/Shared/usersToDelete.txt
        	fi   
		fi
    fi
	exit
