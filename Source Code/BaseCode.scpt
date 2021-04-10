--===============================================
-- SCRIPPS COLLEGE JOURNAL Software Version 0 Beta for Mac, tested and compiled on macOS 10.15.7 (19H524) (Intel-based)
-- Intel x86 binary
-- Last updated 						March 1 2021
-- First released staffwide 				February 2021
-- Beta entered limited staff testing 		February 2021
-- Development began 					July 11 2020
-- Originally packaged with SCJ Visual Design System Version 2.1 for Volume 22
-- © 2020–2021 Shay Lari-Hosain. All rights reserved. Scripps College and The Claremont Colleges do not own any portion of this software. This installer and design system are student-created. The author is not responsible for any modifications, or the consequences of modifications, that are made to this software by others.
-- Last updated by: Shay Lari-Hosain PZ (replace with new name if further development continues)
-- Created by: Shay Lari-Hosain PZ
--===============================================

--=========================
(* AppTranslocationSecurityCheck 1.2 *)

-- Info: Complies with Apple security provisions for apps distributed via unsigned distribution methods
-- Created March 1 2021
-- Last updated March 2 2021
--=========================
set appleAppTranslocationCheck to (((path to me as text) as alias) as string) as text
-- display dialog appleAppTranslocationCheck -- debugger
if appleAppTranslocationCheck does not contain "Users:" and appleAppTranslocationCheck does not contain "Applications:" and appleAppTranslocationCheck does not contain "Library:" then
	-- ZIP alert display alert "To install the SCJ app, please move its icon out of the Visual Design System folder. Then place it right back in the folder." message "You can move the folder anywhere you want. We recommend Documents or Applications."
	set correctPathInstalled to false
	display alert "To install SCJ, drag it to Applications." & return & "Then drag the Assets folder there too." message "Read the enclosed instructions before opening it for the first time."
	continue quit
else
	set correctPathInstalled to true
end if

property runcount : 0

-- Code if app is installed via DMG disk image (won't break if distributed via ZIP)
if runcount is 0 then
	if correctPathInstalled is true then
		tell application "Preview" to close (every window whose name contains "Read Me First")
		tell application "Preview" to close (every window whose name contains "Release Notes")
		try
			tell application "Finder" to eject disk "Install Scripps College Journal"
		end try
	end if
end if

-- Run IconSwitcher
set iconScript to (((path to me as text) & "Contents:IconSwitcher.scpt") as alias) as string
run script file iconScript

-- Run Compatibility Verification
set loadTime to (((path to me as text) & "Contents:Resources:Scripts:SetTimeHandler.scpt") as alias) as string
set loadTime to (load script loadTime as alias)

property cverify : true
set CCCpass to false
set compatibilityscriptpath to (((path to me as text) & "Contents:Resources:Scripts:ComprehensiveCompatibilityCheck.scpt") as alias) as string
set loadCCC to (load script file compatibilityscriptpath)
set CCCinfo to DetermineCompatibility() of loadCCC
if cverify is true then
	run script loadCCC
	set CCCpass to true
	-- For testing purposes only: display notification "Ccheck passed"
end if

-- Run Disk Verification
set diskscriptpath to (((path to me as text) & "Contents:Resources:Scripts:FreeDiskSpace.scpt") as alias) as string
run script file diskscriptpath

set currentyear to getYear() of loadTime
set currentmonth to getMonthName() of loadTime
set currentmonthInt to getMonth() of loadTime
set currenttime to getTime() of loadTime

set adobeCCver to item 1 of CCCinfo
set IDver to item 2 of CCCinfo
set AIver to item 3 of CCCinfo
set osname to item 12 of CCCinfo
set IDverFull to item 13 of CCCinfo

set osver to item 4 of CCCinfo
set shortname to item 5 of CCCinfo
set fullname to item 6 of CCCinfo
set firstname to item 7 of CCCinfo
set computername to item 8 of CCCinfo
set macmodel to item 9 of CCCinfo
set macmodelid to item 10 of CCCinfo
set uuid to item 11 of CCCinfo

-- SCJ Issue

set scjissueyear to getIssueYear() of loadTime
set scjvolume to getVolume() of loadTime

-- Check if the app has been run before

global lastUser
global lastComputer
global lastMachine
global lastMachineID
global lastUserName
global lastUnixName
global lastUniqueID
-- Defaults at first run
property openedBeforeThisMachine : false
property neverRan : true
property neverRanThisMachine : true
-- used to define runcount here, but then moved up
property runcountThisMachine : 0
property dontShowAlert : false

if runcount is greater than 0 then
	if computername is not lastComputer and firstname is not lastUserName or macmodelid is not lastMachineID and fullname is not lastUser or lastUniqueID is not uuid and fullname is not lastUser or macmodelid is not lastMachineID and computername is not lastComputer or shortname is not lastUnixName then
		set runcountThisMachine to 0
		set openedBeforeThisMachine to false
		set neverRanThisMachine to true
		set loggedIn to false
		set lastUniqueID to missing value
	end if
end if

if dontShowAlert is false then
	if runcount is greater than 0 and runcountThisMachine is 0 then
		if lastMachine starts with "a" or lastMachine starts with "e" or lastMachine starts with "i" or lastMachine starts with "o" or lastMachine starts with "u" then
			set pronoun to "an"
		else
			set pronoun to "a"
		end if
		set diffCompMsg to "If you got it from " & lastUserName & " instead of downloading it directly from us, it may not function correctly."
		-- if runcount is greater than 0 then set diffCompMsg to diffCompMsg & return & return & "Make sure to save any work first."
		set diffCompAlert to button returned of (display alert "This app was already run by " & lastUserName & " on " & pronoun & " " & lastMachine & "." message diffCompMsg buttons {"Don't Show Again", "Continue", "Redownload from SCJ…"} default button "Redownload from SCJ…" as critical)
		if diffCompAlert is "Redownload…" then
			DownloadSCJ()
			error number -128
			if diffCompAlert is "Don't Show Again" then
				set dontShowAlert to true
			end if
		end if
	end if
end if

-- Get Started
set getstartedscriptpath to (((path to me as text) & "Contents:Resources:Scripts:FirstTime.scpt") as alias) as string
if openedBeforeThisMachine is false then
	-- COMMENTED OUT FOR DEBUGGING run script file getstartedscriptpath
	set openedBeforeThisMachine to true
end if



--=========================
(* NLU Dialog 1.1 *)

-- Info: Inactive until 2027. Program runs once every eight runs. In 2027, remove this section of code if the app is continuing to be updated.
-- Created September 5 2020
-- Last updated September 18 2020
--=========================

property NLUdialog : false -- NLU stands for No Longer Updated
property NLUdismissedForever : false

if currentyear is greater than 2026 then
	
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
		set NLUbuttons to {"Don't Show Again", "OK"}
	end if
	
	if runcount mod 3 is 0 then
		set msgPortion to return & return & "However, we fully intend for you to continue using it. If you encounter any problems with the app, just use the design guides manually."
	else
		set msgPortion to ""
	end if
	
	if r is yes and NLUdismissedForever is false then
		set NLUreturned to button returned of (display alert NLUheader message "Any unforeseen changes that Apple or Adobe make to their software in the future could break functionality." & msgPortion buttons NLUbuttons as critical)
		set NLUdialog to true
		if NLUreturned is "Don't Show Again" then
			set NLUdismissedForever to true
		end if
	end if
	
end if

--=========================
(* BaseCode 10.3R *)

-- Info: Main program that handles the primary tasks the SCJ application is designed for. Very early builds named Get Started
-- Created July 12 2020
-- Last updated March 1 2021
--=========================

-- Directory tree is damaged alert

on Dialog()
	global neverRan
	if neverRan is true then
		set damagedAlert to "Assets are missing or damaged. Please delete and redownload the SCJ Design System."
		set damagedMsg to "Don't send team members your app. Point them to the original."
	else if neverRan is false then
		set damagedAlert to "Assets are missing or damaged."
		set damagedMsg to "Please delete and redownload the SCJ Design System. If you've worked on any files, make sure to keep them." & return & return & "You can put the top folder anywhere you want, but never rename its subfolders." & return & return & "Don't send team members your app. Point them to the original."
	end if
	set assetbutton to button returned of (display alert damagedAlert message damagedMsg as critical buttons {"Quit", "Redownload…"} default button "Redownload…")
	if assetbutton is "Redownload…" then
		DownloadSCJ()
		-- Future feature: If neverRan is false then replace the files. Detect where they currently are, and replace with the files in the one that's on the desktop. Display notification "we've migrated the contents to the new installation."
		error number -128
	else if assetbutton is "Quit" then
		error number -128
	end if
end Dialog

on DownloadSCJ()
	set FileDownload to "https://dl.dropboxusercontent.com/s/0bd3o9p81jyt47n/DownloadFileTest.zip?dl=0" -- CHANGE FINAL URL, USE GITHUB?
	set FileExtension to ".zip"
	set FileName to "SCJDesign"
	do shell script "curl -f '" & FileDownload & "' -o ~/Desktop/" & FileName & FileExtension -- doesn't work with Google Drive files for some reason
	display notification "A new copy of SCJ has been downloaded to your desktop."
	tell application "Finder"
		open file ((path to desktop folder as text) & FileName & FileExtension)
	end tell
	delay 3
	tell application "System Events"
		delete file ((path to desktop folder as text) & FileName & FileExtension)
	end tell
end DownloadSCJ

-- Define asset locations & asset integrity check

global new_name
if neverRan is true then
	set new_name to "Scripps College Journal — Volume " & scjvolume
	try
		tell application "System Events" to set name of folder ((((path to me as text) & "::Assets") as alias) as string) to new_name
		(*
	on error
		set assets_path to (choose folder with prompt "The SCJ Assets folder has been renamed or moved. Please relocate it:") as alias as string
		try
			set rcheck to ((assets_path & "Fonts") as alias) as string
		on error
			try
				set rcheck to ((assets_path & ".Fonts") as alias) as string
			on error
				Dialog()
			end try
		end try
		*)
	end try
end if

try
	set assets_path to (((path to me as text) & "::" & new_name) as alias) as string
on error
	try
		set assets_path to (((path to me as text) & "::Assets") as alias) as string -- In the instance that app has already been run but folder has been swapped with fresh Assets folder.
		tell application "System Events" to set name of folder ((((path to me as text) & "::Assets") as alias) as string) to new_name
		set assets_path to (((path to me as text) & "::" & new_name) as alias) as string
	on error
		set assets_path to (choose folder with prompt "The SCJ Assets folder has been renamed or moved. Please relocate it:") as alias as string
		try
			set rcheck to ((assets_path & "Fonts") as alias) as string
		on error
			try
				set rcheck to ((assets_path & ".Fonts") as alias) as string
			on error
				Dialog()
			end try
		end try
	end try
end try

if neverRan is true then
	try
		set check to ((assets_path & "Fonts") as alias) as string
		set AssetsNew to true
	on error
		try
			set check to ((assets_path & ".Fonts") as alias) as string
			set AssetsNew to false
		end try
	end try
end if

if runcount is 0 then
	try
		set font_path to ((assets_path & "Fonts") as alias) as string
	on error
		if AssetsNew is false then
			set font_path to ((assets_path & ".Fonts") as alias) as string
		end if
	end try
end if
if runcount is greater than 0 then
	try
		set font_path to ((assets_path & ".Fonts") as alias) as string
	on error
		set font_path to ((assets_path & "Fonts") as alias) as string
		set AppOldNewAssets to true
	end try
end if

-- Verification is complete and installer launch may begin

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

--=========================
(* WelcomeManager 2.9.2; Dynamic Welcome Message (Fork) *)

-- Info: Program (now integrated within BaseCode) that provides the main front-end user interface and manages SCJ user authentication
-- Created July 12 2020
-- Last updated February 26 2021
--=========================

set neverRan to false
set neverRanThisMachine to false

property loggedIn : false

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
	set depnoticetext to "its compatibility rules to notify you of any Adobe or OS incompatibilities. Everyone on the design team must verify manually that they're using the same version of Adobe CC."
	if scjissueyear is 2026 then
		set deprecatednotice to return & return & "Starting next year, this app will no longer auto-update " & depnoticetext
	else if scjissueyear is greater than or equal to 2027 then
		set deprecatednotice to return & return & "This app no longer auto-updates " & depnoticetext
	else if scjissueyear is less than 2026 then
		set deprecatednotice to return
	end if
	
	if loggedIn is false then
		set adminButton to "Log In As Admin…"
		set SCJuser to "staff"
	else if loggedIn is true then
		set adminButton to "Log Out Of Admin…"
		set SCJuser to "managing editor"
	end if
	
	if runcountThisMachine is less than 2 then
		set welcomeMsg1 to ". You're ready to begin building Volume "
		set welcomeMsg0 to "We're so thrilled to have you on board as a designer, "
	else if runcountThisMachine is greater than 1 then
		set welcomeMsg1 to ". You're on your way to building Volume "
		if runcountThisMachine mod 2 is 0 then
			set welcomeMsg0 to "We're so thrilled to have you on board as a designer, "
		else
			set welcomeMsg0 to "You got this, "
		end if
	end if
	if runcountThisMachine is less than 1 then
		set startButton to "Start Designing"
		set welcomeMsg2 to return & return & "With one click, we'll configure your Adobe apps with everything you need, and show you around the design guides." & return & return & "When you're done working, quit SCJ to close everything."
	else if runcountThisMachine is greater than 0 then
		set startButton to "Continue Designing"
	end if
	
	if runcountThisMachine is less than 6 and runcountThisMachine is greater than 0 then
		set welcomeMsg2 to return & return & "You can pin the SCJ icon in the Dock for easy access next time."
	else if runcountThisMachine is less than 11 and runcountThisMachine is greater than 5 then
		set welcomeMsg2 to return & return & "The best way to preview your work and assess your pages’ layout is to print them at 100% scale, if you have easy access to a printer."
	else if runcountThisMachine is less than 26 and runcountThisMachine is greater than 10 then
		set welcomeMsg2 to return & return & "Back up your work periodically, either with Time Machine or by dragging key files into Google Drive."
	else if runcountThisMachine is greater than 25 then
		set welcomeMsg2 to ""
	end if
	
	if runcountThisMachine is greater than 100 then
		set welcomeMsg0 to "Wow, your dedication to SCJ is admirable! Maybe it's time to take a break—please make sure you're taking care of yourself first and foremost, "
		set welcomeMsg1 to ". We love what you're doing with Volume "
	end if
	
	if runcountThisMachine is greater than 2 then
		set artFolder to ((assets_path & "Artwork") as alias)
		tell application "Finder"
			set result to (count files of entire contents of artFolder)
		end tell
		if the result = 0 then
			set transferMsg to "The Artwork folder is still empty. "
		else
			set transferMsg to ""
		end if
	else
		set transferMsg to ""
	end if
	
	set loadFDS to (load script diskscriptpath as alias)
	set freeSpace to DetermineDisk() of loadFDS as integer
	set diskUnit to " GB"
	if freeSpace is greater than 999 then
		set diskUnit to " TB"
		set freeSpace to (freeSpace * 1.0E-3)
		set freeSpace to roundThis(freeSpace, 2)
	end if
	
	if loggedIn is true then
		set diskAbout to freeSpace & diskUnit & " free on disk" & return & return
	else
		set diskAbout to ""
	end if
	
	-- 🎨📚🖌🌻
	set launchButton to button returned of (display alert "Welcome to the Scripps College Journal Design Guide" message welcomeMsg0 & firstname & welcomeMsg1 & scjvolume & ".

" & transferMsg & "Move art to the Artwork folder before placing on your pages.

To do that now, just click “Quit” and drag the images onto the SCJ Dock icon. Then click the icon to return here." & welcomeMsg2 buttons {"About…", "Quit", startButton} default button 3)
	
	if (text of launchButton) is "About…" then
		set backButton to button returned of (display dialog "© Scripps College Journal
For internal use only

Upcoming issue is Spring " & scjissueyear & ", Volume " & scjvolume & deprecatednotice & "

Logged in as " & SCJuser & " on " & computername & "

Adobe CC " & adobeCCver & " " & "installed

" & diskAbout & "App version " & version & "
Design version 2.1" with title "About" buttons {adminButton, "Acknowledgments…", "Back…"} default button "Back…" with icon note) -- can change this to a different icon if we don't want the Construction icon
		if text of backButton is "Back…" then
			Welcome()
		else if text of backButton is "Acknowledgments…" then
			Acknowledgments()
		else if text of backButton is "Log In As Admin…" then
			set authenticateAdmin to (((path to me as text) & "Contents:Resources:Scripts:PasswordProtect3.scpt") as alias) as string
			set loggedIn to (run script (file authenticateAdmin) with parameters (loggedIn))
			-- DEBUGGER display dialog "WelcomeDialog received login status: " & loggedIn
			if loggedIn is true then
				display notification "Welcome back, SCJ Senior Designer."
				set cverify to false
			end if
			-- AuthenticationHandler()
			Welcome()
		else if text of backButton is "Log Out Of Admin…" then
			set loggedIn to false
			display notification "Logged out! Welcome back, SCJ Designer."
			set cverify to true
			Welcome()
		end if
	else if launchButton is "Start Designing" or launchButton is "Continue Designing" then
		if runcountThisMachine is 0 then
			if application id "com.adobe.InDesign" is running then
				set quitIDonInstall to button returned of (display alert "We have to restart InDesign before installing design resources." message "It's only necessary the first time you run Scripps College Journal. Please save any open work." buttons {"Back…", "Continue"} default button 2 as critical)
				if quitIDonInstall is "Continue" then
					tell application id "com.adobe.InDesign" to quit
					Designing()
					-- create new global unique variable just for first run to tell the quit handler to quit InDesign at the end too?
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
	else if launchButton is "Quit" then
		display notification "Press ⌘Q to quit"
		-- display notification "Press ⌘Q to quit. Drag files to the Dock icon to move them to the Artwork folder."
	end if
	
end Welcome

set licenseopen to false
set privacyopen to false
global licenseopen
global privacyopen
set licensebt to "License Agreement"
set privacybt to "Usage"

on Acknowledgments()
	global licensebt
	global privacybt
	set abtn to button returned of (display dialog "SCJ Visual Design System created by" & return & "Shay Lari-Hosain" & return & return & "Special thanks to" & return & "Ariel So, Jamie Jiang and Kerry Taylor" & return & return & "SCJ Leaf illustrated by" & return & "Karen Wang" & return & return & "SCJ Flag designed by" & return & "Shay Lari-Hosain" with title "Acknowledgments" buttons {licensebt, privacybt, "Back…"} default button "Back…")
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
		else if licenseopen is true then
			tell application "Preview" to close (every window whose name contains "SCJ License Agreement")
			set licenseopen to false
			set licensebt to "License Agreement"
		end if
		Acknowledgments()
	else if abtn is "Usage" or abtn is "Close Usage" then
		if privacyopen is false then
			set privacyinfo to (path to me as text) & "Contents:Resources:SCJ Usage Info.pdf" as alias -- relocate to Resources path inside app
			set privacyopen to true
			tell application "Preview" to open file privacyinfo
			set privacybt to "Close Usage"
		else if privacyopen is true then
			tell application "Preview" to close (every window whose name contains "SCJ Usage Info")
			set privacyopen to false
			set privacybt to "Usage"
		end if
		Acknowledgments()
	end if
end Acknowledgments

Welcome()

-- Install SCJ typefaces; doesn't install any that are already installed

global launchFinished

on Designing()
	
	-- set launchFinished to false -- this might be why on first run it redoes everything after circling back? never mind
	
	global assets_path
	global font_path
	global AssetsNew
	global AppOldNewAssets
	global scjissueyear
	global IDver
	global IDverFull
	global runcountThisMachine
	
	set userLibraryFontPath to (((path to library folder from user domain as text) & "Fonts") as alias)
	tell application "System Events"
		make new folder at end of (userLibraryFontPath) with properties {name:"SCJ"}
	end tell
	set computer_fonts to (((path to library folder from user domain as text) & "Fonts:SCJ") as alias) as string
	
	-- alternate: set computer_fonts to (((path to home folder as text) & "Library:Fonts" as alias) as string)
	-- set computer_fonts to (((path to desktop as text) & "testfonts") as alias) as string -- for testing
	
	set font_path_POSIX to quoted form of the POSIX path of font_path
	set computer_fonts_POSIX to quoted form of the POSIX path of computer_fonts
	do shell script "rsync -a " & font_path_POSIX & " " & computer_fonts_POSIX
	
	tell application "Finder" to activate
	if runcountThisMachine is 0 then
		display notification with title "SCJ fonts were installed on your Mac."
	else if runcountThisMachine is greater than 0 and runcountThisMachine is less than 6 then
		display notification "If any were missing before, we just installed them." with title "SCJ fonts were already detected on your Mac."
	end if
	
	-- Import Adobe PDF presets
	
	if runcountThisMachine is 0 then
		try
			rsyncPDFpresets()
			delay 3
			display notification with title "SCJ PDF export presets were installed."
		end try
	else if runcountThisMachine is greater than 0 then
		try
			set PDFpresetscheck to (((path to home folder) as text) & "Library:Application Support:Adobe:Adobe PDF:Settings:Scripps College Journal — Magazine for Print.joboptions" as alias)
		on error
			try
				rsyncPDFpresets()
				delay 3
				display notification "Somehow the SCJ PDF export presets still weren't installed. We just installed them."
			end try
		end try
	end if
	
	-- Import Adobe workspaces
	
	--=========================
	(* Adobe Workspace Installer 1.4.1 *)
	
	-- Info: Pretty rock-solid in my opinion as of February 1. Don't really have an opportunity to test all the possibilities, but I think the error blocks cover any issues. Could use -1700 specifically, but probably no need, as seen in the Adobe Workspace Installer DEBUGGER programs. Removed Adobe Illustrator workspace on February 1 2021
	-- Created August 15 2020
	-- Last updated February 26 2021
	--=========================
	
	try
		if runcountThisMachine is 0 then
			rsyncWorkspaces()
			-- display notification "SCJ InDesign workspace installed."
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
				display notification "Somehow the InDesign workspace still wasn't installed. We just installed it."
			end try
		end if
		set IDworkspaceInstalled to true
	on error
		delay 3
		display notification "You'll have to import it yourself." with title "⚠️ Sorry, we couldn't install the SCJ InDesign workspace."
		set IDworkspaceInstalled to false
		try
			set SCJworkspace to ((assets_path & ".Workspace") as alias) as string
		on error
			set SCJworkspace to ((assets_path & "Workspace") as alias) as string
		end try
		tell application "System Events" to set name of folder SCJworkspace to "Workspace"
	end try
	
	-- Launch SCJ style guides & templates
	
	delay 3
	
	tell application "Finder"
		set myFolder to assets_path as alias
		set myIDFiles to (every item of myFolder whose name extension is "indd") as alias list
		set myAIFiles to (every item of myFolder whose name extension is "ai") as alias list
		open myIDFiles
		open myAIFiles
	end tell
	
	tell application id "com.adobe.InDesign" to activate
	
	-- Show each document and explain their purposes 
	
	if runcountThisMachine is 0 then
		
		(* delay 4
		
		display notification "Front cover template has been opened in Illustrator." -- get rid of these notifications if it's going to flip to each document and issue an explainer notifications
		
		delay 2
		
		display notification "Magazine design template has been opened in InDesign."
		
		delay 2 *)
		
		tell application id "com.adobe.InDesign" to activate
		if scjissueyear is less than 2022 then
			set magDesc to ". 8 × 10 inches, 6 pt grid, CMYK."
		else
			set magDesc to "."
		end if
		display notification "This is the SCJ magazine template" & magDesc with title "InDesign is active"
		delay 4
		tell application id "com.adobe.Illustrator" to activate
		display notification "This is the front cover template. Once it's designed, you'll update it in two locations." with title "Illustrator is active"
		delay 4
		
	end if
	
	-- Switch to SCJ Adobe workspaces
	
	tell application id "com.adobe.InDesign" to activate
	try
		tell application id "com.adobe.InDesign"
			apply workspace name "Scripps College Journal"
			set IDworkspaceApplied to true
		end tell
	on error
		set IDworkspaceApplied to false
		if IDworkspaceInstalled is true then
			display notification "Click the dropdown menu in the top right corner and select the ‘Scripps College Journal’ workspace."
		end if
	end try
	
	if runcountThisMachine is less than 3 then
		if IDworkspaceInstalled is true and IDworkspaceApplied is true then
			display notification with title "InDesign SCJ workspace applied"
		end if
	end if
	
	delay 2
	
	set launchFinished to true
	return assets_path
	
end Designing

on rsyncWorkspaces() -- install Adobe workspaces
	
	global IDver
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
	
	global IDver
	global IDverFull
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

-- Clean up

if launchFinished is true then -- this new if statement accounts for always-on behavior
	(* if runcountThisMachine is 1 then
	display alert "What are you working on at the moment? Let us know for next time." message "We'll continue to open all templates if you select ‘Both.’" buttons {"Both", "Page Layout", "Cover Design"} default button 1 *)
	
	if runcount is 0 then
		tell application "System Events" to set name of folder font_path to ".Fonts"
	end if
	try
		if AppOldNewAssets is true then
			tell application "System Events" to set name of folder font_path to ".Fonts"
		end if
	end try
	
	set lastUser to fullname
	set lastComputer to computername
	set lastMachine to macmodel
	set lastMachineID to macmodelid
	set lastUserName to firstname
	set lastUnixName to shortname
	set lastUniqueID to uuid
	
	set runcount to runcount + 1
	set runcountThisMachine to runcountThisMachine + 1
end if


on reopen
	if launchFinished is false then
		Welcome()
	else if launchFinished is true then
		display notification "Press ⌘Q to quit when you're done. Click the icon for random tips if you're feeling spontaneous."
		set IDtipscriptpath to (((path to me as text) & "Contents:Resources:Scripts:Tips.scpt") as alias) as string
		run script file IDtipscriptpath
	end if
end reopen

(*
On Open Handler
- images (or any files really) move the dropped files to artwork folder
- .indd file starts export process using assets folder
- key opens a preferences panel for compatibility rules
- uninstaller deletes app
- download tutorials

 on open --theDroppedItems
	-- repeat with aDroppedItem in theDroppedItems
	global assets_path
	set documentLocation to assets_path & ":Sample InDesign File.indd"
	set loadAssets to (((path to me as text) & "::InDesignExportPDF (Uninstaller) 2A.scpt") as alias) as string
	run script loadAssets with parameters documentLocation
end open *)

--=========================
(* Transfer Artwork 2.1 *)

-- Info: Convenient and quickly accessible way to drop files into the Artwork folder, even when it isn't open in Finder. Just drag the pieces onto the icon, and they'll transfer.
-- Created February 13 2021
-- Last updated February 28 2021
--=========================

on open theDroppedItems
	if neverRanThisMachine is false then
		global assets_path
		-- display dialog assets_path as string
		
		-- display alert "Do you want to move the selected files into the Artwork folder?" buttons {"No","Yes","Yes, and Don't Ask Me Again"}
		
		set uninstalled to false
		set movingArt to false
		set transferSuccess to false
		
		-- delay 0.2
		
		repeat with a from 1 to length of theDroppedItems
			set theCurrentDroppedItem to item a of theDroppedItems
			set the item_info to info for theCurrentDroppedItem
			set droppedItemPath to alias theCurrentDroppedItem as text
			set droppedFileExtension to the name extension of item_info
			set uNameCheck to (name of (info for theCurrentDroppedItem)) as string
			if uNameCheck is "Uninstaller" then
				-- try
				set uninstalled to true
				set progress description to "Preparing to uninstall…"
				delay 1
				try
					run script file (((path to me as text) & "::Uninstaller:.RemoveSCJ.scpt") as alias)
					set progress description to "Removing fonts…"
					delay 0.5
					set progress description to "Resetting Adobe apps…"
					delay 0.5
					set progress description to "Uninstalling SCJ app…"
					delay 0.5
					set progress description to "We've uninstalled SCJ."
				on error
					set progress description to "Paused…"
					display alert "Uninstallation did not succeed." buttons {"OK"} default button 1 as critical -- for critical information, don't use notifications
				end try
				delay 1
				display notification with title "Scripps College Journal is uninstalled."
				-- end try
				continue quit
			end if
			if droppedFileExtension is "indd" then
				set inddButton to button returned of (display alert "We'll start the export process. (Beta)" buttons {"Package for Senior Designer", "Export Magazine for Print", "Export Magazine for Web"} default button 1) --- UPDATE
				if inddButton is "Package for Senior Designer" then
					-- set passPath to (alias theCurrentDroppedItem) as string
					set docName to (name of (info for theCurrentDroppedItem))
					set action to "exportWeb"
					-- Export(theCurrentDroppedItem, docName, action, droppedItemPath) -- not used anymore
					set exportScript to (path to me as text) & "Contents:Resources:Scripts:ExportMagazine.scpt" as alias
					set theResult to run script exportScript with parameters {droppedItemPath, docName, action}
				end if
			end if
			if droppedFileExtension is not "indd" then
				set movingArt to true
				set progress additional description to "Preparing…"
				set progress total steps to -1
				set progress total steps to length of theDroppedItems
				set progress description to "Moving files to Artwork folder"
				set itemCount to (length of theDroppedItems as string)
				if itemCount is "1" then
					set pieces to "piece"
					set pronoun to "it"
				else
					set pieces to "pieces"
					set pronoun to "them"
				end if
				try
					set progress additional description to "Moving " & a & " out of " & length of theDroppedItems & " art " & pieces & return & "File: " & (name of (info for theCurrentDroppedItem))
					
					-- NEEDS TO ACTUALLY MOVE THE FILES TO THE ARTWORK FOLDER
					-- display alert ((assets_path) & "Artwork")
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
					display notification "We're not sure why the transfer failed. You can always try again, or move the files manually." with title "Transfer Failed ⚠️"
					set transferSuccess to false
					exit repeat
				end try
			end if
		end repeat
		
		if movingArt is true and uninstalled is false and transferSuccess is true then
			set itemCount to ((progress completed steps) as string)
			set artTitle to (name of (info for theCurrentDroppedItem))
			set artTitleLength to count (artTitle)
			if artTitleLength is greater than 14 then
				set artTitle to (characters 1 thru 14 of artTitle as string) & "…"
			end if
			
			if itemCount is "1" then
				set notifTransferSuccess to "“" & artTitle & "”"
			else
				set notifTransferSuccess to itemCount & " " & pieces
			end if
			display notification "You can now place " & pronoun & " on your pages." with title notifTransferSuccess & " transferred to Artwork folder"
			try
				do shell script "afplay /System/Library/PrivateFrameworks/ToneLibrary.framework/Versions/A/Resources/AlertTones/PhotosMemoriesNotification.caf"
			on error
				beep
			end try
		end if
		
	else if neverRanThisMachine is true then
		display alert "You haven't opened SCJ before. Please open the app. When you reach the Welcome screen, click “Quit” and drag the files onto the icon again."
		continue quit
	end if
	
end open

(* on idle
end idle *)

on quit
	global CCCpass
	global cverify
	if CCCpass is false and cverify is true then
		continue quit
	end if
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
			display notification "Quitting " & appRunningOnQuit & "…"
			continue quit
		else
			Welcome() -- haven't tried it, but if this was removed, maybe it would just go to its finished state
		end if
	else if askOnQuit is false then
		continue quit
	end if
end quit

--===============================================
-- End SCJ Program
