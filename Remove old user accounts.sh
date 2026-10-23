#!/bin/zsh
#===============================================================================
# Script Name   : Remove old iser accounts.sh
# Author        : Benjamin Bernert - Senior System Engineer - bbernert@dq-solutions.ch
# Created On    : 2025-01-09
# Version       : 1.1
# Description   : Removes all local accounts on machines that have not signed in for a specific amount of days or are listed on a file. Will spare the 'admin,' and other home directories.
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
# - Change Users in Line 64 & 93 to your local user accounts that should not be deleted
# - Change Number of Days in line 45 after -mtime to the value that accounts should be kept on the mac
#
#===============================================================================

#set -x

currentuser=$( echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ { print $3 }' )
IFS=$'\n' read -d '' -r -a userslist < /Users/Shared/usersToDelete.txt
# you can edit this to remove only accounts that haven't logged in for x days: add '-mtime +<# of days>' after maxdepth
users=$(find /Users -type d -maxdepth 1 -mtime +8 | cut -d"/" -f3)
localusers=$(dscl . list /Users UniqueID | awk '$2 >500 {print $1}')
foldersInUsers=$(ls /Users/)

echo "currently logged in user: "$currentuser
echo "Useraccounts on this computer with a UniqueID over 500: "$localusers
echo "Users have not signed in for more than 8 days: "$users
echo "User home folders: "$foldersInUsers

##########
# Script #
##########
#delete users from textfile input
if [[ -f /Users/Shared/usersToDelete.txt ]]; then
while read -r line
echo "current selected user is: $line"
do
	if [[ "$line" != "$currentuser" ]]; then
        #if user is one of those, delete them from file but don't delete the user
        if [[ "$line" == "Admin" || "$line" == "Shared" || "$line" == "user1" || "$line" == "_mbsetupuser" || "$line" == "root" || "$line" == "loginwindow" ]]; then
            sed -i '' '/'$line'/d' /Users/Shared/usersToDelete.txt
        else
        	echo "user "$line" will now be deleted"
            if echo "$localusers" | grep -q "^$line$"; then
                jamf deleteAccount -username "$line" -deleteHomeDirectory
            fi
        fi
        #remove user from textfile
        if [[ "$line" =~ ^[a-z]+.[a-z]+@uni-ch.ch$ ]]; then
            sedline=$(echo "$line" | sed -r 's/[.]+/\\./g')
        else
            sedline="$line"
        fi
        sed -i '' '/'$sedline'/d' /Users/Shared/usersToDelete.txt    
 	elif [[ -z "$line" ]]; then
    	echo "File is empty. Exiting."
        break
    else
    	echo "$line is currently logged in. Skipping deletion of this account."
    fi
done <<< "$userslist"
else
	echo "deletion file does not exist yet"
fi

#Delete Userhomes older than 8 days
while read -r line2
do
	if [[ -z "$line2" || "$line2" == " " || "$line2" == "Admin" || "$line2" == "Shared" || "$line2" == "user1" || "$line2" == "$currentuser" || "$line2" == "_mbsetupuser" || "$line2" == "root" || "$line2" == "loginwindow" ]]; then
    	echo "Non-deletable account skipped"
	elif [[ "$line2" =~ ^[a-z]+.[a-z]+@uni-ch.ch$ ]]; then
    	#delete user if existing
        echo "user "$line2" will now be deleted"
    	if echo "$localusers" | grep -q "^$line2$"; then
#    		/usr/bin/dscl . -delete /Users/"$line2"
			jamf deleteAccount -username $line2 -deleteHomeDirectory
        fi
        sleep 2
        if [[ -d /Users/"$line2" ]]; then
        	echo "user home "$line2" still exists and should now be deleted"
#			chmod -Rf 777 /Users/"$line2"
#			rm -Rf /Users/"$line2"
        fi
    fi
done <<< "$users"

# rm -f /Users/Shared/usersToDelete.txt

exit 0
