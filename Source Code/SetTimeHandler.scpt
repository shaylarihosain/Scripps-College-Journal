--=========================
(* SetTimeHandler 2.0) *)

-- Info: Relocates older code for time-setting present in all programs into global/centralized handler that can be accessed by all programs
-- Created January 30 2021
-- Last updated September 23 2021

---- © 2020–2021 Shay Lari-Hosain. All rights reserved. Unauthorized copying or reproduction of any part of the proprietary contents of this file, via any medium, is strictly prohibited.
--=========================


on getYear()
	set currentyear to (year of (current date) as integer)
	return currentyear
end getYear

on getMonth()
	set currentmonthint to month of (current date) as integer
	return currentmonthint
end getMonth

on getMonthName()
	set currentmonth to (month of (current date) as string)
	return currentmonth
end getMonthName

on getTime()
	set currenttime to (time string of (current date))
	return currenttime
end getTime

on getIssueYear()
	set currentyear to getYear()
	set currentmonthint to getMonth()
	set incrementMonth to item 1 of adjustSchedule()
	if currentmonthint is less than incrementMonth then
		set scjIssueYear to currentyear
	else if currentmonthint is greater than (incrementMonth - 1) then
		set scjIssueYear to currentyear + 1
	end if
	return scjIssueYear
end getIssueYear

on getVolume()
	set delayVolume to item 2 of adjustSchedule()
	set scjIssueYear to getIssueYear()
	set scjVolume to (scjIssueYear - 1999)
	if delayVolume is not 0 or delayVolume is not "" then set scjVolume to (scjVolume - delayVolume) as integer
	return scjVolume
end getVolume

on adjustSchedule()
	try
		set rawDelayValue to do shell script "curl --max-time 5 --connect-timeout 5 https://raw.githubusercontent.com/scrippscollegejournal/preferences/main/Delay%20SCJ%20Issue"
		if rawDelayValue is not "404: Not Found" or rawDelayValue is not "" then
			set delayValue to rawDelayValue as number
		else
			set delayValue to 0
		end if
	on error
		set delayValue to 0
	end try
	set incrementMonth to 9
	set delayVolume to 0
	if delayValue is 0.5 or delayValue is "sem" or delayValue is "semester" then
		set incrementMonth to 12
	else if delayValue is greater than 0.5 then
		set checkInteger to (delayValue div 1 is delayValue)
		if checkInteger is false then
			set delayValueTest to ((delayValue - 0.5) div 1 is (delayValue - 0.5))
			if delayValueTest is false then
				set incrementMonth to 9
			else
				set incrementMonth to 12
				set delayVolume to (delayValue - 0.5)
			end if
		else
			set delayVolume to delayValue
		end if
	else
		set incrementMonth to 9
	end if
	return {incrementMonth, delayVolume}
end adjustSchedule
