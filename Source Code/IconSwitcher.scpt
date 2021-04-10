--=========================
(* IconSwitcher 1.0.1 *)

-- Info: Switches app icon dynamically to match design of user's macOS. Different versions of macOS sport various icon styles, which we'd like the app to conform to. 
-- This portion of the SCJ software will become obsolete and nonfunctional in macOS 11+ on arm_v64, and will be deprecated or removed entirely when SCJ is reworked to introduce native support for Apple M chips.
-- Created August 25 2020
-- Last updated February 22 2021

---- Copyright © 2020–2021 Shay Lari-Hosain. All rights reserved. Unauthorized copying or reproduction of any part of the proprietary contents of this file, via any medium, is strictly prohibited.
--=========================

property lastOS : missing value

set osver to system version of (system info)

if osver is greater than or equal to "10.16" then
	set filename to "SCJBigSur.icns"
else if osver starts with "10.15" then
	set filename to "SCJCatalina.icns"
else if osver is less than "10.15" then
	set filename to "SCJMojave.icns"
	-- else if osver is less than "10.10" then
	-- set filename to "SCJMavericks.icns"
end if

if lastOS is not osver then
	
	set resourcePath to ((path to me) as text) & "::Resources" as text
	set availableIconsPath to resourcePath & ":" & filename as text
	set iconPath to resourcePath & ":" & "SCJ.icns" as text
	
	do shell script "rm " & quoted form of (POSIX path of iconPath)
	do shell script "cp " & quoted form of (POSIX path of availableIconsPath) & " " & quoted form of (POSIX path of iconPath)
	
end if

set lastOS to osver
