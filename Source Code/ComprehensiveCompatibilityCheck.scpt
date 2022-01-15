--=========================
(* ComprehensiveCompatibilityCheck 9.0R *)

-- Info: Validates user's computer for any Adobe Creative Cloud or macOS incompatibilities; instructs them in detail how to rectify issues if any exist. The program will keep up-to-date on its own—compatibility rules auto-update until SCJ Vol 27.
-- Created July 17 2020
-- Last updated November 10 2021

---- © 2020–2021 Shay Lari-Hosain. All rights reserved. Unauthorized copying or reproduction of any part of the proprietary contents of this file, via any medium, is strictly prohibited.
--=========================

(* Determine system configuration *)

use scripting additions
use script "PrefsStorageLib" version "1.1.0"

on DetermineCompatibility()
	
	set CCCpass to false
	
	set sysinfo to system info
	set osver to system version of sysinfo
	
	set loadTime to (((path to me as text) & "Contents:Resources:Scripts:SetTimeHandler.scpt") as alias) as string
	set loadTime to (load script loadTime as alias)
	set currentyear to getYear() of loadTime
	set currentmonth to getMonthName() of loadTime
	set currentmonthInt to getMonth() of loadTime
	set currenttime to getTime() of loadTime
	
	set shortname to short user name of sysinfo
	set fullname to long user name of sysinfo
	set firstname to word 1 of fullname
	set computername to computer name of sysinfo
	set macmodel to (do shell script "/usr/sbin/system_profiler SPHardwareDataType | sed -En '/Model Name:/ s/^[^:]+: *//p'")
	set macmodelid to (do shell script "/usr/sbin/system_profiler SPHardwareDataType | sed -En '/Model Identifier:/ s/^[^:]+: *//p'")
	-- set uuid to (do shell script "/usr/sbin/system_profiler SPHardwareDataType | sed -En '/Hardware UUID:/ s/^[^:]+: *//p'")
	set cpuArch to do shell script "uname -m"
	if cpuArch is "arm64" then
		set processorArchReadable to "Apple Silicon 64-bit"
	else if cpuArch is "x86_64" then
		set processorArchReadable to "Intel 64-bit"
	else if cpuArch is "i386" then
		set processorArchReadable to "Intel 32-bit"
	else
		set processorArchReadable to "unknown" -- or missing value
	end if
	
	set scjissueyear to getIssueYear() of loadTime
	set scjvolume to getVolume() of loadTime
	
	if osver starts with "12" then
		set osname to "Monterey"
	else if osver starts with "11" or osver starts with "10.16" then
		set osname to "Big Sur"
		if osver starts with "10.16" then set osver to "11"
	else if osver starts with "10.15" then
		set osname to "Catalina"
	else if osver starts with "10.14" then
		set osname to "Mojave"
	else if osver starts with "10.13" then
		set osname to "High Sierra"
	else if osver starts with "10.12" then
		set osname to "Sierra"
	else if osver starts with "10.11" then
		set osname to "El Capitan"
	else if osver starts with "10.10" then
		set osname to "Yosemite"
	else if osver starts with "10.9" then
		set osname to "Mavericks"
		set osver to "10.09"
	else if osver starts with "10.8" then
		set osname to "Mountain Lion"
		set osver to "10.08"
	else if osver starts with "10.7" then
		set osname to "Lion"
		set osver to "10.07"
	else if osver starts with "10.6" then
		set osname to "Snow Leopard"
		set osver to "10.06"
	end if
	if osver is greater than or equal to "10.12" then
		set osfamily to "macOS"
	else if osver is greater than or equal to "10.08" and osver is less than "10.12" then
		set osfamily to "OS X"
	else if osver is less than "10.08" then
		set osfamily to "Mac OS X"
	end if
	if osver is greater than or equal to "10.10" then
		set osverdisplay to osver
	else if osver is less than "10.10" then
		set osverdisplay to system version of sysinfo
	end if
	if osver is greater than or equal to "13" then
		set osname to osver
	end if
	
	(* Get InDesign & Illustrator installation status and versions *)
	
	try
		tell application "Finder" to get application id "com.adobe.InDesign"
		set IDexists to true
	on error
		set IDexists to false
	end try
	try
		tell application "Finder" to get application id "com.adobe.Illustrator"
		set AIexists to true
	on error
		set AIexists to false
	end try
	
	if AIexists = true and IDexists = true then
		set part1beginning to "You have old versions of InDesign and Illustrator. Update to the versions the rest of your team uses, so you can open their design work."
		tell application "Finder" to get version of application id "com.adobe.Illustrator"
		set AIver to text 1 thru 2 of result
		tell application "Finder" to get version of application id "com.adobe.InDesign"
		set IDver to text 1 thru 2 of result
		tell application "Finder" to get version of application id "com.adobe.InDesign"
		set IDverFull to text 1 thru 4 of result
	else if AIexists = false and IDexists = false then
		set part1beginning to "Before installing InDesign and Illustrator, update " & osfamily & ". Otherwise, you can only install old Adobe software, which can't open design work the rest of your team creates."
	else if AIexists = true and IDexists = false then
		set part1beginning to "Before installing InDesign and updating Illustrator, update " & osfamily & "."
		tell application "Finder" to get version of application id "com.adobe.Illustrator"
		set AIver to text 1 thru 2 of result
	else if AIexists = false and IDexists = true then
		set part1beginning to "Before installing Illustrator and updating InDesign, update " & osfamily & "."
		tell application "Finder" to get version of application id "com.adobe.InDesign"
		set IDver to text 1 thru 2 of result
		tell application "Finder" to get version of application id "com.adobe.InDesign"
		set IDverFull to text 1 thru 4 of result
	end if
	
	set x to (scjissueyear - 2021)
	set projectedminAIver to 24 + x
	set projectedminIDver to 15 + x
	-- Exception for first year of deployment
	if scjissueyear is equal to 2021 then
		set projectedminAIver to 25
		set projectedminIDver to 16
		set x to 1
	end if
	
	try
		set a to (24 - AIver)
	end try
	try
		set i to (15 - IDver)
	end try
	try
		if a is greater than 4 then
			set a to (a - 1)
		end if
		if a is i then
			set adobeCCver to (2020 - a)
			set CCfamily to "CC "
			if a is greater than or equal to 4 then
				set adobeCCver to (2019 - a)
				if a is greater than 6 then --- enable support for detecting individual Adobe CS versions
					set d to (a - 7)
					set CSver to (6 - d)
					set adobeCCver to "CS" & CSver
					if CSver is less than 1 then
						set adobeCCver to "legacy software from 2001 or earlier"
					end if
					set CCfamily to ""
				end if
			end if
		else if a is not i then -- remove this 'if' block if it causes problems
			set adobeCCver to "has mismatched versions"
		end if
	end try
	set b to (24 - projectedminAIver)
	set projectedadobeCCver to (2020 - b)
	if scjissueyear is less than or equal to 2021 then
		set projectedadobeCCver to 2021
	end if
	
	(* Determine compatible macOS*)
	
	set f to (x / 100)
	if x is greater than 2 then
		set compatibleos to 8 + x
	else
		set compatibleos to 10.13 + f as string
	end if
	-- Stop compatiblity checks in 2026
	if compatibleos is greater than 13 then
		set compatibleos to 13
	end if
	
	(* Compatibility guide
	10.13 	-- release date 2017, supported until late 2020, MacBook/iMac 2010/09, min require CC 2020	-- SCJ Vol 21 		SP'20
	10.14 	-- release date 2018, supported until late 2021, MacBook/iMac 2012, min require CC 2021 	-- SCJ Vol 22, 23	SP'21,'22
	10.15 	-- release date 2019, supported until late 2022, MacBook/iMac 2012, min require CC 2022 	-- SCJ Vol 24		SP'23
	11   	-- release date 2020, supported until late 2023, MacBook/iMac 2013/14, min require CC 2023 	-- SCJ Vol 25		SP'24
	12   	-- release date 2021, supported until late 2024, MacBook/iMac 2015, min require CC 2024 	-- SCJ Vol 26		SP'25
	13   	-- release date 2022, supported until late 2025, min require CC 2025 							-- SCJ Vol 27		SP'26
							-- Steele lab computers as of 2020: iMac Late 2015
	*)
	
	if compatibleos is "10.14" then
		set compatibleosname to "Mojave"
	else if compatibleos is "10.15" then
		set compatibleosname to "Catalina"
	else if compatibleos is "11" then
		set compatibleosname to "Big Sur"
	else if compatibleos is "12" then
		set compatibleosname to "Monterey"
	else if compatibleos is greater than or equal to "13" then
		set compatibleosname to compatibleos
	end if
	
	(* Alert text *)
	
	set part1 to part1beginning & return & return & "You'll have to update this " & macmodel & "'s software. We're sorry. Your version, "
	
	set part2 to ", is too old to run newer Adobe software." & return & return & "Once you've done that, open Scripps College Journal again."
	
	set addinfo to "Newer Adobe software requires macOS " & compatibleos & " or later. You have " & osfamily & " " & osverdisplay & "." & return & return & "You can update " & osfamily & " for free. Please back up your files before doing so." & return & return & "SCJ typically uses the latest version of Adobe CC or one year behind it, depending on Scripps IT's schedule." & return & return & "If you're not sure, just ask your senior designer. They're here to help."
	
	-- set ITSphonetext to "You can call Scripps IT at (909) 607-3406"
	
	(* Check macOS compatibility *)
	
	try
		set alertheader to "Update your Mac first. " & osfamily & " " & osname & " is too old to run newer Adobe apps."
		set alertmessage to part1 & osname & part2
	on error errorMessage number errorNumber
		if errorNumber = -2753 then
			set alertheader to "Update your Mac first. " & osfamily & " " & osver & " is too old to run newer Adobe apps."
			set alertmessage to part1 & osverdisplay & part2
		end if
	end try
	
	set cccNotifIcon to "⚠️"
	
	if osver is less than compatibleos then
		
		beep
		try
			set compatIcon to "System:Library:CoreServices:CoreTypes.bundle:Contents:Resources:ToolbarCustomizeIcon.icns" as alias
			-- set cccNotifIcon to "🛠"
		on error
			-- set cccNotifIcon to "⚙️"
			try
				set compatIcon to "System:Library:CoreServices:CoreTypes.bundle:Contents:Resources:ToolbarAdvanced.icns" as alias
			on error
				-- set cccNotifIcon to "⚠️"
				set compatIcon to caution
			end try
		end try
		display notification "macOS needs to be updated" with title "Compatibility " & cccNotifIcon
		set thisButton to button returned of (display alert alertheader message alertmessage buttons {"Additional Info…", "Quit"} as critical)
		if thisButton is "Additional Info…" then
			--- display notification ITSphonetext with title "Compatibility"
			if AIexists is true and IDexists is true then
				set addButtonSelection to {"Quit", "Override…", "Software Update…"}
			else
				set addButtonSelection to {"Quit", "About This Mac…", "Software Update…"}
			end if
			set addButton to button returned of (display dialog addinfo buttons addButtonSelection default button "Software Update…" with title "Compatibility Info" with icon compatIcon)
			if addButton is "About This Mac…" then
				tell application "Finder" to open POSIX file "/System/Library/CoreServices/Applications/About This Mac.app"
			else if addButton is "Override…" then
				set CCCpass to overrideCCC()
				if CCCpass is true then
					return {adobeCCver, IDver, AIver, osver, shortname, fullname, firstname, computername, macmodel, macmodelid, osname, IDverFull, CCCpass, projectedadobeCCver, cpuArch, processorArchReadable}
					error number -128
				else
					DetermineCompatibility()
				end if
			else if addButton is "Software Update…" then
				try
					tell application "Finder" to open POSIX file "/System/Library/CoreServices/Software Update.app"
				on error
					if osver is greater than or equal to 10.14 then
						tell application "System Preferences"
							activate
							set the current pane to pane id "com.apple.preferences.softwareupdate"
						end tell
					else if osver is less than 10.14 then
						tell application "App Store"
							activate
						end tell
					end if
				end try
			end if
		end if
		tell application id "edu.scrippsjournal.design" to quit
	end if
	
	(* Check Adobe compatibility *)
	
	set adobecheckhead to "Update your Adobe software first."
	set adobecheckmsg to " installed. Update to the version the design team uses, so that you'll be able to open their work. 
	
You need CC " & projectedadobeCCver & ". Ask the senior designer to confirm. It's usually the latest version or one year behind, depending on what Scripps IT's using this year."
	set missingadobemsg to "We'll be using InDesign & Illustrator." & return & return & "Pick the version the design team uses, so that they'll be able to open your work. Most likely, it's CC " & projectedadobeCCver & "."
	set adobe2021covidmsg to return & return & "Scripps College provides students access to Adobe software." -- edit to add "use school email" once testing downloading the app and then trying to log into a school account
	set missingadobemsg to missingadobemsg & adobe2021covidmsg
	
	-- try (Getting rid of this try block, because it would render all the Quit buttons inside this code useless)
	if osver is greater than or equal to compatibleos then
		if AIexists is false and IDexists is false then
			set adobeButton to button returned of (display alert "Install Adobe Creative Cloud first." message missingadobemsg buttons {"Quit", "Get Adobe Software…"} default button 2 as critical)
			if adobeButton is "Get Adobe Software…" then
				open location "https://creativecloud.adobe.com/apps/download/creative-cloud"
				display notification "Downloading the Adobe Creative Cloud installer" with title "Compatibility"
				delay 20
				display notification "Once you install Creative Cloud, sign in with your Scripps credentials." with title "If you don't have access to a subscription"
			end if
			tell application id "edu.scrippsjournal.design" to quit
		else
			if IDexists is true and AIexists is false then
				set adobeSpecificHeader to "Install Adobe Illustrator first."
				set adobeSpecificMsg to missingadobemsg
				set updateButton to {"Quit", "Get Illustrator…"}
				set defButton to 2
				set p to i
				set compatibilityNotif to "Get Illustrator"
				set adobeIssue to true
			else if AIexists is true and IDexists is false then
				set adobeSpecificHeader to "Install Adobe InDesign first."
				set adobeSpecificMsg to missingadobemsg
				set updateButton to {"Quit", "Get InDesign…"}
				set defButton to 2
				set p to a
				set compatibilityNotif to "Get InDesign"
				set adobeIssue to true
			else if IDver is less than projectedminIDver and AIver is less than projectedminAIver then
				if a is i then
					set adobecheckmsg1 to "You have Adobe " & CCfamily & adobeCCver
				else if a is not i then
					set adobecheckmsg1 to "You have old versions of InDesign & Illustrator"
				end if
				set adobeSpecificHeader to adobecheckhead
				set adobeSpecificMsg to adobecheckmsg1 & adobecheckmsg
				set updateButton to {"Quit", "Override…", "Update…"}
				set defButton to 3
				set p to i
				set compatibilityNotif to "InDesign & Illustrator need to be updated"
				set adobeIssue to true
			else if IDver is greater than or equal to projectedminIDver and AIver is not greater than or equal to projectedminAIver then
				set adobeSpecificHeader to adobecheckhead
				set adobeSpecificMsg to "You have an old version of Illustrator" & adobecheckmsg
				set updateButton to {"Quit", "Override…", "Update Illustrator…"}
				set defButton to 3
				set p to a
				set compatibilityNotif to "Illustrator needs to be updated"
				set adobeIssue to true
			else if AIver is greater than or equal to projectedminAIver and IDver is not greater than or equal to projectedminIDver then
				set adobeSpecificHeader to adobecheckhead
				set adobeSpecificMsg to "You have an old version of InDesign" & adobecheckmsg
				set updateButton to {"Quit", "Override…", "Update InDesign…"}
				set defButton to 3
				set p to i
				set compatibilityNotif to "InDesign needs to be updated"
				set adobeIssue to true
			else
				set adobeIssue to false
			end if
			if adobeIssue is true then
				display notification compatibilityNotif with title "Compatibility " & cccNotifIcon
				set adobeButton to button returned of (display alert adobeSpecificHeader message adobeSpecificMsg buttons updateButton default button defButton as critical)
				if adobeButton contains "Update" or adobeButton contains "Get" then
					OpenCCManager(p)
					tell application id "edu.scrippsjournal.design" to quit
				else if adobeButton is "Override…" then
					overrideCCC()
				else if adobeButton is "Quit" then
					tell application id "edu.scrippsjournal.design" to quit
				end if
			end if
		end if
	end if
	
	(* if a is i and AIver is greater than projectedminAIver then
	display alert "You have a newer version of Adobe software than we expected you to!" message "Consult with your team to make sure they're on the same version as you. If they have an older version, they won't be able to open your files."
end if
*)
	
	set CCCpass to true
	
	return {adobeCCver, IDver, AIver, osver, shortname, fullname, firstname, computername, macmodel, macmodelid, osname, IDverFull, CCCpass, projectedadobeCCver, cpuArch, processorArchReadable}
end DetermineCompatibility

DetermineCompatibility()

on OpenCCManager(x)
	if x is less than 7 then
		try
			-- tell application "Creative Cloud" to activate -- when CCC fails and app is quit, app incorrectly prompts asking about how to locate Creative Cloud. Solution below
			set runAdobe to (((path to me as text) & "Contents:Resources:Scripts:CreativeCloudLaunch.scpt") as alias)
			run script runAdobe
		on error
			set aupdatebutton to button returned of (display alert "Sorry, we weren't able to open the Adobe updater." message "You'll have to open it yourself." buttons {"Quit"} default button "Quit")
			-- display notification "Sorry, somehow we couldn't open the Adobe updater. You'll have to do it yourself."
		end try
	else if x is greater than 6 then
		set CSbutton to button returned of (display alert "Sorry, you have Adobe Creative Suite, which is legacy Adobe software." message "You'll need to uninstall it and download Adobe Creative Cloud." buttons {"Quit", "Get Creative Cloud…"} default button 2 as critical)
		if CSbutton is "Get Creative Cloud…" then
			open location "https://creativecloud.adobe.com/apps/download/creative-cloud"
			display notification "Downloading the Adobe Creative Cloud installer" with title "Compatibility"
		end if
	end if
	tell application id "edu.scrippsjournal.design" to quit
end OpenCCManager

on overrideCCC()
	global CCCpass
	global loggedIn
	prepare storage for (path to me) -- default values {loggedIn:false}
	set loggedIn to value for key "loggedIn"
	if loggedIn is false then
		set authenticateAdmin to (((path to me as text) & "Contents:Resources:Scripts:PasswordProtect3.scpt") as alias) as string
		set loggedIn to (run script (file authenticateAdmin) with parameters (loggedIn))
		if loggedIn is false then
			DetermineCompatibility()
		else
			set CCCpass to true
		end if
		assign value loggedIn to key "loggedIn"
	else
		set CCCpass to true
	end if
	return CCCpass
end overrideCCC
