--=========================
(* ComprehensiveCompatibilityCheck 8.0.1R *)

-- Info: Validates user's computer for any Adobe Creative Cloud or macOS incompatibilities; instructs them in detail how to rectify issues if any exist. The program will keep up-to-date on its own—compatibility rules auto-update until SCJ Vol 27.
-- Created July 17 2020
-- Last updated June 3 2021

---- © 2020–2021 Shay Lari-Hosain. All rights reserved. Unauthorized copying or reproduction of any part of the proprietary contents of this file, via any medium, is strictly prohibited.
--=========================

(* Determine system configuration *)


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
	set uuid to (do shell script "/usr/sbin/system_profiler SPHardwareDataType | sed -En '/Hardware UUID:/ s/^[^:]+: *//p'")
	
	set scjissueyear to getIssueYear() of loadTime
	set scjvolume to getVolume() of loadTime
	
	if osver starts with "11" then
		set osname to "Big Sur"
	end if
	if osver starts with "10.16" then
		set osname to "Big Sur"
		set osver to "11"
	end if
	if osver starts with "10.15" then
		set osname to "Catalina"
	end if
	if osver starts with "10.14" then
		set osname to "Mojave"
	end if
	if osver starts with "10.13" then
		set osname to "High Sierra"
	end if
	if osver starts with "10.12" then
		set osname to "Sierra"
	end if
	if osver starts with "10.11" then
		set osname to "El Capitan"
		set osfamily to "OS X"
	end if
	if osver starts with "10.10" then
		set osname to "Yosemite"
		set osfamily to "OS X"
	end if
	if osver starts with "10.9" then
		set osname to "Mavericks"
		set osfamily to "OS X"
		set osver to "10.09"
		set osverdisplay to "10.9"
	end if
	if osver starts with "10.8" then
		set osname to "Mountain Lion"
		set osfamily to "OS X"
		set osver to "10.08"
		set osverdisplay to "10.8"
	end if
	if osver starts with "10.7" then
		set osname to "Lion"
		set osfamily to "Mac OS X"
		set osver to "10.07"
		set osverdisplay to "10.7"
	end if
	if osver starts with "10.6" then
		set osname to "Snow Leopard"
		set osfamily to "Mac OS X"
		set osver to "10.06"
		set osverdisplay to "10.6"
	end if
	if osver is greater than or equal to "10.12" then
		set osfamily to "macOS"
	end if
	if osver is greater than or equal to "10.10" then
		set osverdisplay to osver
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
	set compatibleos to 10.13 + f as string
	if x is greater than 2 then
		-- incremental macOS naming scheme
		(* set x to x - 4
		set f to (x / 10)
		set compatibleos to 11.1 + f as string *)
		-- consecutive macOS naming scheme
		set compatibleos to 8 + x
	end if
	-- Stop compatiblity checks in 2026
	if compatibleos is greater than 13 then
		set compatibleos to 13
	end if
	
	(* Compatibility guide
	10.13 	-- release date 2017, supported until late 2020, MacBook/iMac 2010/09, min require CC 2020	-- SCJ Vol 21 		SP'20
	10.14 	-- release date 2018, supported until late 2021, MacBook/iMac 2012, min require CC 2021 		-- SCJ Vol 22, 23	SP'21,'22
	10.15 	-- release date 2019, supported until late 2022, MacBook/iMac 2012, min require CC 2022 		-- SCJ Vol 24		SP'23
	11.0   	-- release date 2020, supported until late 2023, MacBook/iMac 2013/14, min require CC 2023 	-- SCJ Vol 25		SP'24
	11.1/12   -- release date 2021, supported until late 2024, MacBook/iMac 2013/14, min require CC 2024 	-- SCJ Vol 26		SP'25
	11.2/13   -- release date 2022, supported until late 2025, min require CC 2025 						-- SCJ Vol 27		SP'26
							-- Steele lab computers as of 2020: iMac Late 2015
	*)
	
	if compatibleos is "10.14" then
		set compatibleosname to "Mojave"
	else if compatibleos is "10.15" then
		set compatibleosname to "Catalina"
	else if compatibleos is "11" then
		set compatibleosname to "Big Sur"
	else if compatibleos is greater than or equal to "12" then
		set compatibleosname to compatibleos
	end if
	
	(* Alert text *)
	
	set part1 to part1beginning & "
		
You'll have to update this " & macmodel & "'s software. We're sorry. Your version, "
	
	set part2 to ", is too old to run newer Adobe software.

Once you've done that, run Scripps College Journal again."
	
	set addinfo to "Newer Adobe software requires macOS" & " " & compatibleos & " or later. You have " & osfamily & " " & osverdisplay & ".

You can update " & osfamily & " for free. Please back up your files before doing so.

SCJ typically uses the latest version of Adobe CC or one year behind it, depending on what Scripps IT's schedule.

If you're not sure, just ask your senior designer. They're here to help."
	
	set ITSphonetext to "You can call Scripps IT at +1 909 607 3406"
	
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
	
	if osver is less than compatibleos then
		
		beep
		try
			set compatIcon to "System:Library:CoreServices:CoreTypes.bundle:Contents:Resources:ToolbarCustomizeIcon.icns" as alias
		on error
			set compatIcon to caution
		end try
		set thisButton to button returned of (display alert alertheader message alertmessage buttons {"Additional Info…", "Quit"} as critical)
		if thisButton is "Additional Info…" then
			--- display notification ITSphonetext
			set addButton to button returned of (display dialog addinfo buttons {"About This Mac…", "Software Update…", "Quit"} default button "Quit" with title "Compatibility Info" with icon compatIcon)
			if addButton is "About This Mac…" then
				tell application "Finder" to open POSIX file "/System/Library/CoreServices/Applications/About This Mac.app"
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
	set adobe2021covidmsg to return & return & "Scripps College is providing free access to Adobe software while campus is closed." -- edit to add "use school email" once testing downloading the app and then trying to log into a school account
	if scjissueyear is 2021 then set missingadobemsg to missingadobemsg & adobe2021covidmsg
	
	-- try (Getting rid of this try block, because it would render all the Quit buttons inside this code useless)
	if osver is greater than or equal to compatibleos then
		if AIexists is false and IDexists is false then
			set adobeButton to button returned of (display alert "Install Adobe Creative Cloud first." message missingadobemsg buttons {"Quit", "Get Adobe Software…"} default button 2 as critical)
			if adobeButton is "Get Adobe Software…" then
				open location "https://creativecloud.adobe.com/apps/download/creative-cloud"
				display notification "Downloading the Adobe Creative Cloud installer"
				delay 20
				display notification "Once you install Creative Cloud, sign in with your Scripps credentials." with title "If you don't have access to a subscription"
			end if
			tell application id "edu.scrippsjournal.design" to quit
		else if IDexists is true and AIexists is false then
			set adobeButton to button returned of (display alert "Install Adobe Illustrator first." message missingadobemsg buttons {"Quit", "Get Illustrator…"} default button 2 as critical)
			if adobeButton is "Get Illustrator…" then
				OpenCCManager(i)
			end if
			tell application id "edu.scrippsjournal.design" to quit
		else if AIexists is true and IDexists is false then
			set adobeButton to button returned of (display alert "Install Adobe InDesign first." message missingadobemsg buttons {"Quit", "Get InDesign…"} default button 2 as critical)
			if adobeButton is "Get InDesign…" then
				OpenCCManager(a)
			end if
			tell application id "edu.scrippsjournal.design" to quit
		else if IDver is less than projectedminIDver and AIver is less than projectedminAIver then
			if a is i then
				set adobecheckmsg1 to "You have Adobe " & CCfamily & adobeCCver
			else if a is not i then
				set adobecheckmsg1 to "You have old versions of InDesign & Illustrator"
			end if
			set adobeButton to button returned of (display alert adobecheckhead message adobecheckmsg1 & adobecheckmsg buttons {"Quit", "Update…"} default button 2 as critical)
			if adobeButton is "Update…" then
				OpenCCManager(i)
			end if
			tell application id "edu.scrippsjournal.design" to quit
		else if IDver is greater than or equal to projectedminIDver and AIver is not greater than or equal to projectedminAIver then
			set adobeButton to button returned of (display alert adobecheckhead message "You have an old version of Illustrator" & adobecheckmsg buttons {"Quit", "Update Illustrator…"} default button 2 as critical)
			if adobeButton is "Update Illustrator…" then
				OpenCCManager(a)
			end if
			tell application id "edu.scrippsjournal.design" to quit
		else if AIver is greater than or equal to projectedminAIver and IDver is not greater than or equal to projectedminIDver then
			set adobeButton to button returned of (display alert adobecheckhead message "You have an old version of InDesign" & adobecheckmsg buttons {"Quit", "Update InDesign…"} default button 2 as critical)
			if adobeButton is "Update InDesign…" then
				OpenCCManager(i)
			end if
			tell application id "edu.scrippsjournal.design" to quit
		end if
	end if
	
	(* if a is i and AIver is greater than projectedminAIver then
	display alert "You have a newer version of Adobe software than we expected you to!" message "Consult with your team to make sure they're on the same version as you. If they have an older version, they won't be able to open your files."
end if
*)
	
	set CCCpass to true
	
	return {adobeCCver, IDver, AIver, osver, shortname, fullname, firstname, computername, macmodel, macmodelid, uuid, osname, IDverFull, CCCpass, projectedadobeCCver}
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
			-- display notification "Sorry, somehow we couldn't open the Adobe updater. You'll have to do it yourself." with title "Scripps College Journal"
		end try
	else if x is greater than 6 then
		set CSbutton to button returned of (display alert "Sorry, you have Adobe Creative Suite, which is legacy Adobe software." message "You'll need to uninstall it and download Adobe Creative Cloud." buttons {"Quit", "Get Creative Cloud…"} default button 2 as critical)
		if CSbutton is "Get Creative Cloud…" then
			open location "https://creativecloud.adobe.com/apps/download/creative-cloud"
			display notification "Downloading the Adobe Creative Cloud installer"
		end if
	end if
	tell application id "edu.scrippsjournal.design" to quit
end OpenCCManager
