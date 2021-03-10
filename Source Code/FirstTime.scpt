--=========================
(* First-time Setup 1.4.4 *)

-- Info: Will only show when app is run for the first time to prepare the user for UAC system prompts.
-- Created September 26 2020
-- Last updated February 12 2021

---- © 2020–2021 Shay Lari-Hosain. All rights reserved. Unauthorized copying or reproduction of any part of the proprietary contents of this file, via any medium, is strictly prohibited.
--=========================

property LAagreed : false

set licenseagreement to (path to me as text) & "::SCJ License Agreement.pdf" as alias -- relocate to Resources path inside app
global licenseagreement

display alert "Welcome. ☺️ 🎉

You'll be up and running in no time." buttons {""} giving up after 5

-- Could introduce custom icon to validate authenticity

-- Initialize()

on Initialize()
	set initialOptions to {"License Agreement…", "Got It"}
	set initialButton to button returned of (display dialog "Your Mac will ask you if Scripps College Journal can access various things, like Finder, System, InDesign and Preview. Please click OK whenever that happens." & return buttons initialOptions default button "Got It" with title "Initial Setup" with icon ":Users:Shay:Documents:University:Scripps College Journal:SCJ Complete Visual Design System:ICNS Not Final:Flag MacGeneric.icns" as alias)
	if initialButton is "License Agreement…" then
		set initialOptions to {"Quit", "Got It"} --- Consider Tutorial in future
		DisplayLA()
	end if
	if initialButton is "Got It" then
		set LAagreed to true
		tell application "Preview" to close (every window whose name contains "SCJ License Agreement")
	end if
	if initialButton is "Quit" then
		set LAagreed to false
		tell application "Preview" to close (every window whose name contains "SCJ License Agreement")
		--- display alert "Please uninstall Scripps College Journal from your system." message "The app will quit." buttons {"Quit"} default button 1 giving up after 4
		error number -128
	end if
end Initialize

on DisplayLA()
	tell application "Preview" to open file licenseagreement
	Initialize()
end DisplayLA

-- INACTIVE CODE BELOW

-- display dialog "Apple will ask if it's okay for SCJ to use System Events. Click ‘Allow’ each time." with title "Set Up Scripps College Journal" buttons {"OK"} default button 1
(*
set positionsList to choose from list {"Staff", "Managing editor"} with title "Initial Setup" with prompt "Select your position on Scripps College Journal." OK button name {"Authenticate…"} cancel button name {"Quit"}
return positionsList
if positionsList is {"Managing editor"} then
	set loggedIn to false
	set authenticateAdmin to (((path to me as text) & "::PasswordProtect3.scpt") as alias) as string
	set loggedIn to (run script (file authenticateAdmin) with parameters (loggedIn))
	if loggedIn is true then
		display notification "Welcome back, SCJ Senior Designer."
	end if
else if positionsList is false then
	error number -128
end if
*)

(* if (selection as string) is "Managing editor)" then
		adminApproval()
	end if *)
