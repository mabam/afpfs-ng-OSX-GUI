-- define function to replace one or more characters in text strings
on replaceText(incomingString, SearchString, replacementString)
	set tid to AppleScript's text item delimiters
	set AppleScript's text item delimiters to the SearchString
	set the textitemlist to every text item of the incomingString
	set AppleScript's text item delimiters to the replacementString
	set the newitemname to the textitemlist as string
	set AppleScript's text item delimiters to tid
	return newitemname
end replaceText

-- after installation, create folder for mount aliases and add to sidebar
tell application "Finder"
	if not (exists "/etc/afpfs-ng-OSX/link/AFP2 Mounts" as POSIX file) then
		make new folder at "/etc/afpfs-ng-OSX/link/" as POSIX file with properties {name:"AFP2 Mounts"}
		activate
		reveal "/etc/afpfs-ng-OSX/link/AFP2 Mounts" as POSIX file
		tell application "System Events" to keystroke "t" using command down
		close window 1
	end if
end tell

-- clear mount variables file in case previous run errored after volume selection
do shell script "cat /dev/null > /etc/afpfs-ng-OSX/bin/AFP2_mount_vars"

-- after restart, clean up "mount" and "link/AFP2 Mounts" if volumes were unmounted by other means than unmount.command
try
	do shell script "if ! test -e dev/osxfuse0; then rm -rf /etc/afpfs-ng-OSX/link/\"AFP2 Mounts\"/*; rmdir /etc/afpfs-ng-OSX/mount/*; fi"
end try

-- ping broadcast IP (x.x.x.255) to update device list for arp
-- use arp to get IP addresses of all active devices
set IPlines to do shell script "ping -t 10 $(ifconfig -u | grep broadcast | rev | cut -d' ' -f1 | rev | head -1) > /dev/null 2>&1 & echo > /dev/null; arp -a | cut -d'(' -f2 | cut -d')' -f1 | tr '
' ',' | rev | cut -c 2- | rev"

-- properly format list with IP addresses of active devices
set tid to AppleScript's text item delimiters -- get present (original) state
set AppleScript's text item delimiters to ","
set IPList to text items of IPlines
set AppleScript's text item delimiters to tid -- reset to original state

set afpServerList to {}

-- call afpgetstatus with timeout of 2 sec (to prevent long wait for non-responsive IP) for each IP address to output server status of any active AFP2-only servers
-- filter output to print only IP address and server name
-- create list with available AFP2-only servers for dialog
repeat with theItem in IPList
	set afpServer to do shell script "sh -c 'AFPstatus=$(doalarm () { perl -e \"alarm shift; exec @ARGV\" \"$@\"; }; doalarm 2 /usr/local/bin/afpgetstatus afp://" & theItem & "); echo $AFPstatus | grep -q AFP3\\. || if echo $AFPstatus | tr -d [:space:] | grep -q AFPVersion2; then echo $AFPstatus; else echo $AFPstatus | grep -q AFP2\\. && echo $AFPstatus; fi || exit 0 &' | cut -d: -f1,2 | cut -d' ' -f2,6- | rev | cut -d' ' -f3- | rev"
	set afpServerLine to afpServer as string
	if afpServerLine is "" then
	else
		copy afpServer to end of afpServerList
	end if
end repeat

-- if AFP2 servers were found display them in a list, else display error message
try
	tell application (path to frontmost application as text) to set afpServerChoice to choose from list afpServerList with title "afpfs-ng-OSX � Server Selection" with prompt "Choose an AFP2.x server:" OK button name "Continue �"
on error errStr number errorNumber
	if errorNumber is equal to -50 then
		tell application (path to frontmost application as text) to display dialog "No active AFP2.x servers found." with title "afpfs-ng-OSX � Error" buttons {"OK"} default button "OK" with icon "/etc/afpfs-ng-OSX/icon/server.icns" as POSIX file
		error number -128 -- stop script execution
	end if
end try

-- split selected server in IP and name
try
	set afpServerIPName to text item 1 of afpServerChoice
on error errStr number errorNumber
	if errorNumber is equal to -1728 then -- error code if choose from list was cancelled by user
		error number -128 -- stop script execution
	end if
end try
set tid to AppleScript's text item delimiters -- get present (original) state
set AppleScript's text item delimiters to " "
set afpServerIP to text item 1 of afpServerIPName
set AppleScript's text item delimiters to tid -- reset to original state
set afpServerIPName to replaceText(afpServerIPName, "'", "\\'") -- escape apostrophe in server name
set afpServerName to do shell script "echo " & afpServerIPName & " | cut -d' ' -f2-"

-- query volume names of selected server
set afpVolumeLines to do shell script "/usr/local/bin/afpcmd afp://" & afpServerIP & " | tail -1 | cut -d: -f2 | cut -c 2-"

-- display error message if no shared volumes have been found on server
if afpVolumeLines is "rror" then
	tell application (path to frontmost application as text) to display dialog "No AFP2.x volumes found on �" & afpServerName & "�." with title "afpfs-ng-OSX � Error" buttons {"OK"} default button "OK" with icon "/etc/afpfs-ng-OSX/icon/shared_volume.icns" as POSIX file
	error number -128 -- stop script execution
end if

-- properly format list with available volumes for dialog
set tid to AppleScript's text item delimiters -- get present (original) state
set AppleScript's text item delimiters to ", "
set afpVolumeList to text items of afpVolumeLines
set AppleScript's text item delimiters to tid -- reset to original state

tell application (path to frontmost application as text) to set afpVolumeChoice to choose from list afpVolumeList with title "afpfs-ng-OSX � Volume Selection" with prompt "Choose a volume from �" & afpServerName & "�:" OK button name "Mount"
-- if afpVolumeChoice is false then
-- set afpUserPass to choose from list
-- else
try
	set afpVolumeName to text item 1 of afpVolumeChoice
on error errStr number errorNumber
	if errorNumber is equal to -1728 then -- error code if choose from list was cancelled by user
		error number -128 -- stop script execution
	end if
end try
-- end if

-- define display name of mounted volume
set afpMountNameRAW to afpVolumeName & "@" & afpServerName
set afpMountName to replaceText(afpMountNameRAW, "'", "\\'")

-- prevent multiple aliases if attempting to mount the same volume more than once (the actual mounting isn't done twice by osxfuse)
tell application "Finder"
	if exists "/etc/afpfs-ng-OSX/link/AFP2 Mounts/" & afpMountNameRAW as POSIX file then
		error number -128 -- stop script execution
	else
		-- create mount point, load osxfuse if not yet running, load afpfs daemon
		-- export variables for beeing processed by afpfs-ng-OSX.mount_cmd.app
		-- launch afpfs-ng-OSX.mount_cmd.app to create mounts and aliases
		do shell script "mkdir /etc/afpfs-ng-OSX/mount/\"" & afpMountNameRAW & "\" && if ! test -e dev/osxfuse0; then /Library/Filesystems/osxfuse.fs/Contents/Resources/load_osxfuse && /usr/local/bin/afpfsd; fi
echo afpServerIP=\\\"" & afpServerIP & "\\\" >> /etc/afpfs-ng-OSX/bin/AFP2_mount_vars; echo afpVolumeName=\\\"" & afpVolumeName & "\\\" >> /etc/afpfs-ng-OSX/bin/AFP2_mount_vars; echo afpMountName=\\\"" & afpMountName & "\\\" >> /etc/afpfs-ng-OSX/bin/AFP2_mount_vars; open /etc/afpfs-ng-OSX/bin/afpfs-ng-OSX.mount_cmd.app"
	end if
end tell