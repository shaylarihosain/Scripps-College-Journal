--===============================================
-- SCRIPPS COLLEGE JOURNAL Software for Mac
-- Version 1.1.2
--------------------------------------------------------------------------------------
-- Compiled on:		macOS 12.3 (21E230) (Intel-based)
-- Tested on:		macOS 12.3 (21E230) (Intel-based)
-- Platform:			Universal (Apple arm64 binary and Intel x86_64 binary)
--------------------------------------------------------------------------------------
-- Last updated: 								March 26 2022
-- First released staffwide: 						April 24 2021
-- First beta entered limited staff testing: 		February 28 2021
-- Software development began: 				July 11 2020
--------------------------------------------------------------------------------------
-- Copyright © 2020–2022 Shay Lari-Hosain. All rights reserved. Unauthorized copying or reproduction of any part of the contents of this file, via any medium, is strictly prohibited. Proprietary and confidential. Scripps College and The Claremont Colleges do not own any portion of this software. This software, design system, and the artwork and visual materials used with it are student-created. The author is not responsible for any modifications, or the consequences of modifications, that are made to this software in any form by others.
-- Last updated by:		Shay Lari-Hosain
-- Created by:			Shay Lari-Hosain
--===============================================

use scripting additions
use script "PrefsStorageLib" version "1.1.0"

(*
set progress description to "Starting up…"
set progress additional description to ""
set progress total steps to 8
set progress completed steps to 0
*)

--=========================
(* InstallAssistant 2.0.1 *)

-- Info: Complies with Apple security provisions for apps distributed via unsigned distribution methods
-- Created March 1 2021
-- Last updated March 26 2022
--=========================
set appleTranslocationCheck to (((path to me as text) as alias) as string) as text
if appleTranslocationCheck does not contain "Users:" and appleTranslocationCheck does not contain "Applications:" and appleTranslocationCheck does not contain "Library:" then
	set correctPathInstalled to false
	set appTransMsg to "To install SCJ, drag it to Applications."
	set appTransButtons to {"Quit", "Instructions"}
	try
		set appAlreadyInstalled to "Applications:Scripps College Journal.app" as alias
		set installStatus to true
	on error
		set installStatus to false
	end try
	if installStatus is true then
		set appInstalledVersion to short version of (info for appAlreadyInstalled)
		if my version is less than or equal to appInstalledVersion then
			set appTransMsg to "SCJ is already installed. Open SCJ from your Applications folder."
			set appTransButtons to {"Instructions", "View Folder & Instructions"}
		end if
	end if
	set atcButton to button returned of (display alert appTransMsg message "Please read the enclosed instructions before opening SCJ for the first time." buttons appTransButtons default button 2)
	if atcButton contains "Instructions" then
		try
			set readMePOSIX to POSIX path of "Install Scripps College Journal:Read Me First.pdf"
			do shell script "open " & quoted form of readMePOSIX
		on error
			open location "https://github.com/shaylarihosain/Scripps-College-Journal/blob/main/README.md#installation"
		end try
	end if
	if atcButton is "View Folder & Instructions" then do shell script "open /Applications"
	continue quit
else
	set correctPathInstalled to true
end if

(* set progress completed steps to 1 *)

prepare storage for (path to me) default values {runcount:0}
set runcount to value for key "runcount"
global runcount

if runcount is 0 then
	try
		tell application "System Events" to make new folder at "tmp" with properties {name:"SCJPermissionsCheck"}
	on error msg number n
		if n = -1743 then
			permissionsMsg("“System Events,”", "Automation", "System Events")
		end if
	end try
end if

on permissionsMsg(processAlert, processCategory, processName)
	tell me to activate
	set permissionsButton to button returned of (display alert "Please grant Scripps College Journal access to " & processAlert & " or the app won’t work." message "To do this, start by opening System Preferences." buttons {"Why?", "Open System Preferences"} default button 2)
	if permissionsButton is "Why?" then
		tell application "Preview" to open file ((path to me as text) & "Contents:Resources:SCJ Usage Info.pdf" as alias)
		permissionsMsg("“System Events,”", "Automation", "System Events")
	else
		if processCategory is "Automation" then
			open location "x-apple.systempreferences:com.apple.preference.security?Privacy_Automation"
			set eventPermissionsAlert to "Scroll down until you find Scripps College Journal in the list on the right."
			set eventPermissionsMsg to "Then tick the “" & processName & "” checkbox."
		else
			try
				open location "x-apple.systempreferences:com.apple.preference.security?Privacy"
				set eventPermissionsAlert to "On the left is a list of categories."
			on error
				do shell script "open /System/Library/PreferencePanes/Security.prefPane/"
				set eventPermissionsAlert to "Now, click the “Privacy” tab."
			end try
			set eventPermissionsMsg to "Scroll down until you see the “" & processCategory & "” section." & return & return & "Then find Scripps College Journal, and tick the “" & processName & "” checkbox."
		end if
		tell me to activate
		display alert eventPermissionsAlert message eventPermissionsMsg buttons {"Done"}
	end if
end permissionsMsg

if application "Preview" is running then
	set alreadyOpenPreview to true
else
	set alreadyOpenPreview to false
end if

-- Code if app is installed via DMG disk image (won’t break if distributed via ZIP)
if runcount is 0 then -- doesn’t need to be runcountThisMachine because regular runcount will always = 0 when installed from the DMG
	if correctPathInstalled is true then
		if alreadyOpenPreview is true then
			tell application "Preview" to close (every window whose name contains "Read Me First")
			tell application "Preview" to close (every window whose name contains "Release Notes")
		else
			tell application "Preview" to quit
		end if
		try
			tell application "Finder" to eject disk "Install Scripps College Journal"
		on error msg number n
			if n = -1743 then
				permissionsMsg("“Finder,”", "Automation", "Finder")
			end if
		end try
		try
			do shell script "rm -f $HOME/Downloads/InstallScrippsCollegeJournal.dmg"
		on error
			try
				do shell script "rm -f $HOME/Desktop/InstallScrippsCollegeJournal.dmg"
			end try
		end try
	end if
end if

-- Set the time
set loadTime to (((path to me as text) & "Contents:Resources:Scripts:SetTimeHandler.scpt") as alias) as string
set loadTime to (load script loadTime as alias)

set currentyear to getYear() of loadTime
set currentmonth to getMonthName() of loadTime
set currentmonthInt to getMonth() of loadTime
set currenttime to getTime() of loadTime

(* 
set progress description to "Checking for software updates…"
set progress completed steps to 2
*)

-- Check for app updates
-- if runcountThisMachine mod 2 is 0 then
set checkSuccess to true
set appVersionDownload to "https://raw.githubusercontent.com/shaylarihosain/Scripps-College-Journal/main/Attributes/App%20Version" -- CHANGE FINAL URL
set getReleaseNotes to "https://raw.githubusercontent.com/shaylarihosain/Scripps-College-Journal/main/Attributes/App%20Release%20Notes" -- CHANGE FINAL URL
try
	set appLatestVersion to do shell script "curl --max-time 4 --connect-timeout 4 " & appVersionDownload
on error
	set checkSuccess to false
	display notification "Couldn’t check for app updates" with title "Software Update ⚠️"
end try

try
	set appReleaseNotes to do shell script "curl --max-time 4 --connect-timeout 4 " & getReleaseNotes
on error
	set appReleaseNotes to ""
end try

if checkSuccess is true then
	if my version is less than appLatestVersion then
		-- display notification "A software update is available"
		if appReleaseNotes is "" or appReleaseNotes is " " then
			set updateMsg2 to ""
		else
			set updateMsg2 to return & return & "What’s new:" & return & appReleaseNotes
		end if
		tell me to activate
		set updateButton to button returned of (display alert "An update to the SCJ app is available. Would you like to install it now?" message "The latest version is " & appLatestVersion & ". You have " & my version & "." & updateMsg2 buttons {"Not Now", "Update…"} default button 2)
		if updateButton is "Update…" then
			set introNewFeatures to true
			DownloadSCJ(true)
		end if
		-- else
		-- display notification "Your software is up to date ✓"
	end if
	
else if checkSuccess is false then
	set appLatestVersion to "unknown"
end if
-- end if

(*
set progress description to "Evaluating system…"
set progress completed steps to 3
*)

-- Run compatibility verification
prepare storage for (path to me) default values {loggedIn:false}
set loggedIn to value for key "loggedIn"
global loggedIn
set compatibilityscriptpath to (((path to me as text) & "Contents:Resources:Scripts:ComprehensiveCompatibilityCheck.scpt") as alias) as string
set loadCCC to (load script file compatibilityscriptpath)
set CCCinfo to DetermineCompatibility() of loadCCC
if loggedIn is false then
	run script loadCCC
	set CCCpass to item 13 of CCCinfo
	if CCCpass is false then continue quit
end if

-- Run disk verification
set diskscriptpath to (((path to me as text) & "Contents:Resources:Scripts:FreeDiskSpace.scpt") as alias) as string
run script file diskscriptpath

(* set progress completed steps to 4 *)

set adobeCCver to item 1 of CCCinfo
set IDver to item 2 of CCCinfo
set AIver to item 3 of CCCinfo
set osname to item 11 of CCCinfo
set IDverFull to item 12 of CCCinfo
set projectedadobeCCver to item 14 of CCCinfo

set osver to item 4 of CCCinfo
set shortname to item 5 of CCCinfo
set fullname to item 6 of CCCinfo
set firstname to item 7 of CCCinfo
set computername to item 8 of CCCinfo
set macmodel to item 9 of CCCinfo
set macmodelid to item 10 of CCCinfo
set cpuArch to item 15 of CCCinfo
set processorArchReadable to item 16 of CCCinfo

global IDver

-- SCJ Issue

set scjissueyear to getIssueYear() of loadTime
set scjvolume to getVolume() of loadTime

-- Check if the app has been run before

prepare storage for (path to me) default values {neverRan:true}
set neverRan to value for key "neverRan"
global neverRan
prepare storage for (path to me) default values {neverRanThisMachine:true}
set neverRanThisMachine to value for key "neverRanThisMachine"
global neverRanThisMachine
-- used to define runcount here, but then moved up
prepare storage for (path to me) default values {runcountThisMachine:0}
set runcountThisMachine to value for key "runcountThisMachine"
global runcountThisMachine
prepare storage for (path to me) default values {runcountSinceLastDesignUpdate:0}
set runcountSinceLastDesignUpdate to value for key "runcountSinceLastDesignUpdate"
global runcountThisMachine
prepare storage for (path to me) default values {introNewFeatures:true}
set introNewFeatures to value for key "introNewFeatures"

-- Get Started
set getstartedscriptpath to (((path to me as text) & "Contents:Resources:Scripts:FirstTime.scpt") as alias) as string

(*
set progress description to "Connecting to the Internet…"
set progress completed steps to 5
*)

-- Announcements & News
set announcementsScript to (((path to me as text) & "Contents:Resources:Scripts:News.scpt") as alias) as string
set loadAnnouncement to (load script file announcementsScript)
try
	if neverRan is false then
		set userFacingAnnouncement to fetchNews(false) of loadAnnouncement
	else
		set userFacingAnnouncement to "none"
	end if
on error
	set userFacingAnnouncement to "none"
end try

--=========================
(* NLU Dialog 1.2 *)

-- Info: Inactive until 2027. Program runs once every eight runs. In 2027, remove this section of code if the app is continuing to be updated.
-- Created September 5 2020
-- Last updated September 25 2021
--=========================

if currentyear is greater than 2026 then
	
	prepare storage for (path to me) default values {NLUdialog:false}
	set NLUdialog to value for key "NLUdialog"
	prepare storage for (path to me) default values {NLUdismissedForever:false}
	set NLUdismissedForever to value for key "NLUdismissedForever"
	
	if runcount mod 8 is 0 then
		set r to yes
	else
		set r to no
	end if
	
	if NLUdialog is false then
		set NLUheader to "The developer of this app is no longer updating it."
		set NLUbuttons to {"OK"}
	else if NLUdialog is true then
		set NLUheader to "Occasional reminder: the developer of this app is no longer updating it."
		set NLUbuttons to {"Don’t Show Again", "OK"}
	end if
	
	if runcount mod 3 is 0 then
		set msgPortion to return & return & "However, we fully intend for you to continue using it. If you encounter any problems with the app, just use the design guides manually."
	else
		set msgPortion to ""
	end if
	
	if r is yes and NLUdismissedForever is false then
		set NLUreturned to button returned of (display alert NLUheader message "Any unforeseen changes that Apple or Adobe make to their software in the future could break functionality." & msgPortion buttons NLUbuttons as critical)
		set NLUdialog to true
		if NLUreturned is "Don’t Show Again" then
			set NLUdismissedForever to true
		end if
	end if
	
	assign value NLUdialog to key "NLUdialog"
	assign value NLUdismissedForever to key "NLUdismissedForever"
	
end if

--=========================
(* BaseCode 14.1.2R *)

-- Info: Main program that handles the primary tasks the SCJ application is designed for. Contains many smaller handlers, as well as programs like Download SCJ, WelcomeManager, Adobe Workspace Installer, and Transfer Artwork. Very early builds named Get Started.
-- Created July 12 2020
-- Last updated March 26 2021
--=========================

-- Directory tree is damaged alert

on damagedDialog()
	global neverRan
	set damagedAlert to "Design guides are missing or damaged. Please redownload them."
	set assetbutton to button returned of (display alert damagedAlert as critical buttons {"Quit", "Try Another Folder…", "Get Design Guides…"} default button "Get Design Guides…")
	if assetbutton is "Get Design Guides…" then
		DownloadAssets(true)
		tell me to activate
		scjRestart()
	else if assetbutton is "Try Another Folder…" then
		scjRestart()
	else if assetbutton is "Quit" then
		continue quit
	end if
end damagedDialog

on scjRestart()
	return on run
	(* display notification "You can click on this notification to re-open SCJ once it quits." *)
end scjRestart

--=========================
(* Download SCJ 6.0.2 *)

-- Info: 
-- Created July 25 2020
-- Last updated March 26 2022
--=========================

on DownloadSCJ(installUpdate)
	global currentyear
	global currentmonthInt
	global appLatestVersion
	
	set repo to "shaylarihosain/Scripps-College-Journal" as string
	if currentyear is greater than or equal to 2021 and currentmonthInt is greater than 10 then -- (November 2021)
		set checkRepo to ("https://raw.githubusercontent.com/shaylarihosain/Scripps-College-Journal/main/Attributes/Use%20Original%20Repository")
		try
			set useInitialRepo to do shell script "curl --max-time 4 --connect-timeout 4 " & checkRepo
		end try
		try
			if useInitialRepo is "false" then
				set repo to "scrippscollegejournal/mac-app" as string
			else if useInitialRepo is not "false" and useInitialRepo is not "true" then
				set repo to useInitialRepo
			end if
		end try
	end if
	
	set scjDownload to "https://github.com/" & repo & "/releases/latest/download/InstallScrippsCollegeJournal.dmg" as string
	
	set scjExtension to ".dmg"
	set scjName to "ReinstallScrippsCollegeJournal"
	set scjDestination to "Desktop"
	downloadResources(scjDownload, scjExtension, scjName, scjDestination)
	tell application "System Events" to open file ((path to desktop folder as text) & scjName & scjExtension)
	
	repeat
		tell application "System Events" to set diskNames to name of every disk
		if "Install Scripps College Journal" is in diskNames then
			set newAppFull to "Install Scripps College Journal:Scripps College Journal.app" as alias
			tell application "System Events" to delete file ((path to desktop folder as text) & scjName & scjExtension)
			exit repeat
		end if
		delay 0.02
	end repeat
	
	-- Installs new update
	try
		if installUpdate is true then
			relaunchSCJapp()
			display notification "The latest app, " & appLatestVersion & ", is installed ✓" with title "Software Update ↓"
			continue quit
		end if
	on error
		display notification "After dragging the new app to the Applications folder, click “Replace” when prompted." with title "Software Update ↓"
		continue quit
	end try
	
end DownloadSCJ

on downloadResources(FileDownload, FileExtension, FileName, FileDestination)
	
	try
		do shell script "curl -L -0 --max-time 140 --connect-timeout 6 '" & FileDownload & "' -o ~/" & FileDestination & "/" & FileName & FileExtension -- untested on Google Drive files
	on error
		set networkError to button returned of (display alert "Your Internet connection appears to be offline." message "Check your network connection and try again." buttons {"Quit", "Try Again…"} default button 2 as critical)
		if networkError is "Try Again…" then
			downloadResources(FileDownload, FileExtension, FileName, FileDestination)
		else if networkError is "Quit" then
			continue quit
		end if
	end try
end downloadResources

on relaunchSCJapp()
	set nameOfThisApp to name of me
	tell application "System Events" to set the frontmost of process nameOfThisApp to true
	do shell script "osascript -e '

	tell application \"" & nameOfThisApp & "\" to quit
	repeat until application \"" & nameOfThisApp & "\" is not running
	delay 0.05
	end repeat
	tell application \"Finder\" to delete POSIX file \"/Applications/Scripps College Journal.app\"
	set newAppFull to \"Install Scripps College Journal:Scripps College Journal.app\" as alias
	tell application \"Finder\" to move newAppFull to (path to applications folder) with replacing
	tell application \"Finder\" to eject disk \"Install Scripps College Journal\"
	tell application \"" & nameOfThisApp & "\" to activate
   
' &> /dev/null &"
end relaunchSCJapp

-- Download Assets folder to Documents folder

prepare storage for (path to me) default values {whenAssetsUpdated:""}
set whenAssetsUpdated to value for key "whenAssetsUpdated"
global whenAssetsUpdated

on determineDownloadDate()
	global currentyear
	global currentmonthInt
	
	set t to time of (get current date)
	set h to t div hours
	set m to t mod hours div minutes
	set s to t mod minutes
	
	set assetsUpdatedTime to h & "." & m & "." & s as string
	
	set assetsUpdatedDate to (currentyear & "-" & currentmonthInt & "-" & (word 3 of (date string of (current date)) as integer)) as text
	
	set whenAssetsUpdated to assetsUpdatedDate & " at " & assetsUpdatedTime as string
	assign value whenAssetsUpdated to key "whenAssetsUpdated"
end determineDownloadDate

on DownloadAssets(AssetsNew)
	global new_name
	global scjDesignVersion
	try
		try
			set checkDocumentsFolder to ((((path to documents folder as text) & "Assets") as alias) as string)
		on error
			set checkDocumentsFolder to ((((path to documents folder as text) & new_name) as alias) as string)
		end try
		set documentsGood to false
	on error
		set documentsGood to true
	end try
	if documentsGood is false then
		if runcountThisMachine is greater than 15 and AssetsNew is false then
			global currentmonthInt
			if currentmonthInt is greater than or equal to 4 and currentmonthInt is less than 8 then
				set existingAssetsMsg to "It seems like you’ve already worked on them a lot. If you have, skip unless your senior designer tells you otherwise." & return & return & "If you do get the new design guides, we’ll rename the folder containing your work. We won’t replace it."
			else
				set existingAssetsMsg to "If you get the new design guides, we’ll rename the folder containing your work. We won’t replace it."
			end if
			set existingAssetsHeader to "Do you want to continue?"
			set existingAssetsButtons to {"Skip", "Continue"}
		else
			if AssetsNew is false then
				set cautionMsg to "⚠️ "
				set cautionButton to "⚠️ Replace"
			else
				set cautionMsg to ""
				set cautionButton to "Replace"
			end if
			set existingAssetsHeader to "Would you like to keep the existing design guides?"
			set existingAssetsMsg to "“Keep” gets the new design guides while keeping the existing ones." & return & return & cautionMsg & "“Replace” overwrites the existing design guides with the new ones. This action cannot be undone. Do not select if you have done valuable work on the magazine that you don’t want to lose."
			set existingAssetsButtons to {cautionButton, "Skip", "Keep"}
		end if
		
		set replaceOldAssets to button returned of (display alert existingAssetsHeader message existingAssetsMsg buttons existingAssetsButtons)
		if replaceOldAssets is "Keep" or replaceOldAssets is "Continue" then
			try
				set namePrefix to (new_name & " (" & "v" & scjDesignVersion) as string
			on error
				try
					set namePrefix to ("Scripps College Journal (Previous version" as string)
				end try
			end try
			set renameOldAssets to (namePrefix & ", from " & whenAssetsUpdated & ")" as string)
			if whenAssetsUpdated is "" then
				determineDownloadDate()
				set renameOldAssets to (namePrefix & ", from " & whenAssetsUpdated & ")" as string)
			end if
			tell application "System Events" to set name of folder checkDocumentsFolder to (renameOldAssets as string)
			downloadAssetsThemselves()
			set runcountSinceLastDesignUpdate to 0
			scjRestart()
		else if replaceOldAssets contains "Replace" then
			try
				tell application "System Events"
					delete folder checkDocumentsFolder
				end tell
			end try
			downloadAssetsThemselves()
			set runcountSinceLastDesignUpdate to 0
			scjRestart()
		end if
	else
		downloadAssetsThemselves()
		set runcountSinceLastDesignUpdate to 0
	end if
end DownloadAssets

on downloadAssetsThemselves()
	determineDownloadDate()
	tell me to activate
	display alert "Downloading latest SCJ design guides…" message "Please wait. You’ll be up and running in no time." buttons {""} giving up after 2.5
	set assetsDownload to "https://github.com/scrippscollegejournal/design-resources/blob/main/Assets.zip?raw=true"
	set assetsExtension to ".zip"
	set assetsName to "SCJAssets"
	set assetsDestination to "Documents"
	downloadResources(assetsDownload, assetsExtension, assetsName, assetsDestination)
	display notification "Almost done…" with title "Design Guide 📘"
	tell application "Finder"
		open file ((path to documents folder as text) & assetsName & assetsExtension)
	end tell
	
	delay 3
	tell application "System Events"
		delete file ((path to documents folder as text) & assetsName & assetsExtension)
	end tell
end downloadAssetsThemselves

-- Define asset locations & asset integrity check

(* set progress description to "Reading SCJ design guides…"
set progress completed steps to 6
set progress additional description to "SCJ starts up faster with a fast Internet connection." *)

set assetsLocated to false
global new_name
set new_name to "Scripps College Journal — Volume " & scjvolume

try
	try
		set assetLocationCheck to ((((path to me as text) & ":Assets") as alias) as string)
	on error
		set assetLocationCheck to ((((path to me as text) & ":" & new_name) as alias) as string)
	end try
	set assetInitial to (path to me as text) & "::"
on error
	try
		set assetLocationCheck to ((((path to documents folder as text) & "Assets") as alias) as string)
	on error
		try
			set assetLocationCheck to ((((path to documents folder as text) & new_name) as alias) as string)
		on error
			if neverRanThisMachine is true then
				DownloadAssets(true)
				set assetsLocated to true
			end if
		end try
	end try
	set assetInitial to (path to documents folder as text)
end try

if neverRan is true then -- rename Assets folder to final name
	try
		tell application "System Events" to set name of folder (((assetInitial & "Assets") as alias) as string) to new_name
	end try
end if

set offerDesignUpdate to true
set restartAfterNewGuides to false
try
	set assets_path to ((assetInitial & new_name) as alias) as string
	set assetsLocated to true
on error
	try
		set assets_path to ((assetInitial & "Assets") as alias) as string -- In the instance that app has already been run but folder has been swapped with fresh Assets folder.
		tell application "System Events" to set name of folder (((assetInitial & "Assets") as alias) as string) to new_name
		set assets_path to ((assetInitial & new_name) as alias) as string
		set assetsLocated to true
	on error
		try
			-- Search for older assets
			set assetsLocated to false
			set searchScript to (path to me as text) & "Contents:Resources:Scripts:PollDesignGuides.scpt" as alias
			set assetsReturned to run script searchScript with parameters {scjvolume}
			if assetsReturned is "download" then
				DownloadAssets(true)
				set restartAfterNewGuides to true -- this variable is used in place because scjRestart handler errors here with "-1708: <<script>> doesn’t understand the "return" message
			else
				set assets_path to assetsReturned as string
				set assetsLocated to true
				set offerDesignUpdate to false
			end if
		on error
			set assetsLocated to false
			set offerDesignUpdate to false
			try
				set assets_path to (choose folder with prompt "The SCJ design guides folder has been renamed or moved. Please relocate it:") as alias as string
			on error number errorNumber
				if errorNumber is -128 then
					continue quit
				end if
			end try
		end try
		-- the below try block was moved from here
	end try
end try

if restartAfterNewGuides is true then scjRestart()

try -- checks if it’s a real SCJ Assets folder; last line of defense
	set rcheck to ((assets_path & "Fonts") as alias) as string
	set assetsLocated to true
on error
	try
		set rcheck to ((assets_path & ".Fonts") as alias) as string
		set assetsLocated to true
	on error
		set assetsLocated to false
		damagedDialog()
	end try
end try

if runcount is greater than 0 then
	try
		set font_path to ((assets_path & ".Fonts") as alias) as string
		set AssetsNew to false
	on error
		set font_path to ((assets_path & "Fonts") as alias) as string
		set AssetsNew to true
		-- set AppOldNewAssets to true
	end try
else
	try
		set font_path to ((assets_path & "Fonts") as alias) as string
		set AssetsNew to true
	on error
		set font_path to ((assets_path & ".Fonts") as alias) as string
		set AssetsNew to false
	end try
end if

try
	set artFolderPresent to ((assets_path & "Artwork") as alias)
on error
	set makeArtFolderSuccess to true
	try
		tell application "System Events" to make new folder at end of (assets_path as alias) with properties {name:"Artwork"}
	on error
		set makeArtFolderSuccess to false
	end try
	if makeArtFolderSuccess is true then
		display notification "SCJ Artwork folder was deleted, moved, or renamed, so we made a new one in its place." with title "Design Guide 📘"
	else
		display notification "This could cause unexpected behavior and visual art placement to fail. Create a new one in the SCJ design guide’s folder." subtitle "SCJ Artwork folder is missing" with title "Design Guide ⚠️"
	end if
end try

-- Check for design guide updates

(* set progress description to "Checking for newer design guides…"
set progress completed steps to 7 *)

try
	set versionLocation to POSIX path of (assets_path & ".SCJ Design Version.txt" as string)
	set scjDesignVersion to (paragraphs of (read POSIX file versionLocation) as text)
on error
	set scjDesignVersion to "unknown ⚠️"
end try

if scjDesignVersion is not "unknown ⚠️" then
	
	set assetsVersionDownload to "https://raw.githubusercontent.com/scrippscollegejournal/design-resources/main/Assets%20Version" -- URL
	set assetsInfoDownload to "https://raw.githubusercontent.com/scrippscollegejournal/design-resources/main/Assets%20Info" -- URL
	try
		set designCheckSuccess to true
		set scjLatestVersion to do shell script "curl --max-time 4 --connect-timeout 4 " & assetsVersionDownload
	on error
		set designCheckSuccess to false
	end try
	
	try
		set assetsInfo to do shell script "curl --max-time 4 --connect-timeout 4 " & assetsInfoDownload
	on error
		set assetsInfo to ""
	end try
	
	if designCheckSuccess is true and offerDesignUpdate is not false then
		if scjDesignVersion is less than scjLatestVersion then
			if assetsInfo is "" or assetsInfo is " " then
				set additionalMsg to ""
			else
				set additionalMsg to return & return & assetsInfo
			end if
			if offerDesignUpdate is false then
				set offeredOnceMsg to "Newer SCJ design guides than the ones you selected are available. Would you like to get them now?"
			else
				set offeredOnceMsg to "A revision to the SCJ design guides is available. Would you like to get it now?"
			end if
			tell me to activate
			set updateButton to button returned of (display alert offeredOnceMsg message "Design system version " & scjLatestVersion & " introduces new changes and rules. You have " & scjDesignVersion & "." & additionalMsg buttons {"Not Now", "Get…"} default button 2)
			if updateButton is "Get…" then
				if offerDesignUpdate is false then
					DownloadAssets(true)
					scjRestart()
				else
					DownloadAssets(AssetsNew)
				end if
			end if
		end if
		
	else if designCheckSuccess is false then
		set scjLatestVersion to "unknown"
	end if
end if

try
	tell application "Finder" to set assetDisplayLocation to (name of folder of folder assets_path) as string
on error
	set assetDisplayLocation to false
end try

try
	tell application "Finder" to set inddCount to (count (every file of folder assets_path whose name extension is "indd"))
	if inddCount is 2 then
		set displayMsgCount to "an"
		set pluralIDmsg to ""
		set pronounIDmsg to "it"
	else if inddCount is greater than 2 then
		set displayMsgCount to (inddCount - 1)
		set pluralIDmsg to "s"
		set pronounIDmsg to "they"
	end if
	if inddCount is greater than 1 then
		set inddExtraButton to button returned of (display alert "There’s " & displayMsgCount & " extra InDesign document" & pluralIDmsg & " in the design guides folder." message "Please move the unrelated document" & pluralIDmsg & " out of the folder. If improperly prepared, " & pronounIDmsg & " could cause issues." buttons {"Skip", "Open Folder"} default button 2 as critical)
		if inddExtraButton is "Open Folder" then
			tell application "Finder" to open assets_path
			display alert "When you’re finished removing the extra InDesign document" & pluralIDmsg & ", click “Continue.”" message "Be sure to remove the unrelated file" & pluralIDmsg & ", not the relevant one for SCJ that you’re working on." buttons {"Continue"} default button "Continue"
		end if
	end if
end try

-- Verification is complete and installer launch may begin

(* set progress completed steps to 8
set progress description to "Welcome to Scripps College Journal."
set progress additional description to "" *)

prepare storage for (path to me) default values {showPSalert:true}
set showPSalert to value for key "showPSalert"

if runcountThisMachine is greater than 0 and showPSalert is true then
	if runcountThisMachine mod 8 is 0 then
		
		try
			tell application "Finder" to get application file id "com.adobe.Photoshop"
			set PSexists to true
		on error
			set PSexists to false
		end try
		
		if PSexists is false then
			set PSbutton to button returned of (display alert "We noticed you don’t have Photoshop." message "You might want it, at some point, to retouch the condition of submitted artwork, particularly physical pieces." & return & return & "It comes with your Scripps subscription as long as campus is closed." buttons {"Don’t Show Again", "Get Photoshop…", "Later"})
			if PSbutton is "Get Photoshop…" then
				open location "https://creativecloud.adobe.com/apps/all/desktop/pdp/photoshop"
			else if PSbutton is "Don’t Show Again" then
				set showPSalert to false
				assign value showPSalert to key "showPSalert"
			end if
		end if
		
	end if
end if

(* if macmodel is "iMac" or firstname contains "Scripps" then signInOnLabComputer("Type your first name")
on signInOnLabComputer(prompt)
	global firstname
	global loggedIn
	if loggedIn is false then
			set SCJuser to "designer"
		else
			set SCJuser to "senior designer"
	end if
	set oldfirstname to firstname
	try
		set signInIcon to "System:Library:CoreServices:CoreTypes.bundle:Contents:Resources:GroupIcon.icns" as alias
	on error
		set signInIcon to note
	end try
	set signInDialog to (display dialog "We think this might be a Scripps lab computer." default answer prompt with title "Sign In" buttons {"Use “" & oldfirstname & "”", "OK"} default button "OK" with icon signInIcon)
	set firstname to text returned of signInDialog
	if button returned of signInDialog is "OK" and text returned of signInDialog contains "Type your" or text returned of signInDialog contains "first name" or text returned of signInDialog contains "Enter a" or text returned of signInDialog contains "valid" then
		signInOnLabComputer("Enter a valid first name")
		set firstname to oldfirstname
	else if button returned of signInDialog contains "Use" then
		set firstname to oldfirstname
	end if
end signInOnLabComputer *)

set showQuitNotif to true
set launchFinished to false

if application id "com.adobe.Illustrator" is running then
	set alreadyOpenAI to true
else
	set alreadyOpenAI to false
end if
if application id "com.adobe.InDesign" is running then
	set alreadyOpenID to true
else
	set alreadyOpenID to false
end if

if neverRanThisMachine is true then
	display notification subtitle "Click Start Designing to begin" with title "Welcome, " & firstname & "! 💫"
else
	fetchNews(true) of loadAnnouncement
end if

--=========================
(* WelcomeManager 2.16.1 *)

-- Info: Program (now integrated within BaseCode) that provides the main front-end user interface and manages SCJ user authentication
-- Created July 12 2020
-- Last updated March 7 2022
--=========================

set neverRan to false
assign value neverRan to key "neverRan"
set neverRanThisMachine to false
assign value neverRan to key "neverRanThisMachine"

on Welcome()
	
	global currentyear
	global currentmonth
	global currentmonthInt
	global firstname
	global fullname
	global computername
	global scjissueyear
	global scjvolume
	global runcount
	global adobeCCver
	global diskscriptpath
	global assets_path
	global alreadyOpenID
	global alreadyOpenAI
	global scjDesignVersion
	global scjLatestVersion
	global appLatestVersion
	global assetDisplayLocation
	global projectedadobeCCver
	global userFacingAnnouncement
	global showQuitNotif
	global inddCount
	set depNoticeText to "its compatibility rules to notify you of Adobe incompatibilities. Everyone on the design team must manually verify that they’re using the same Creative Cloud version."
	if scjissueyear is 2026 then
		set deprecatedNotice to return & return & "Starting next year, this app will no longer auto-update " & depNoticeText
	else if scjissueyear is greater than or equal to 2027 then
		set deprecatedNotice to return & return & "This app no longer auto-updates " & depNoticeText
	else if scjissueyear is less than 2026 then
		set deprecatedNotice to ""
	end if
	
	if loggedIn is false then
		set adminButton to "Log In As Admin…"
		set SCJuser to "staff"
	else if loggedIn is true then
		set adminButton to "Log Out Of Admin…"
		set SCJuser to "managing editor"
	end if
	
	if my version is greater than or equal to appLatestVersion then
		set aboutApp to " — Up to date ✓"
	else if appLatestVersion is "unknown" then
		set aboutApp to " — Couldn’t check for updates"
	else
		set aboutApp to " — Update available"
		try
			set aV to character 1 of my version as integer
			set aLV to character 1 of appLatestVersion as integer
			if (aLV - aV) is greater than or equal to 1 then
				set aboutApp to " — Update available ⚠️"
			end if
		end try
	end if
	try
		if scjDesignVersion is greater than or equal to scjLatestVersion then
			set aboutDesign to " — Up to date ✓"
		else if scjLatestVersion is "unknown" or scjDesignVersion contains "unknown" then
			set aboutDesign to " — Couldn’t check for updates"
		else
			set aboutDesign to " — Update available"
			try
				set dV to character 1 of scjDesignVersion as integer
				set LV to character 1 of scjLatestVersion as integer
				if (LV - dV) is greater than or equal to 1 then
					set aboutDesign to " — Update available ⚠️"
				end if
			end try
		end if
	on error msg number n
		if n = -2753 then
			tell me to activate
			permissionsMsg("your Documents folder", "Files and Folders", "Documents Folder")
			display notification "Click here to reopen Scripps College Journal" with title "Setup 🛠"
			continue quit
		end if
	end try
	
	if runcountThisMachine is less than 2 then
		set welcomeMsg1 to ". You’re ready to begin building Volume "
		set welcomeMsg0 to "We’re so thrilled to have you on board as a designer, "
	else if runcountThisMachine is greater than 1 then
		set welcomeMsg1 to ". You’re on your way to building Volume "
		if runcountThisMachine mod 2 is 0 then
			set welcomeMsg0 to "We’re so thrilled to have you on board as a designer, "
		else
			set welcomeMsg0 to "You got this, "
		end if
	end if
	
	if alreadyOpenID is true and alreadyOpenAI is false then
		set whenDoneMsg to return & return & "When you’re done working, quit SCJ to close the front cover template."
	else if alreadyOpenID is false and alreadyOpenAI is true then
		set whenDoneMsg to return & return & "When you’re done working, quit SCJ to close the magazine design guide."
	else if alreadyOpenID is false and alreadyOpenAI is false then
		set whenDoneMsg to return & return & "When you’re done working, quit SCJ to close everything."
	else if alreadyOpenID is true and alreadyOpenAI is true then
		set whenDoneMsg to ""
	end if
	if runcountThisMachine is less than 1 then
		set welcomeMsg2 to return & return & "With one click, we’ll configure your Adobe apps with everything you need, and show you around the design guides." & whenDoneMsg
	else if runcountThisMachine is less than 4 then
		set welcomeMsg2 to whenDoneMsg
	end if
	if runcountThisMachine is less than 1 then
		set startButton to "Start Designing"
	else if runcountThisMachine is greater than 0 then
		set startButton to "Continue Designing"
	end if
	
	if runcountThisMachine is less than 6 and runcountThisMachine is greater than 3 then
		set welcomeMsg2 to return & return & "You can pin the SCJ icon in the Dock for easy access next time."
	else if runcountThisMachine is less than 11 and runcountThisMachine is greater than 5 then
		set welcomeMsg2 to return & return & "The best way to preview your work and assess your pages’ layout is to print them at 100% scale, if you have easy access to a printer."
	else if runcountThisMachine is less than 26 and runcountThisMachine is greater than 10 then
		set welcomeMsg2 to return & return & "Back up your work periodically, either with Time Machine or by dragging key files into Google Drive."
	else if runcountThisMachine is greater than 25 then
		set welcomeMsg2 to return & return & "When you’re ready to export the magazine, click “Close” and drag your InDesign file onto the SCJ Dock icon."
	end if
	
	if runcountThisMachine is greater than 100 then
		set welcomeMsg0 to "Wow, your dedication to SCJ is admirable! Maybe it’s time to take a break—please make sure you’re taking care of yourself first and foremost, "
		set welcomeMsg1 to ". We love what you’re doing with Volume "
	end if
	
	if runcountThisMachine is greater than 2 then
		set artFolder to ((assets_path & "Artwork") as alias)
		tell application "Finder"
			set result to (count files of entire contents of artFolder)
		end tell
		if the result = 0 then
			set transferMsg to "The Artwork folder is still empty. "
			set showExtraTextQuitNotif to true
		else
			set transferMsg to ""
			set showExtraTextQuitNotif to false
		end if
		
		try
			if inddCount is greater than 1 then
				set inddCountMsg to return & return & "You have an extra InDesign document in the design guides folder. Move it to eliminate unexpected behavior."
			else
				set inddCountMsg to ""
			end if
		on error
			set inddCountMsg to ""
		end try
	else
		set transferMsg to ""
		set showExtraTextQuitNotif to false
		set inddCountMsg to ""
	end if
	
	set inddDocOpen to isMagazineOpen("InDesign")
	if inddDocOpen is true then
		set quitNotif to "Press ⌘Q to quit. Or drag an art piece onto the Dock icon to place it on the current InDesign page."
	else
		if showExtraTextQuitNotif is true or runcountThisMachine is less than 2 then
			set quitNotif to "Press ⌘Q to quit. Or drag art pieces onto the Dock icon to import them into the SCJ Artwork folder."
		else
			set quitNotif to "Press ⌘Q to quit"
		end if
	end if
	
	set loadFDS to (load script diskscriptpath as alias)
	set freeSpace to DetermineDisk(false, false) of loadFDS as integer
	set diskUnit to " GB"
	if freeSpace is greater than 999 then
		set diskUnit to " TB"
		set freeSpace to (freeSpace * 1.0E-3)
		set freeSpace to roundThis(freeSpace, 2)
	end if
	
	if loggedIn is true then
		set diskAbout to freeSpace & diskUnit & " free on disk" & return & return
		if assetDisplayLocation is not false then
			set assetDisplay to return & return & "Design guides located in " & assetDisplayLocation & " folder ✓"
		else
			set assetDisplay to ""
		end if
	else
		set diskAbout to ""
		set assetDisplay to ""
	end if
	
	set adobeStatusValid to ""
	try
		if projectedadobeCCver is less than or equal to adobeCCver then
			set adobeStatusValid to " ✓"
		end if
	end try
	set adobeCCstatusDisplay to ("Adobe CC " & adobeCCver & " " & "installed" & adobeStatusValid as string)
	
	set activateWelcomeNews to false
	if userFacingAnnouncement is "none" or activateWelcomeNews is false then
		set welcomeNews to ""
	else if activateWelcomeNews is true then
		set welcomeNews to return & return & "News — " & userFacingAnnouncement
	end if
	
	-- 🎨📚🖌🌻
	tell me to activate
	set launchButton to button returned of (display alert "Welcome to the Scripps College Journal Design Guide" message welcomeMsg0 & firstname & welcomeMsg1 & scjvolume & ".

" & transferMsg & "Move art to the Artwork folder before placing on your pages.

To do that now, just click “Close” and drag the images onto the SCJ Dock icon. Then click the icon to return here." & welcomeMsg2 & inddCountMsg buttons {"About…", "Close", startButton} default button 3)
	
	if (text of launchButton) is "About…" then
		set backButton to button returned of (display dialog "SCRIPPS COLLEGE JOURNAL" & return & "Interactive Design System" & return & return & "Upcoming issue is Spring " & scjissueyear & ", Volume " & scjvolume & return & return & "Logged in as " & SCJuser & " on " & computername & assetDisplay & return & return & adobeCCstatusDisplay & deprecatedNotice & return & return & diskAbout & "App version " & my version & aboutApp & return & "Design version " & scjDesignVersion & aboutDesign & welcomeNews with title "About" buttons {adminButton, "Acknowledgments…", "Back…"} default button "Back…" with icon note) -- can change this to a different icon if we don’t want the Construction icon
		if text of backButton is "Back…" then
			Welcome()
		else if text of backButton is "Acknowledgments…" then
			Acknowledgments(loggedIn)
		else if text of backButton is "Log In As Admin…" then
			set authenticateAdmin to (((path to me as text) & "Contents:Resources:Scripts:PasswordProtect3.scpt") as alias) as string
			set loggedIn to (run script (file authenticateAdmin) with parameters (loggedIn))
			-- DEBUGGER display dialog "WelcomeDialog received login status: " & loggedIn
			if loggedIn is true then display notification "Welcome back, SCJ Senior Designer" with title "Logged In 👩🏽‍🎨"
			-- AuthenticationHandler()
			Welcome()
		else if text of backButton is "Log Out Of Admin…" then
			set loggedIn to false
			display notification "Welcome back, SCJ Designer" with title "Logged Out 👩🏽‍🎨"
			Welcome()
		end if
	else if launchButton is "Start Designing" or launchButton is "Continue Designing" then
		if runcountThisMachine is 0 then
			if application id "com.adobe.InDesign" is running then
				set quitIDonInstall to button returned of (display alert "We have to restart InDesign before installing new design resources." message "It’s only necessary the first time. Save any open work." buttons {"Back…", "Continue"} default button 2)
				if quitIDonInstall is "Continue" then
					tell application id "com.adobe.InDesign" to quit
					repeat until application id "com.adobe.InDesign" is not running
						delay 0.05
					end repeat
					Designing()
				else if quitIDonInstall is "Back…" then
					Welcome()
				end if
			else
				Designing()
			end if
		else if runcountThisMachine is greater than 0 then
			--if launchFinished is false then
			Designing()
		end if
		-- else if launchFinished is true then
		-- ?? make cleanUp a handler?
	else if launchButton is "Close" then
		if showQuitNotif is true then display notification quitNotif with title "Tips 💭"
		set showQuitNotif to false
	end if
	
end Welcome

set licenseopen to false
set privacyopen to false
global licenseopen
global privacyopen
set licensebt to "License Agreement"
set privacybt to "Usage"

on Acknowledgments(loggedIn)
	global licensebt
	global privacybt
	if loggedIn is false then
		set aButtonList to {licensebt, privacybt, "Back…"}
	else
		set aButtonList to {"Uninstall", "Reset Settings", "Back…"}
	end if
	set abtn to button returned of (display dialog "SCJ Visual Design System created by" & return & "Shay Lari-Hosain" & return & return & "Special thanks to" & return & "Ariel So, Kerry Taylor, and Jamie Jiang" & return & return & "SCJ Leaf illustrated by" & return & "Karen Wang" & return & return & "SCJ Flag designed by" & return & "Shay Lari-Hosain" with title "Acknowledgments" buttons aButtonList default button "Back…")
	if abtn is "Back…" then
		tell application "Preview" to close (every window whose name contains "SCJ License Agreement")
		tell application "Preview" to close (every window whose name contains "SCJ Usage Info")
		set licenseopen to false
		set privacyopen to false
		set licensebt to "License Agreement"
		set privacybt to "Usage"
		Welcome()
	else if abtn is "License Agreement" or abtn is "Close License Agreement" then
		if licenseopen is false then
			set licenseagreement to (path to me as text) & "Contents:Resources:SCJ License Agreement.pdf" as alias -- relocate to Resources path inside app
			set licenseopen to true
			set licensebt to "Close License Agreement"
			tell application "Preview" to open file licenseagreement
			-- tell application "Preview" to activate
		else if licenseopen is true then
			tell application "Preview" to close (every window whose name contains "SCJ License Agreement")
			set licenseopen to false
			set licensebt to "License Agreement"
		end if
		Acknowledgments(loggedIn)
	else if abtn is "Usage" or abtn is "Close Usage" then
		if privacyopen is false then
			set privacyinfo to (path to me as text) & "Contents:Resources:SCJ Usage Info.pdf" as alias -- relocate to Resources path inside app
			set privacyopen to true
			set privacybt to "Close Usage"
			tell application "Preview" to open file privacyinfo
			-- tell application "Preview" to activate
		else if privacyopen is true then
			tell application "Preview" to close (every window whose name contains "SCJ Usage Info")
			set privacyopen to false
			set privacybt to "Usage"
		end if
		Acknowledgments(loggedIn)
	else if abtn is "Reset Settings" then
		resetAllSettings(true, "welcome")
	else if abtn is "Uninstall" then
		uninstallSCJ("welcome")
	end if
end Acknowledgments

on resetAllSettings(promptBefore, location)
	if promptBefore is true then
		set lastCheck to button returned of (display alert "Are you sure you want to reset SCJ app settings?" message "The app will behave as if it was just installed and never used on this Mac." buttons {"Cancel", "Reset"} default button "Cancel" as critical)
	else
		set lastCheck to "Reset"
	end if
	if lastCheck is "Reset" then
		set runcount to 0
		assign value runcount to key "runcount"
		set runcountThisMachine to 0
		assign value runcountThisMachine to key "runcountThisMachine"
		set runcountSinceLastDesignUpdate to 0
		assign value runcountSinceLastDesignUpdate to key "runcountSinceLastDesignUpdate"
		
		set neverRan to true
		assign value neverRan to key "neverRan"
		set neverRanThisMachine to true
		assign value neverRan to key "neverRanThisMachine"
		
		set showPSalert to false
		assign value showPSalert to key "showPSalert"
		set introNewFeatures to true
		assign value introNewFeatures to key "introNewFeatures"
		
		try
			global currentyear
			if currentyear is greater than 2026 then
				set NLUdialog to false
				assign value NLUdialog to key "NLUdialog"
				set NLUdismissedForever to false
				assign value NLUdismissedForever to key "NLUdismissedForever"
			end if
		end try
		
		if promptBefore is true then
			display notification "App settings reset to defaults" with title "Setup 🛠"
			scjRestart()
		end if
	else
		if promptBefore is true and location is "welcome" then Acknowledgments(loggedIn)
	end if
end resetAllSettings

Welcome()

-- Install SCJ typefaces; doesn’t install any that are already installed

global launchFinished
global designWork

on Designing()
	
	-- set launchFinished to false -- this might be why on first run it redoes everything after circling back? never mind
	
	global assets_path
	global font_path
	global AssetsNew
	-- global AppOldNewAssets
	global scjissueyear
	-- global IDver
	global IDverFull
	global firstname
	global osver
	
	if runcountThisMachine is greater than 0 then
		set designWork to button returned of (display alert "What are you designing today?" buttons {"Both", "Cover Illustration 🎨", "Page Layout 📐"})
	else
		set designWork to "Both"
	end if
	
	set userLibraryFontPath to (((path to library folder from user domain as text) & "Fonts") as alias)
	tell application "System Events"
		make new folder at end of (userLibraryFontPath) with properties {name:"SCJ"}
	end tell
	set computer_fonts to (((path to library folder from user domain as text) & "Fonts:SCJ") as alias) as string
	
	set font_path_POSIX to quoted form of the POSIX path of font_path
	set computer_fonts_POSIX to quoted form of the POSIX path of computer_fonts
	do shell script "rsync -a " & font_path_POSIX & " " & computer_fonts_POSIX
	
	tell application "Finder" to activate
	if runcountThisMachine is 0 then
		display notification subtitle "SCJ fonts installed" with title "Fonts 🔤"
	else if runcountThisMachine is greater than 0 and runcountThisMachine is less than 6 then
		display notification "If any were missing before, we just installed them." with title "Fonts 🔤" subtitle "SCJ fonts are already installed"
	end if
	
	-- Import Adobe PDF presets
	
	if runcountThisMachine is 0 then
		try
			rsyncPDFpresets()
			delay 4
			display notification subtitle "SCJ PDF export presets installed" with title "PDF Presets 🔧"
		end try
	else if runcountThisMachine is greater than 0 then
		try
			set PDFpresetscheck to (((path to home folder) as text) & "Library:Application Support:Adobe:Adobe PDF:Settings:Scripps College Journal — Magazine for Print.joboptions" as alias)
		on error
			try
				rsyncPDFpresets()
				delay 3
				display notification "Somehow the SCJ PDF export presets still weren’t installed. We just installed them." with title "PDF Presets 🔧"
			end try
		end try
	end if
	
	-- Import Adobe workspaces
	
	--=========================
	(* Adobe Workspace Installer 1.4.1 *)
	
	-- Info: Pretty rock-solid in my opinion as of February 1. Don’t really have an opportunity to test all the possibilities, but I think the error blocks cover any issues. Could use -1700 specifically, but probably no need, as seen in the Adobe Workspace Installer DEBUGGER programs. Removed Adobe Illustrator workspace on February 1 2021
	-- Created August 15 2020
	-- Last updated February 26 2021
	--=========================
	
	try
		if runcountThisMachine is 0 then
			rsyncWorkspaces()
		else if runcountThisMachine is greater than 0 then
			try
				try
					set workspacecheck to (((path to home folder as text) & "Library:Preferences:Adobe InDesign:Version " & IDver & ".0:en_US:Workspaces:Scripps College Journal.xml")) as alias
				on error
					set workspacecheck to (((path to home folder as text) & "Library:Preferences:Adobe InDesign:Version " & IDverFull & ":en_US:Workspaces:Scripps College Journal.xml")) as alias
				end try
			on error
				rsyncWorkspaces()
				delay 3
				display notification "Somehow the InDesign workspace still wasn’t installed. We just installed it." with title "Workspace Layout 🖱"
			end try
		end if
		set IDworkspaceInstalled to true
	on error
		delay 3
		display notification "You’ll have to import it yourself." with title "Workspace Layout ⚠️" subtitle "Couldn’t install InDesign workspace"
		set IDworkspaceInstalled to false
		try
			set SCJworkspace to ((assets_path & ".Workspace") as alias) as string
		on error
			set SCJworkspace to ((assets_path & "Workspace") as alias) as string
		end try
		tell application "System Events" to set name of folder SCJworkspace to "Workspace"
	end try
	
	-- Launch SCJ style guides & templates
	
	if runcountThisMachine is 0 then
		delay 3
	end if
	
	tell application "Finder"
		set myFolder to assets_path as alias
		set myIDFiles to (every item of myFolder whose name extension is "indd") as alias list
		set myAIFiles to (every item of myFolder whose name extension is "ai") as alias list
	end tell
	if osver is less than "12.3" then
		tell application "Finder"
			if designWork is "Page Layout 📐" then
				open myIDFiles
			else if designWork is "Cover Illustration 🎨" then
				open myAIFiles
			else
				open myIDFiles
				open myAIFiles
			end if
		end tell
	else
		if designWork is "Page Layout 📐" then
			tell application id "com.adobe.InDesign" to open myIDFiles
		else if designWork is "Cover Illustration 🎨" then
			tell application id "com.adobe.Illustrator" to activate
			tell application id "com.adobe.Illustrator" to open myAIFiles
		else -- earlier, pre-12.3 approach using Finder is nicer, because it opens all the documents at the same time
			tell application id "com.adobe.InDesign" to open myIDFiles
			tell application id "com.adobe.Illustrator" to open myAIFiles
		end if
	end if
	
	-- Show each document and explain their purposes 
	
	if runcountThisMachine is 0 then
		
		(* delay 4
		
		display notification "Front cover template has been opened in Illustrator." -- get rid of these notifications if it’s going to flip to each document and issue an explainer notifications
		
		delay 2
		
		display notification "Magazine design template has been opened in InDesign."
		
		delay 2 *)
		
		tell application id "com.adobe.InDesign" to activate
		if scjissueyear is less than 2022 then
			set magDesc to ". 8 × 10 inches, 6 pt grid, CMYK."
		else
			set magDesc to "."
		end if
		display notification "This is the SCJ magazine template" & magDesc subtitle "InDesign is active 📐" with title "Design Guide 📘"
		delay 4
		tell application id "com.adobe.Illustrator" to activate
		display notification "This is the front cover template. Once it’s designed, you’ll update the link in InDesign." subtitle "Illustrator is active 🎨" with title "Design Guide 📘"
		delay 4
		
	end if
	
	-- Switch to SCJ Adobe workspaces
	
	if designWork is not "Cover Illustration 🎨" then
		tell application id "com.adobe.InDesign" to activate
		if runcountThisMachine is greater than 0 then delay 1.5
		try
			tell application id "com.adobe.InDesign"
				apply workspace name "Scripps College Journal"
				set IDworkspaceApplied to true
			end tell
		on error
			set IDworkspaceApplied to false
			if IDworkspaceInstalled is true then
				display notification "Click the dropdown menu in the top right corner and select the ‘Scripps College Journal’ workspace." with title "Workspace Layout 🖱"
			end if
		end try
		
		if runcountThisMachine is less than 3 then
			if IDworkspaceInstalled is true and IDworkspaceApplied is true then
				display notification subtitle "InDesign SCJ workspace applied" with title "Workspace Layout 🖱"
			end if
		end if
	end if
	
	set launchFinished to true
	return assets_path
	
end Designing

on rsyncWorkspaces() -- install Adobe workspaces
	
	-- global IDver
	global IDverFull
	global assets_path
	
	try
		set SCJworkspace to ((assets_path & ".Workspace") as alias) as string
	on error
		set SCJworkspace to ((assets_path & "Workspace") as alias) as string
	end try
	try
		set IDworkspace to (((path to home folder as text) & "Library:Preferences:Adobe InDesign:Version " & IDver & ".0:en_US:Workspaces")) as alias
	on error
		set IDworkspace to (((path to home folder as text) & "Library:Preferences:Adobe InDesign:Version " & IDverFull & ":en_US:Workspaces")) as alias
	end try
	
	set SCJworkspace_POSIX to quoted form of the POSIX path of SCJworkspace
	set IDworkspace_POSIX to quoted form of the POSIX path of IDworkspace
	do shell script "rsync -a " & SCJworkspace_POSIX & " " & IDworkspace_POSIX
	
end rsyncWorkspaces

on rsyncPDFpresets() -- install PDF presets
	
	global assets_path
	
	set scj_PDFpresets to ((assets_path & ".PDF Preset") as alias) as string
	set computer_PDFpresets to (((path to home folder as text) & "Library:Application Support:Adobe:Adobe PDF:Settings")) as alias
	
	set scj_PDFpresets_POSIX to quoted form of the POSIX path of scj_PDFpresets
	set computer_PDFpresets_POSIX to quoted form of the POSIX path of computer_PDFpresets
	do shell script "rsync -a " & scj_PDFpresets_POSIX & " " & computer_PDFpresets_POSIX
	
end rsyncPDFpresets

on roundThis(n, numDecimals)
	set x to 10 ^ numDecimals
	(((n * x) + 0.5) div 1) / x
end roundThis

on isMagazineOpen(program)
	set programID to "com.adobe." & program as string
	if application id programID is running then
		try
			tell application id programID
				set docName to name of front document as string
			end tell
			if docName contains "Magazine Design Guide" or docName contains "Pages" or docName contains "Workshop" or docName contains "Layout" or docName contains "Cover" then
				set docOpen to true
			else
				set docOpen to false
			end if
		on error
			set docOpen to false
		end try
	else
		set docOpen to false
	end if
	
	return docOpen
end isMagazineOpen

-- Clean up

if launchFinished is true then -- this new if statement accounts for always-on behavior
	if runcountThisMachine is 0 then -- and AssetsNew is true then
		try
			set welcomeSound to POSIX path of file ((path to me as text) & "Contents:Resources:DesignerWelcome.m4a") as string
			do shell script "afplay '" & welcomeSound & "'"
		end try
		try
			tell application id "com.adobe.InDesign"
				display alert "Nice, " & firstname & "! You’ve got all our fonts, PDF presets, and other materials installed. You’re ready to go." message "Now you get to start creating. Scripps College Journal is well-integrated with InDesign — letting you focus on the important stuff. Here’s a few things you can do:" & return & return & "✒️ To place a writing piece on the current page, drag and drop a Word doc onto the SCJ icon in the Dock. We’ll place and format it automatically." & return & return & "🎨 To place visual art on the current spread, drag and drop an image on the SCJ icon." & return & return & "📚 To export the magazine with a click, drag and drop the InDesign file from the Finder onto the SCJ icon." & return & return & "It’s pretty sweet. We can’t wait to see what you do." buttons {"Woo!"}
			end tell
		end try
	else
		try
			if introNewFeatures is true and (my version is greater than or equal to appLatestVersion) then
				set newFeatures to do shell script "curl --max-time 0.5 --connect-timeout 0.5 https://raw.githubusercontent.com/scrippscollegejournal/preferences/main/App%20New%20Features"
				if designWork contains "Page Layout" or designWork is "Both" then
					set displayApp to "com.adobe.InDesign"
				else
					set displayApp to "com.adobe.Illustrator"
				end if
				if (newFeatures is not "404: Not Found" or newFeatures is not "" or newFeatures is not " " or newFeatures is not return) and newFeatures does not contain "http" then
					tell application id displayApp to display dialog newFeatures buttons {"Got It"} default button 1 with title "New Features in Scripps College Journal " & my version as string
					set introNewFeatures to false
					assign value introNewFeatures to key "introNewFeatures"
				end if
			else
				delay 1
			end if
		end try
	end if
	if runcount is 0 then tell application "System Events" to set name of folder font_path to ".Fonts"
	if runcount is greater than 0 and (AssetsNew is true or runcountSinceLastDesignUpdate is 0) then tell application "System Events" to set name of folder font_path to ".Fonts"
	
	set runcount to runcount + 1
	assign value runcount to key "runcount"
	set runcountThisMachine to runcountThisMachine + 1
	assign value runcountThisMachine to key "runcountThisMachine"
	set runcountSinceLastDesignUpdate to runcountSinceLastDesignUpdate + 1
	assign value runcountSinceLastDesignUpdate to key "runcountSinceLastDesignUpdate"
end if


on reopen
	if launchFinished is false then
		global assetsLocated
		if assetsLocated is true then
			Welcome()
			-- else
			-- scjRestart()
		end if
	else if launchFinished is true then
		set inddDocOpen to isMagazineOpen("InDesign")
		set aiDocOpen to isMagazineOpen("Illustrator")
		if designWork is "Both" and application id "com.adobe.InDesign" is not running and application id "com.adobe.Illustrator" is not running or designWork contains "Page Layout" and application id "com.adobe.InDesign" is not running or designWork contains "Cover Illustration" and application id "com.adobe.Illustrator" is not running then
			scjRestart()
		else if designWork is "Both" and (inddDocOpen is false or aiDocOpen is false) or designWork contains "Page Layout" and inddDocOpen is false or designWork contains "Cover Illustration" and aiDocOpen is false then
			Welcome()
		else
			global assets_path
			global adobeCCver
			global inddCount
			display notification "Press ⌘Q to quit when you’re done. Click the Dock icon for random tips if you’re feeling spontaneous." with title "Tips 💭"
			set IDtipscriptpath to (((path to me as text) & "Contents:Resources:Scripts:Tips.scpt") as alias) as string
			run script file IDtipscriptpath with parameters {assets_path, adobeCCver}
		end if
	end if
end reopen

(*
On Open Handler
- images (or any files really) move the dropped files to artwork folder
- .indd file starts export process using assets folder
- key opens a preferences panel for compatibility rules
- uninstaller deletes app and preferences
- download tutorials
*)

--=========================
(* Transfer, Place, and Export 4.1 *)

-- Info: Convenient and quickly accessible way to drop files into the Artwork folder, even when it isn’t open in Finder. Just drag the pieces onto the Dock icon, and they’ll transfer. Drag an .indd onto the Dock icon, and you can export the magazine with a selection of SCJ-specific web and print presets (and even email it).
-- Created February 13 2021
-- Last updated November 18 2021
--=========================

on open theDroppedItems
	if neverRanThisMachine is false then
		global assets_path
		
		set uninstalled to false
		set movingArt to false
		set transferSuccess to false
		
		-- delay 0.2
		
		repeat with a from 1 to length of theDroppedItems
			set theCurrentDroppedItem to item a of theDroppedItems
			set the itemInfo to info for theCurrentDroppedItem
			set droppedItemPath to alias theCurrentDroppedItem as text
			set droppedFileExtension to the name extension of itemInfo
			set docName to (name of (info for theCurrentDroppedItem))
			if docName is "Uninstaller" then
				set uninstalled to true
			end if
			if droppedFileExtension is "indd" then
				global runcountThisMachine
				if runcountThisMachine is less than 1 then
					rsyncPDFpresets()
					display notification "SCJ PDF export presets were installed." with title "PDF Presets 🔧"
				end if
				global adobeCCver
				-- global IDver
				global firstname
				global assets_path
				display notification "was added to the SCJ InDesign export queue" subtitle "“" & docName & "”" with title "Export Magazine 📚"
				set exportScript to (path to me as text) & "Contents:Resources:Scripts:ExportMagazine.scpt" as alias
				set theResult to run script exportScript with parameters {droppedItemPath, docName, adobeCCver, assets_path, IDver, "choose"}
			else if droppedFileExtension is "docx" or droppedFileExtension is "doc" or droppedFileExtension is "rtf" then
				set itemCount to (length of theDroppedItems as string)
				if itemCount is less than 2 then
					if droppedFileExtension is "docx" or droppedFileExtension is "doc" then
						set docTypeHumanReadable to "Word document"
					else
						set docTypeHumanReadable to "text file"
					end if
					set getLargest to true
					try
						set getLargestIDTextFrame to (path to me as text) & "Contents:Resources:Scripts:PollTextFramesInDesign.scpt" as alias
						set textFrameInfo to run script getLargestIDTextFrame
						set largestTextFrameID to item 1 of textFrameInfo
						set largestTextFrameArea to item 2 of textFrameInfo
						set largestTextFrameSize to item 3 of textFrameInfo
						set largestTextFrameIndex to item 4 of textFrameInfo
					on error
						set getLargest to false
					end try
					set writingFile to theCurrentDroppedItem as «class furl»
					tell application id "com.adobe.InDesign"
						tell word RTF import preferences
							set convert page breaks to none
							set import endnotes to false
							set import footnotes to false
							set import index to false
							set import TOC to false
							set import unused styles to false
							set preserve graphics to false
							set remove formatting to true
							-- set preserve track changes to true
							-- set resolve character style clash to resolve clash use existing
							-- set resolve paragraph style clash to resolve clash use existing
							set use typographers quotes to true
						end tell
						activate
						try
							if docName contains "Category—Prose" or docName contains "Category — Prose" or docName contains "Category_Prose" or docName contains "Cat_Pr" then
								set storyType to "Prose"
							else if docName contains "Category—Poetry" or docName contains "Category — Poetry" or docName contains "Category_Poetry" or docName contains "Cat_Po" then
								set storyType to "Poetry"
							else
								set storyType to button returned of (display alert "Is this a poetry piece or a prose piece?" buttons {"Poetry", "Prose"} default button "Prose")
							end if
						on error
							set storyType to "Prose"
						end try
						try
							set italicsPref to button returned of (display alert "Do you want to try to preserve italics?" message "If this " & docTypeHumanReadable & " uses custom formatting, preserving italics can also transfer other formatting issues." & return & return & "Don’t consider it unless you know the piece uses italicized text." buttons {"Preserve", "Don’t Preserve"})
						on error
							set italicsPref to "Don’t Preserve"
						end try
						if italicsPref is "Preserve" then
							tell word RTF import preferences to set preserve local overrides to true
						else
							tell word RTF import preferences to set preserve local overrides to false
						end if
						try
							if storyType is "Poetry" then
								tell active document to set myParaStyle to paragraph style "Body Copy (Poetry)" of paragraph style group "Poetry" of paragraph style group "Magazine"
							else
								tell active document to set myParaStyle to paragraph style "Body Copy (Prose)" of paragraph style group "Prose" of paragraph style group "Magazine"
							end if
							tell active page of layout window 1 of active document
								if getLargest is true then
									set emptyFrame to text frame largestTextFrameIndex
								else
									if storyType is "Poetry" then
										set emptyFrame to text frame 2
									else
										set emptyFrame to text frame 1
									end if
								end if
								tell parent story of emptyFrame to set contents to ""
								tell first insertion point of parent story of emptyFrame to place writingFile -- with properties {label:"Story Piece"}
								apply paragraph style (text of parent story of emptyFrame) using next style of myParaStyle without clearing overrides
								if storyType is "Prose" then apply paragraph style (first paragraph of parent story of emptyFrame) using myParaStyle without clearing overrides
							end tell
							set placeWritingSuccess to true
						on error errorMessage number errorNumber
							set placeWritingSuccess to false
							if errorMessage contains "Can’t get paragraph style" then -- -1728
								display alert "Writing pieces can’t be placed in this particular InDesign document, which seems to be missing a required SCJ paragraph style." message "The InDesign document provided by the SCJ senior designer normally includes a paragraph style called “Body Copy (Prose),” which should be located inside a style group folder called “Prose,” which is itself located in another called “Magazine.”" & return & return & "The style and/or style group folders may have been renamed, or may be missing." as critical
							else if errorMessage contains "Can’t get text frame" then -- also -1728
								display alert "There are no text boxes on this page to place a written piece into."
							else if errorMessage contains "No documents are open" or errorNumber is 90884 then
								activate
								display alert "To place a written piece in Scripps College Journal, please open the InDesign document and navigate to the page you want it on."
							else
								if errorMessage contains "Cannot handle the request because a modal dialog" then
									set errorGuess to "Our best guess: the document you tried placing used footnotes or endnotes. These documents will not work." & return & return -- error 30486
								else
									set errorGuess to ""
								end if
								global firstname
								display alert "Oops! Sorry, " & firstname & ". Scripps College Journal encountered an issue placing the writing piece. Please try again." message errorGuess & "Here’s some info from InDesign about what went wrong: " & return & return & errorMessage & return & "Error code: " & errorNumber
							end if
						end try
						if placeWritingSuccess is true then
							try
								find text preferences
								set find what of find text preferences to nothing
								set font style of find text preferences to "Italic"
								set change to of change text preferences to nothing
								set font style of change text preferences to "Medium Italic"
								tell emptyFrame to change text
								set font style of find text preferences to nothing
								set font style of change text preferences to nothing
							end try
							if italicsPref is "Preserve" then
								try
									set redoButton to button returned of (display alert "Italicized text was preserved when placing. Does the rest of the text look correct?" message "If not, choose “Reformat.” Doing so will remove italics." buttons {"Reformat", "Looks Good"})
								on error
									set redoButton to "Looks Good"
								end try
								if redoButton is "Reformat" then
									apply paragraph style (text of parent story of emptyFrame) using next style of myParaStyle
									apply paragraph style (first paragraph of parent story of emptyFrame) using myParaStyle
								end if
							end if
						end if
					end tell
					if placeWritingSuccess is true then
						set writingTitle to docName
						set writingTitleLength to count (writingTitle)
						if writingTitleLength is greater than 28 then
							set writingTitle to (characters 1 thru 28 of writingTitle as string) & "…"
						end if
						display notification "SCJ font, type sizes, leading, indentation and next styles applied." subtitle storyType & " piece placed in SCJ magazine ✓" with title "“" & writingTitle & "”"
						try
							do shell script "afplay '/System/Library/PrivateFrameworks/ToneLibrary.framework/Versions/A/Resources/AlertTones/PhotosMemoriesNotification.caf'"
						on error
							beep
						end try
					end if
				else
					display alert "To place a prose or poetry piece in the magazine, place one document at a time." message "Make sure to have the magazine open in InDesign as well."
					exit repeat
				end if
			else if droppedFileExtension is "txt" or droppedFileExtension is "pages" or droppedFileExtension is "rtfd" or droppedFileExtension is "odt" or droppedFileExtension is "tex" then
				display alert "Only Word documents can be placed in the SCJ magazine. This type of text file is not supported."
			else
				-- display alert "Do you want to move the selected files into the Artwork folder?" buttons {"No","Yes","Yes, and Don’t Ask Me Again"}
				set movingArt to true
				set artPlaceSuccess to false
				set progress additional description to "Preparing…"
				set progress total steps to -1
				set progress total steps to length of theDroppedItems
				set progress description to "Moving files to Artwork folder"
				set itemCount to (length of theDroppedItems as string)
				if itemCount is "1" then
					set pieces to "piece"
					set pronoun to "it"
					set placeInID to true
				else
					set pieces to "pieces"
					set pronoun to "them"
					set placeInID to false
				end if
				try
					set progress additional description to "Moving " & a & " out of " & length of theDroppedItems & " art " & pieces & return & "File: " & docName
					
					-- Move the files to the Artwork folder
					tell application "Finder"
						move theCurrentDroppedItem to ((assets_path) & "Artwork")
					end tell
					
					set progress completed steps to a
					-- end
					if length of theDroppedItems is greater than 40 and length of theDroppedItems is less than 101 then
						delay 0.02
					else if length of theDroppedItems is greater than 20 and length of theDroppedItems is less than 41 then
						delay 0.04
					else if length of theDroppedItems is greater than 10 and length of theDroppedItems is less than 21 then
						delay 0.08
					else if length of theDroppedItems is greater than 1 and length of theDroppedItems is less than 11 then
						delay 0.15
					else if length of theDroppedItems is less than 2 then
						delay 0.1
					else if length of theDroppedItems is greater than 100 and length of theDroppedItems is less than 200 then
						delay 0.01
					else if length of theDroppedItems is greater than 199 then
						delay 0
					end if
					set transferSuccess to true
				on error
					display notification "We’re not sure why the transfer failed. You can always try again, or move the files manually." with title "Transfer Failed ⚠️"
					set transferSuccess to false
					exit repeat
				end try
				
				if placeInID is true and transferSuccess is true then
					try
						tell application id "com.adobe.InDesign"
							tell layout window 1 of active document
								select nothing
								set theZoom to zoom percentage
								zoom given show pasteboard
								set zoom percentage to theZoom
							end tell
						end tell
					end try
					try
						set imageNewPath to ((assets_path) & "Artwork") & ":" & (docName as string)
						set imageFile to imageNewPath as «class furl»
						set layerName to ("Placed with SCJ: " & (docName as string)) as string
						tell application id "com.adobe.InDesign"
							activate
							tell active spread of layout window 1 of active document
								set importedImage to make rectangle with properties {geometric bounds:{24, 24, 384, 384}, name:layerName, stroke weight:0}
								set importedImage to page item layerName
								place imageFile on importedImage with properties {label:"scjGraphic"}
								tell importedImage
									fit given proportionally
									fit given frame to content
								end tell
							end tell
						end tell
						set artPlaceSuccess to true
					on error errorMessage number errorNumber
						set artPlaceSuccess to false
						if errorMessage contains "No documents are open" or errorNumber is 90884 then
							activate
							display alert "To place a visual art piece in Scripps College Journal, please open the InDesign document and navigate to the page you want it on."
						else
							display alert "Oops! Sorry, " & firstname & ". Scripps College Journal encountered an issue placing the visual art piece. Please try again." message "Here’s some info from InDesign about what went wrong: " & return & return & errorMessage & return & "Error code: " & errorNumber
						end if
					end try
				end if
				
			end if
		end repeat
		
		if movingArt is true and uninstalled is false and transferSuccess is true then
			set itemCount to ((progress completed steps) as string)
			set artTitle to docName
			set artTitleLength to count (artTitle)
			if artTitleLength is greater than 28 then
				set artTitle to (characters 1 thru 28 of artTitle as string) & "…"
			end if
			
			if itemCount is "1" then
				set notifTransferSuccess to "“" & artTitle & "”"
			else
				set notifTransferSuccess to itemCount & " " & "visual art " & pieces
			end if
			if artPlaceSuccess is true then
				if droppedItemPath contains "Scripps College Journal — Volume " then
					set transferMsg to ""
				else
					set transferMsg to " File was also transferred to Artwork folder"
				end if
				display notification "Frame is proportionally sized to artwork" & transferMsg subtitle "Visual art placed in SCJ magazine ✓" with title notifTransferSuccess
				try
					if placeInID is true then do shell script "afplay '/System/Library/PrivateFrameworks/ToneLibrary.framework/Versions/A/Resources/AlertTones/PhotosMemoriesNotification.caf'"
				on error
					beep
				end try
			else
				if droppedItemPath contains "Scripps College Journal — Volume " then
					set transferMsg to "already in Artwork folder ✓"
				else
					set transferMsg to "transferred to Artwork folder ✓"
				end if
				display notification "You can now place " & pronoun & " on your pages" subtitle transferMsg with title notifTransferSuccess
			end if
		end if
		
	else if neverRanThisMachine is true then
		display alert "You haven’t opened SCJ before. Please open the app. When you reach the Welcome screen, click “Close” and drag the items onto the icon again."
		continue quit
	end if
	
end open

on idle
	if application id "com.adobe.InDesign" is not running and application id "com.adobe.Illustrator" is not running and neverRanThisMachine is false and launchFinished is true then
		display notification "Click here, then press ⌘Q" with title "Quit SCJ if you haven’t used it in a while"
	end if
	return 86400
end idle

on quit
	assign value loggedIn to key "loggedIn"
	global alreadyOpenAI
	global alreadyOpenID
	if application id "com.adobe.Illustrator" is running and application id "com.adobe.InDesign" is running and alreadyOpenAI is false and alreadyOpenID is false then
		set appRunningOnQuit to "InDesign and Illustrator"
		set askOnQuit to true
	else if application id "com.adobe.Illustrator" is running and alreadyOpenAI is false then
		set appRunningOnQuit to "Illustrator"
		set askOnQuit to true
	else if application id "com.adobe.InDesign" is running and alreadyOpenID is false then
		set appRunningOnQuit to "InDesign"
		set askOnQuit to true
	else
		set askOnQuit to false
	end if
	if askOnQuit is true then
		set quitButton to button returned of (display alert "Quitting SCJ will quit " & appRunningOnQuit & ". Are you sure?" buttons {"Back…", "Quit"}) -- add Save & Quit option
		if quitButton is "Quit" then
			if appRunningOnQuit is "Illustrator" then
				tell application id "com.adobe.Illustrator" to quit
			else if appRunningOnQuit is "InDesign" then
				tell application id "com.adobe.InDesign" to quit
			else if appRunningOnQuit is "InDesign and Illustrator" then
				tell application id "com.adobe.InDesign" to quit
				tell application id "com.adobe.Illustrator" to quit
			end if
			display notification "Quitting " & appRunningOnQuit & "…" with title "Design Guide 📘"
			continue quit
		else
			Welcome() -- haven’t tried it, but if this was removed, maybe it would just go to its finished state
		end if
	else if askOnQuit is false then
		continue quit
	end if
end quit

on uninstallSCJ(location)
	set confirmUninstall to button returned of (display alert "Are you sure you want to uninstall the SCJ app?" message "Your design work will not be removed." buttons {"Cancel", "Uninstall"} default button "Cancel" as critical) -- "SCJ configuration settings will be removed from Adobe apps."
	if confirmUninstall is "Uninstall" then
		set uninstalled to true
		set progress description to "Preparing to uninstall…"
		delay 1
		set progress description to "Removing fonts…"
		try
			try
				set fontsUninstalled to true
				set computer_fonts to (((path to library folder from user domain as text) & "Fonts:SCJ") as alias) as string
				set computer_fonts_POSIX to quoted form of the POSIX path of computer_fonts
				do shell script "rm -rf -d '" & computer_fonts_POSIX & "'"
				delay 0.5
			on error
				set progress description to "Removing fonts failed ⚠️"
				set fontsUninstalled to false
			end try
			set progress description to "Resetting Adobe apps…"
			try
				set IDworkspaceRemoved to true
				try
					set IDworkspaceFile to (((path to home folder as text) & "Library:Preferences:Adobe InDesign:Version " & IDver & ".0:en_US:Workspaces:Scripps College Journal.xml") as alias)
					set IDworkspaceFile2 to (((path to home folder as text) & "Library:Preferences:Adobe InDesign:Version " & IDver & ".0:en_US:Workspaces:Scripps College Journal_CurrentWorkspace.xml") as alias)
				on error
					set IDworkspaceFile to (((path to home folder as text) & "Library:Preferences:Adobe InDesign:Version " & IDverFull & ":en_US:Workspaces:Scripps College Journal.xml")) as alias
					set IDworkspaceFile2 to (((path to home folder as text) & "Library:Preferences:Adobe InDesign:Version " & IDverFull & ":en_US:Workspaces:Scripps College Journal_CurrentWorkspace.xml")) as alias
				end try
				set IDworkspaceFile_POSIX to quoted form of the POSIX path of IDworkspaceFile
				set IDworkspaceFile_POSIX2 to quoted form of the POSIX path of IDworkspaceFile2
				do shell script "rm -rf " & IDworkspaceFile_POSIX
				do shell script "rm -rf " & IDworkspaceFile_POSIX2
				delay 0.5
			on error
				set progress description to "Resetting Adobe apps failed ⚠️"
				set IDworkspaceRemoved to false
			end try
			set progress description to "Removing SCJ app settings…"
			resetAllSettings(false, "uninstall")
			delay 0.5
			try
				set preferencesDeleted to true
				set preferencesFile to (((path to home folder as text) & "Library:Preferences:edu.scrippsjournal.design.plist") as alias)
				set preferencesFile_POSIX to quoted form of the POSIX path of preferencesFile
				do shell script "rm -rf " & preferencesFile_POSIX
			on error
				set preferencesDeleted to false
			end try
			set progress description to "Uninstalling SCJ app…"
			set appRemoved to true
			set appPath to (path to me) as alias
			tell application "Finder" to move appPath to trash
			try
				do shell script "afplay '/System/Library/Components/CoreAudio.component/Contents/SharedSupport/SystemSounds/finder/empty trash.aif'"
			end try
		on error
			set uninstalled to false
			set progress description to "Paused…"
			delay 1
			-- if fontsUninstalled is false then display dialog "Fonts false"
			-- if IDworkspaceRemoved is false then display dialog "ID workspace false"
			-- if preferencesDeleted is false then display dialog "preferences false"
			set uninFail to button returned of (display alert "Uninstallation did not succeed." buttons {"Try Again", "OK"} default button "Try Again" as critical) -- for critical information, don’t use notifications
			if uninFail is "Try Again" then
				uninstallSCJ(location)
			else
				if location is "welcome" then Acknowledgments(loggedIn)
			end if
		end try
		delay 0.5
		if uninstalled is true then
			set progress description to "We’ve uninstalled SCJ."
			display notification "Scripps College Journal is uninstalled." with title "Setup 🛠"
			continue quit
		end if
	else
		if location is "welcome" then Acknowledgments(loggedIn)
	end if
end uninstallSCJ

--===============================================
-- End SCJ Program
