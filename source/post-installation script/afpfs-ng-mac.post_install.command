#!/bin/bash

# check if AppleScript menu active
if grep -q 'Script Menu.menu' ~/Library/Preferences/com.apple.systemuiserver.plist

# if AppleScript menu already active, point to it for controlling afpfs-ng-mac
then osascript -e 'tell application (path to frontmost application as text) to display dialog "Find “afpfs-ng-mac” in the AppleScript menu to the right of your menu bar." & return & return & "There you can mount and unmount volumes." & return & return & "After first run, any mounted volumes will be available through “AFP2 Mounts” in the side bar of each Finder window." with title "afpfs-ng-mac" buttons {"OK"} default button "OK" with icon "/usr/local/afpfs-ng-mac/icon/logged_on_folder.icns" as POSIX file'

# if AppleScript menu not active, add it to SystemUIServer preferences and save as temp file
else plutil -convert xml1 ~/Library/Preferences/com.apple.systemuiserver.plist -o - | awk '/<array>/{print;print "\t\t<string>/System/Library/CoreServices/Menu Extras/Script Menu.menu</string>";next}1' | plutil -convert binary1 - -o - > /usr/local/afpfs-ng-mac/ScriptMenu.tmp

# check temp file to verify conversion went fine
if grep -q 'Script Menu.menu' /usr/local/afpfs-ng-mac/ScriptMenu.tmp

# if conversion successful, backup SystemUIServer prefs, overwrite with temp file and restart SystemUIServer
then mv ~/Library/Preferences/com.apple.systemuiserver.plist ~/Library/Preferences/com.apple.systemuiserver.plist.old; cp /usr/local/afpfs-ng-mac/ScriptMenu.tmp ~/Library/Preferences/com.apple.systemuiserver.plist && $(sleep 1; killall SystemUIServer; open /System/Library/CoreServices/Menu\ Extras/Script\ Menu.menu); rm /usr/local/afpfs-ng-mac/ScriptMenu.tmp

# check if prefs are still intact after restarting SystemUIServer
if grep -q 'Script Menu.menu' ~/Library/Preferences/com.apple.systemuiserver.plist

# if prefs are intact, point user to AppleScript menu
then osascript -e 'tell application (path to frontmost application as text) to display dialog "The AppleScript menu to the right of your menu bar has been activated." & return & return & "There you can find “afpfs-ng-mac” to mount and unmount volumes." & return & return & "After first run, any mounted volumes will be available through “AFP2 Mounts” in the side bar of each Finder window." with title "afpfs-ng-mac" buttons {"OK"} default button "OK" with icon "/usr/local/afpfs-ng-mac/icon/logged_on_folder.icns" as POSIX file'

# if prefs are not intact, offer to manually activate AppleScript menu or to retry automatically
else rm ~/Library/Preferences/com.apple.systemuiserver.plist; mv ~/Library/Preferences/com.apple.systemuiserver.plist.old ~/Library/Preferences/com.apple.systemuiserver.plist; rm ~/Library/Preferences/com.apple.systemuiserver.plist.old; killall SystemUIServer; open /System/Library/CoreServices/SystemUIServer.app; osascript -e 'tell application "System Events"' -e 'if (name of processes) contains "Installer" then' -e 'tell application "Installer" to activate' -e 'end if' -e 'end tell' -e 'tell application (path to frontmost application as text) to display alert "Could not complete post-installation automatically" message "In order to mount and unmount volumes using afpfs-ng-mac, the AppleScript menu has to be activated. It will then appear to the right of your menu bar." & return & return & "To activate it manually:" & return & "• Click on “Open Script Editor.app”," & return & "• select “Script Editor” –> “Preferences …” from the menu," & return & "• tick “Show Script menu in menu bar”." & return & return & "Alternatively you may retry automatic completion." & return & return & "Do you want to open Script Editor now?" buttons {"Open Script Editor.app", "Retry automatically"} default button "Open Script Editor.app" cancel button "Retry automatically"' -e 'tell application "AppleScript Editor" to activate' || $(plutil -convert xml1 ~/Library/Preferences/com.apple.systemuiserver.plist -o - | awk '/<array>/{print;print "\t\t<string>/System/Library/CoreServices/Menu Extras/Script Menu.menu</string>";next}1' | plutil -convert binary1 - -o - > /usr/local/afpfs-ng-mac/ScriptMenu.tmp

# REPEAT ORIGINAL STEPS IF USER OPTED FOR AUTO RETRY - if fails again only offer manual activation
if grep -q 'Script Menu.menu' /usr/local/afpfs-ng-mac/ScriptMenu.tmp

then mv ~/Library/Preferences/com.apple.systemuiserver.plist ~/Library/Preferences/com.apple.systemuiserver.plist.old; cp /usr/local/afpfs-ng-mac/ScriptMenu.tmp ~/Library/Preferences/com.apple.systemuiserver.plist && $(sleep 1; killall SystemUIServer; open /System/Library/CoreServices/Menu\ Extras/Script\ Menu.menu); rm /usr/local/afpfs-ng-mac/ScriptMenu.tmp

if grep -q 'Script Menu.menu' ~/Library/Preferences/com.apple.systemuiserver.plist

then osascript -e 'tell application (path to frontmost application as text) to display dialog "The AppleScript menu to the right of your menu bar has been activated." & return & return & "There you can find “afpfs-ng-mac” to mount and unmount volumes." & return & return & "After first run, any mounted volumes will be available through “AFP2 Mounts” in the side bar of each Finder window." with title "afpfs-ng-mac" buttons {"OK"} default button "OK" with icon "/usr/local/afpfs-ng-mac/icon/logged_on_folder.icns" as POSIX file'

else rm ~/Library/Preferences/com.apple.systemuiserver.plist; mv ~/Library/Preferences/com.apple.systemuiserver.plist.old ~/Library/Preferences/com.apple.systemuiserver.plist; rm ~/Library/Preferences/com.apple.systemuiserver.plist.old; killall SystemUIServer; open /System/Library/CoreServices/SystemUIServer.app; osascript -e 'tell application "System Events"' -e 'if (name of processes) contains "Installer" then' -e 'tell application "Installer" to activate' -e 'end if' -e 'end tell' -e 'tell application (path to frontmost application as text) to display alert "Could not complete post-installation automatically" message "In order to mount and unmount volumes using afpfs-ng-mac, you must activate the AppleScript menu manually. It will then appear to the right of your menu bar." & return & return & "Follow these steps:" & return & "• Click on “Open Script Editor.app”," & return & "• select “Script Editor” –> “Preferences …” from the menu," & return & "• tick “Show Script menu in menu bar”." buttons {"Open Script Editor.app"} default button "Open Script Editor.app"' -e 'tell application "AppleScript Editor" to activate'
fi

else rm /usr/local/afpfs-ng-mac/ScriptMenu.tmp; osascript -e 'tell application "System Events"' -e 'if (name of processes) contains "Installer" then' -e 'tell application "Installer" to activate' -e 'end if' -e 'end tell' -e 'tell application (path to frontmost application as text) to display alert "Could not complete post-installation automatically" message "In order to mount and unmount volumes using afpfs-ng-mac, you must activate the AppleScript menu manually. It will then appear to the right of your menu bar." & return & return & "Follow these steps:" & return & "• Click on “Open Script Editor.app”," & return & "• select “Script Editor” –> “Preferences …” from the menu," & return & "• tick “Show Script menu in menu bar”." buttons {"Open Script Editor.app"} default button "Open Script Editor.app"' -e 'tell application "AppleScript Editor" to activate'
fi)
# END REPEAT ORIGINAL STEPS IF USER OPTED FOR AUTO RETRY

fi

# if temp file is not intact, offer to manually activate AppleScript menu or to retry automatically
else rm /usr/local/afpfs-ng-mac/ScriptMenu.tmp; osascript -e 'tell application "System Events"' -e 'if (name of processes) contains "Installer" then' -e 'tell application "Installer" to activate' -e 'end if' -e 'end tell' -e 'tell application (path to frontmost application as text) to display alert "Could not complete post-installation automatically" message "In order to mount and unmount volumes using afpfs-ng-mac, the AppleScript menu has to be activated. It will then appear to the right of your menu bar." & return & return & "To activate it manually:" & return & "• Click on “Open Script Editor.app”," & return & "• select “Script Editor” –> “Preferences …” from the menu," & return & "• tick “Show Script menu in menu bar”." & return & return & "Alternatively you may retry automatic completion." & return & return & "Do you want to open Script Editor now?" buttons {"Open Script Editor.app", "Retry automatically"} default button "Open Script Editor.app" cancel button "Retry automatically"' -e 'tell application "AppleScript Editor" to activate' || $(plutil -convert xml1 ~/Library/Preferences/com.apple.systemuiserver.plist -o - | awk '/<array>/{print;print "\t\t<string>/System/Library/CoreServices/Menu Extras/Script Menu.menu</string>";next}1' | plutil -convert binary1 - -o - > /usr/local/afpfs-ng-mac/ScriptMenu.tmp

# REPEAT ORIGINAL STEPS IF USER OPTED FOR AUTO RETRY - if fails again only offer manual activation
if grep -q 'Script Menu.menu' /usr/local/afpfs-ng-mac/ScriptMenu.tmp

then mv ~/Library/Preferences/com.apple.systemuiserver.plist ~/Library/Preferences/com.apple.systemuiserver.plist.old; cp /usr/local/afpfs-ng-mac/ScriptMenu.tmp ~/Library/Preferences/com.apple.systemuiserver.plist && $(sleep 1; killall SystemUIServer; open /System/Library/CoreServices/Menu\ Extras/Script\ Menu.menu); rm /usr/local/afpfs-ng-mac/ScriptMenu.tmp

if grep -q 'Script Menu.menu' ~/Library/Preferences/com.apple.systemuiserver.plist

then osascript -e 'tell application (path to frontmost application as text) to display dialog "The AppleScript menu to the right of your menu bar has been activated." & return & return & "There you can find “afpfs-ng-mac” to mount and unmount volumes." & return & return & "After first run, any mounted volumes will be available through “AFP2 Mounts” in the side bar of each Finder window." with title "afpfs-ng-mac" buttons {"OK"} default button "OK" with icon "/usr/local/afpfs-ng-mac/icon/logged_on_folder.icns" as POSIX file'

else rm ~/Library/Preferences/com.apple.systemuiserver.plist; mv ~/Library/Preferences/com.apple.systemuiserver.plist.old ~/Library/Preferences/com.apple.systemuiserver.plist; rm ~/Library/Preferences/com.apple.systemuiserver.plist.old; killall SystemUIServer; open /System/Library/CoreServices/SystemUIServer.app; osascript -e 'tell application "System Events"' -e 'if (name of processes) contains "Installer" then' -e 'tell application "Installer" to activate' -e 'end if' -e 'end tell' -e 'tell application (path to frontmost application as text) to display alert "Could not complete post-installation automatically" message "In order to mount and unmount volumes using afpfs-ng-mac, you must activate the AppleScript menu manually. It will then appear to the right of your menu bar." & return & return & "Follow these steps:" & return & "• Click on “Open Script Editor.app”," & return & "• select “Script Editor” –> “Preferences …” from the menu," & return & "• tick “Show Script menu in menu bar”." buttons {"Open Script Editor.app"} default button "Open Script Editor.app"' -e 'tell application "AppleScript Editor" to activate'
fi

else rm /usr/local/afpfs-ng-mac/ScriptMenu.tmp; osascript -e 'tell application "System Events"' -e 'if (name of processes) contains "Installer" then' -e 'tell application "Installer" to activate' -e 'end if' -e 'end tell' -e 'tell application (path to frontmost application as text) to display alert "Could not complete post-installation automatically" message "In order to mount and unmount volumes using afpfs-ng-mac, you must activate the AppleScript menu manually. It will then appear to the right of your menu bar." & return & return & "Follow these steps:" & return & "• Click on “Open Script Editor.app”," & return & "• select “Script Editor” –> “Preferences …” from the menu," & return & "• tick “Show Script menu in menu bar”." buttons {"Open Script Editor.app"} default button "Open Script Editor.app"' -e 'tell application "AppleScript Editor" to activate'
fi)
# END REPEAT ORIGINAL STEPS IF USER OPTED FOR AUTO RETRY

fi

fi
