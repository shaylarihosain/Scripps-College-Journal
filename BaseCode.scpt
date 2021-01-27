--===============================================
-- SCRIPPS COLLEGE JOURNAL Software Version 1.0 for Mac, tested and compiled on macOS 10.15.7 (19H114) (Intel-based)
-- Intel x86 binary
-- Last updated 						January 24 2021
-- First released staffwide 				February 2021
-- Beta entered limited staff testing 		January 2021
-- Development began 					July 11 2020
-- Originally packaged with SCJ Visual Design System Version 2.1 for Volume 22
-- © 2020–2021 Shay Lari-Hosain. All rights reserved. Scripps College and The Claremont Colleges do not own any portion of this software. This installer and design system are student-created. The author is not responsible for any modifications, or the consequences of modifications, that are made to this software by others.
-- Last updated by: Shay Lari-Hosain PZ (replace with new name if further development continues after me)
-- Created by: Shay Lari-Hosain PZ
--===============================================

-- SCJ (Replace with code from elsewhere, this is for debugging)

-- Compatibility Verification
property cverify : true
if cverify is true then
	set compatibilityscriptpath to (((path to me as text) & "::ComprehensiveCompatibilityCheck.scpt") as alias) as string -- CHANGE TO PATH TO RESOURCE
	run script file compatibilityscriptpath
	-- For testing purposes only: display notification "Ccheck passed"
end if
-- Maybe put compatibility and disk check in their own handlers so that you can decide to call them or not call them depending on last status
-- Remember to call each variable as global also

-- Disk Verification
set diskscriptpath to (((path to me as text) & "::FreeDiskSpace.scpt") as alias) as string -- CHANGE TO PATH TO RESOURCE
run script file diskscriptpath

set sysinfo to system info
set osver to system version of sysinfo

set currentyear to (year of (current date) as integer)
set currentmonth to (month of (current date) as string)
set currentmonthInt to month of (current date) as integer
set currenttime to (time string of (current date))

set shortname to short user name of sysinfo
set fullname to long user name of sysinfo
set firstname to word 1 of fullname
set computername to computer name of sysinfo
set macmodel to (do shell script "/usr/sbin/system_profiler SPHardwareDataType | sed -En '/Model Name:/ s/^[^:]+: *//p'")
set macmodelid to (do shell script "/usr/sbin/system_profiler SPHardwareDataType | sed -En '/Model Identifier:/ s/^[^:]+: *//p'")

set uuid to (do shell script "/usr/sbin/system_profiler SPHardwareDataType | sed -En '/Hardware UUID:/ s/^[^:]+: *//p'")

-- SCJ Issue

if currentmonthInt is less than 6 then
	set scjissueyear to currentyear
else if currentmonthInt is greater than 5 then
	set scjissueyear to currentyear + 1
end if

set scjvolume to (scjissueyear - 1999)

-- Check if the app has been run before

global lastUser
global lastComputer
global lastMachine
global lastMachineID
global lastUserName
global lastUnixName
global lastUniqueID
property openedbeforeThisMachine : false
property neverRan : true
property runcount : 0
property runcountThisMachine : 0

if runcount is greater than 0 then
	if computername is not lastComputer and firstname is not lastUserName or macmodelid is not lastMachineID and fullname is not lastUser or lastUniqueID is not uuid and fullname is not lastUser or macmodelid is not lastMachineID and computername is not lastComputer or shortname is not lastUnixName then
		set runcountThisMachine to 0
		set openedbeforeThisMachine to false
		set loggedIn to false
	end if
end if

if runcount is greater than 0 and runcountThisMachine is 0 then
	if lastMachine starts with "a" or lastMachine starts with "e" or lastMachine starts with "i" or lastMachine starts with "o" or lastMachine starts with "u" then
		set pronoun to "an"
	else
		set pronoun to "a"
	end if
	set diffCompMsg to "If you got it from " & lastUserName & " instead of downloading it directly from us, it may not function correctly."
	-- if runcount is greater than 0 then set diffCompMsg to diffCompMsg & return & return & "Make sure to save any work first."
	set diffCompAlert to button returned of (display alert "This app has already been run by " & lastUserName & " on " & pronoun & " " & lastMachine & "." message diffCompMsg buttons {"Continue Anyway", "Redownload from SCJ…"} default button "Redownload from SCJ…" as critical)
	if diffCompAlert is "Redownload…" then
		DownloadSCJ()
		error number -128
	end if
end if

-- Get Started
set getstartedscriptpath to (((path to me as text) & "::FirstTime.scpt") as alias) as string -- CHANGE TO PATH TO RESOURCE
if openedbeforeThisMachine is false then
	run script file getstartedscriptpath
	set openedbeforeThisMachine to true
end if



--=========================
(* NLU Dialog 1.1 *)

-- Info: Inactive until 2026. Program runs once every four runs.
-- Created September 5 2020
-- Last updated September 18 2020
--=========================

property NLUdialog : false -- NLU stands for No Longer Updated
property NLUdismissedForever : false

if currentyear is greater than 2025 then
	
	if runcount mod 4 is 0 then
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
		set msgPortion to return & return & "However, we fully intend for you to continue using it."
	else
		set msgPortion to ""
	end if
	
	if r is yes and NLUdismissedForever is false then
		set NLUreturned to button returned of (display alert NLUheader message "Any unforeseen changes that Apple or Adobe make to their software in the future might break functionality." & msgPortion buttons NLUbuttons as critical)
		set NLUdialog to true
		if NLUreturned is "Don't Show Again" then
			set NLUdismissedForever to true
		end if
	end if
	
end if

--=========================
(* BaseCode 6.3.2 *)

-- Info: Main program that handles the primary tasks the SCJ application is designed for. Very early builds named Get Started
-- Created July 12 2020
-- Last updated November 9 2020
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

--=========================
(* WelcomeDialog 2.5.4; Dynamic Welcome Message (Fork) *)

-- Info: Program (now integrated within BaseCode) that provides the front-end user interface and manages SCJ user authentication
-- Created July 12 2020
-- Last updated January 24 2021
--=========================

set neverRan to false

property loggedIn : false

on Welcome()
	
	global currentyear
	global currentmonth
	global currentmonthInt
	global sysinfo
	global firstname
	global fullname
	global computername
	global scjissueyear
	global scjvolume
	global runcount
	global compatibilityscriptpath
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
	else if runcountThisMachine is greater than 0 then
		set startButton to "Continue Designing"
	end if
	
	if runcountThisMachine is less than 6 then
		set welcomeMsg2 to return & return & "You can drag the SCJ icon from the folder into the Dock for quick access."
	else if runcountThisMachine is greater than 5 then
		set welcomeMsg2 to ""
	end if
	
	if runcountThisMachine is greater than 100 then
		set welcomeMsg0 to "Wow, your dedication to SCJ is admirable! Maybe it's time to take a break—please make sure you're taking care of yourself first and foremost, "
		set welcomeMsg1 to ". We love what you're doing with Volume "
	end if
	
	set loadCCC to (load script compatibilityscriptpath as alias)
	set adobeCCver to DetermineCompatibility() of loadCCC
	
	set launchButton to button returned of (display alert "Welcome to the Scripps College Journal Extended Visual Design Guide" message welcomeMsg0 & firstname & welcomeMsg1 & scjvolume & ".

Put all art pieces in the ‘Artwork’ folder before placing them on your pages.

The best way to preview your work and assess your pages’ layout is to print them at 100% scale, if you have easy access to a printer.

Be sure to back up your work periodically, either with Time Machine or by dragging key files into Google Drive." & welcomeMsg2 buttons {"About…", "Quit", startButton} default button 3 cancel button "Quit")
	
	if (text of launchButton) is "About…" then
		set backButton to button returned of (display dialog "© Scripps College Journal
For internal use only

Upcoming issue is Spring " & scjissueyear & ", Volume " & scjvolume & deprecatednotice & "

Logged in as " & SCJuser & " on " & computername & "

Adobe CC " & adobeCCver & " " & "installed

App version " & version & "
Design version 2.1" with title "About" buttons {adminButton, "Acknowledgments…", "Back…"} default button "Back…" with icon note) -- can change this to a different icon if we don't want the Construction icon
		if text of backButton is "Back…" then
			Welcome()
		else if text of backButton is "Acknowledgments…" then
			Acknowledgments()
		else if text of backButton is "Log In As Admin…" then
			set authenticateAdmin to (((path to me as text) & "::PasswordProtect3.scpt") as alias) as string -- CHANGE THIS TO REAL THING
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
	set abtn to button returned of (display dialog "SCJ Visual Design System and App created by" & return & "Shay Lari-Hosain" & return & return & "Special thanks to" & return & "Ariel So, Jamie Jiang and Kerry Taylor" & return & return & "SCJ Leaf illustrated by" & return & "Karen Wang" & return & return & "SCJ Flag designed by" & return & "Shay Lari-Hosain" with title "Acknowledgments" buttons {licensebt, privacybt, "Back…"} default button "Back…")
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
			set licenseagreement to (path to me as text) & "::SCJ License Agreement.pdf" as alias -- relocate to Resources path inside app
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
			set privacyinfo to (path to me as text) & "::SCJ Usage Info.pdf" as alias -- relocate to Resources path inside app
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

set computer_fonts to (((path to desktop as text) & "testfonts") as alias) as string -- NEEDS TO CHANGE TO REAL THING
-- REAL PATH IS set computer_fonts to (((path to library folder from user domain as text) & "Fonts") as alias) as string -- tested
-- or (((path to home folder as text) & "Library:Fonts" as alias) as string)

set font_path_POSIX to quoted form of the POSIX path of font_path
set computer_fonts_POSIX to quoted form of the POSIX path of computer_fonts
do shell script "rsync -a " & font_path_POSIX & " " & computer_fonts_POSIX

if runcount is 0 then
	display notification "SCJ fonts were installed on this Mac."
else if runcount is greater than 0 and runcount is less than 6 then
	display notification "SCJ fonts were already detected on this Mac. If any were missing before, we just installed them."
end if

(* Using Finder tell instead of rysnc shell script
with timeout of 600 seconds
	try
		tell application "Finder"
			duplicate every file of folder font_path to folder computer_fonts
		end tell
		display notification "SCJ fonts were installed on this Mac."
	on error errorMessage number errorNumber
		if errorNumber = -15267 then
			display notification "SCJ fonts were already detected on this Mac. If any were missing before, we just installed them."
		end if
	end try
end timeout *)

-- Import Adobe PDF presets
(*
set computer_PDFpresets to (path to home folder) & "Library:Application Support:Adobe:Adobe PDF:Settings" as string as alias
set computer_PDFpresets_POSIX to quoted form of the POSIX path of computer_workspaces
*)

if runcount is 0 then
	rsyncPDFpresets()
	display notification "SCJ PDF export presets for InDesign and Illustrator were installed."
else if runcount is greater than 0 then
	try
		set PDFpresetscheck to (path to home folder) & "Library:Application Support:Adobe:Adobe PDF:Settings:Scripps College Journal.joboptions" as string as alias
	on error -1700
		rsyncPDFpresets()
		display notification "Somehow the SCJ PDF export presets still weren't installed. We just installed them."
	end try
end if

on rsyncPDFpresets()
	(* install PDF presets with rsync *)
end rsyncPDFpresets

-- Import Adobe workspaces



-- Launch SCJ style guides & templates

tell application "Finder"
	set myFolder to assets_path as alias
	set myIDFiles to (every item of myFolder whose name extension is "indd") as alias list
	set myAIFiles to (every item of myFolder whose name extension is "ai") as alias list
	open myIDFiles
	open myAIFiles
end tell

-- Switch to SCJ Adobe workspaces

-- Show each document and explain their purposes if runcount is 0

(*

delay 4

display notification "Front cover template has been opened in Adobe Illustrator." with title "Scripps College Journal" -- maybe get rid of these notifications if it's going to flip to each document and issue an explainer notifications

delay 2

display notification "Magazine design template has been opened in Adobe InDesign." with title "Scripps College Journal"

delay 2

-- Explanation

repeat 3 times
	
	delay 5
	tell application "System Events"
		set activeApp to name of first application process whose frontmost is true
		if "InDesign" is in activeApp then
			display notification ("This is the SCJ magazine template. 8 × 10 inches, 6 pt grid, CMYK.") with title "Adobe InDesign is active"
		else if "Illustrator" is in activeApp then
			display notification ("This is the front cover template. Once it's designed, you'll update it in two locations.") with title "Adobe Illustrator is active"
		end if
	end tell
end repeat *)

-- Clean up

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

--===============================================
-- End SCJ Program
