--=========================
(* PasswordProtect 3.1 *)

-- Info: Handler that can allow user such as senior designer or managing editor to elevate privileges and override SCJ compatibility rules, and possibly other settings in the future. Back-end for WelcomeDialog authentication interface.
-- Created July 31 2020
-- Last updated November 28 2021

---- © 2020–2021 Shay Lari-Hosain. All rights reserved. Unauthorized copying or reproduction of any part of the proprietary contents of this file, via any medium, is strictly prohibited.
--=========================

on run {loggedIn}
	
	if loggedIn is false then set loggedIn to adminApproval(loggedIn, "Enter password:")
	
	return loggedIn
	
end run

on adminApproval(loggedIn, passwordDialog)
	try
		set passwordIcon to "System:Library:PrivateFrameworks:AOSUI.framework:Versions:A:Resources:pref_accounts.icns" as alias
	on error
		set passwordIcon to note
	end try
	set passwordRequest to display dialog passwordDialog buttons {"Back…", "Unlock"} default answer "" default button 2 with title "Senior Designer Settings" with icon passwordIcon with hidden answer
	if button returned of passwordRequest is "Back…" then
		set loggedIn to false
	else if button returned of passwordRequest is "Unlock" then
		if text returned of passwordRequest is "*******" then
			try
				do shell script "afplay /System/Library/PrivateFrameworks/ScreenReader.framework/Versions/A/Resources/Sounds/Announcement.aiff"
			end try
			set loggedIn to true
		else
			try
				do shell script "afplay /System/Library/PrivateFrameworks/ScreenReader.framework/Versions/A/Resources/Sounds/EnterVisibleArea.aiff"
			end try
			set loggedIn to false
			adminApproval(loggedIn, "Incorrect. Try again:")
		end if
	end if
	return loggedIn
end adminApproval
