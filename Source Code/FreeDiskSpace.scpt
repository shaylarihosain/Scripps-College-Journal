--=========================
(* FreeDiskSpace 1.6 *)

-- Info: Checks that the startup disk has enough free space to run SCJ.
-- Created July 20 2020
-- Last updated January 30 2021

---- © 2020–2021 Shay Lari-Hosain. All rights reserved. Unauthorized copying or reproduction of any part of the proprietary contents of this file, via any medium, is strictly prohibited.
--=========================

DetermineDisk()

on DetermineDisk()
	
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
	set free_space_GB_round to (round (free_space / 1.0E+7) * 0.01)
	
	if free_space_GB is less than 1.8 then
		set diskalertheader to "You might end up running out of space as you work on the magazine."
	end if
	if free_space_GB is less than 0.4 then
		set diskalertheader to "You might not have enough room for the issue's artwork." -- removed "on this computer" for length
	end if
	
	
	if PhotoshopIsRunning then
		set diskalertmsg to "The startup drive is " & the percent_used & ¬
			" percent full." & return & return & ¬
			"However, quit Photoshop and you might save space, especially if you've opened large files in it for multiple days."
	else
		set diskalertmsg to "The startup drive is " & the percent_used & ¬
			" percent full."
	end if
	
	if free_space_GB is less than 1.8 then
		try
			do shell script "afplay /System/Library/PrivateFrameworks/ScreenReader.framework/Versions/A/Resources/Sounds/BrailleChordMemorize.aiff"
			--- other option EnterInvisibleArea
		on error
			beep
		end try
		if osver is greater than or equal to "10.12" then
			set diskbuttonoptions to {"Cancel", "Manage Storage…", "Continue"}
		else if osver is less than "10.12" then
			set diskbuttonoptions to {"Cancel", "Continue"}
		end if
		set diskButton to button returned of (display alert diskalertheader message diskalertmsg buttons diskbuttonoptions cancel button "Cancel" default button "Continue" as critical)
		if diskButton is "Manage Storage…" then
			tell application "Finder" to open POSIX file "/System/Library/CoreServices/Applications/Storage Management.app"
		end if
	end if
	
	set freespaceGB to free_space_GB_round as string
	return freespaceGB
	
end DetermineDisk
