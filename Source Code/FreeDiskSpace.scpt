--=========================
(* FreeDiskSpace 2.0 *)

-- Info: Checks that the startup disk has enough free space to run SCJ.
-- Created July 20 2020
-- Last updated June 28 2021

---- © 2020–2021 Shay Lari-Hosain. All rights reserved. Unauthorized copying or reproduction of any part of the proprietary contents of this file, via any medium, is strictly prohibited.
--=========================

DetermineDisk(false, true)

on DetermineDisk(alreadyLaunched, showUI)
	
	set osver to do shell script "sw_vers -productVersion"
	
	tell application "System Events"
		set PhotoshopIsRunning to ((bundle identifier of processes) ¬
			contains "com.adobe.Photoshop")
	end tell
	
	tell application "Finder"
		set percent_free to ¬
			(((the free space of the startup disk) / (the capacity of the startup disk)) * 100) div 1
		set percent_used to (100 - percent_free)
		set free_space to (the free space of the startup disk)
	end tell
	
	set free_space_GB to ((free_space / 1.0E+7) * 0.01)
	set free_space_GB_round to (round (free_space_GB))
	set free_space_GB_round_dec to (round (free_space / 1.0E+7)) * 0.01
	
	if free_space_GB is less than 1.8 then
		set diskAlertHeader to "You might end up running out of space as you work on the magazine."
	end if
	if free_space_GB is less than 0.4 then
		set diskAlertHeader to "You might not have enough room for the issue's artwork."
	end if
	
	if PhotoshopIsRunning then
		set PSmsg to return & return & "However, quit Photoshop and you might save space, especially if you've opened large files in it for multiple days."
	else
		set PSmsg to ""
	end if
	
	set diskAlertMsg to "Your Mac is " & the percent_used & " percent full. You have " & free_space_GB_round_dec & " GB free." & PSmsg
	
	if free_space_GB is less than 1.8 and showUI is true then
		if alreadyLaunched is false then
			try
				do shell script "afplay /System/Library/PrivateFrameworks/ScreenReader.framework/Versions/A/Resources/Sounds/BrailleChordMemorize.aiff"
				--- other option EnterInvisibleArea
			on error
				beep
			end try
		end if
		if osver is greater than or equal to "10.12" then
			set diskButtonOptions to {"Quit", "Manage Storage…", "Continue"}
		else if osver is less than "10.12" then
			set diskButtonOptions to {"Quit", "Continue"}
		end if
		set diskButton to button returned of (display alert diskAlertHeader message diskAlertMsg buttons diskButtonOptions default button "Continue" as critical)
		if diskButton is "Manage Storage…" then
			tell application "Finder" to open POSIX file "/System/Library/CoreServices/Applications/Storage Management.app"
			DetermineDisk(true, true)
		else if diskButton is "Quit" then
			tell application id "edu.scrippsjournal.design" to quit
		end if
	end if
	
	return free_space_GB_round as string
	
end DetermineDisk
