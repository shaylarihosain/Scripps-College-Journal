--===============================================
-- SCRIPPS COLLEGE JOURNAL Software Version 1.0 for Mac, tested and compiled on macOS 10.15.7 (19H15) (Intel-based)
-- Intel x86 binary
-- Last updated 						November 9 2020
-- First released staffwide 				February 2021
-- Beta entered limited staff testing 		December 2020
-- Development began 					July 2020
-- Originally packaged with SCJ Visual Design System Version 2.1 for Volume 22
-- © 2020–2021 Shay Lari-Hosain. All rights reserved. Scripps College and The Claremont Colleges do not own any portion of this software. This installer and design system are student-created. The author is not responsible for any modifications, or the consequences of modifications, that are made to this software by others.
--===============================================

-- SCJ (Replace with code from elswhere, this is for debugging)

set compatibilityscriptpath to (((path to me as text) & "::ComprehensiveCompatibilityCheck.scpt") as alias) as string -- CHANGE TO PATH TO RESOURCE
run script file compatibilityscriptpath
-- Maybe put compatibility and disk check in their own handlers so that you can decide to call them or not call them depending on last status
-- Remember to call each variable as global also

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

-- SCJ Issue

if currentmonthInt is less than 6 then
	set scjissueyear to currentyear
else if currentmonthInt is greater than 5 then
	set scjissueyear to currentyear + 1
end if

set scjvolume to (scjissueyear - 1999)
