#!/bin/bash

# only run commands if mount variables file is not empty (contains variables)
if [ -s /usr/local/afpfs-ng-OSX/bin/AFP2_mount_vars ]; then \

source /usr/local/afpfs-ng-OSX/bin/AFP2_mount_vars
mount_afp2 afp://"$afpServerIP"/"$afpVolumeName" /usr/local/afpfs-ng-OSX/mount/"$afpMountName"

osascript -e 'tell application "Finder"
make new alias to POSIX file "/usr/local/afpfs-ng-OSX/mount/'"$afpMountName"'" at POSIX file "/usr/local/afpfs-ng-OSX/link/AFP2 Mounts"
set name of result to "'"$afpMountName"'"
end tell'

# clear content of mount variables file
> /usr/local/afpfs-ng-OSX/bin/AFP2_mount_vars

sleep 2

# force quit volume selection app (required when first ran after system boot, probably due to bug in AppleScript)
kill $(ps -ax | grep "afpfs-ng-OSX.volume_select.app" | awk '!/grep/' | cut -c 1-5)

fi
