--=========================
(* SetTimeHandler 1.0) *)

-- Info: Relocates older code for time-setting present in all programs into global/centralized handler that can be accessed by all programs
-- Created January 30 2021
-- Last updated January 30 2021

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
	if currentmonthint is less than 8 then
		set scjIssueYear to currentyear
	else if currentmonthint is greater than 7 then
		set scjIssueYear to currentyear + 1
	end if
	return scjIssueYear
end getIssueYear

on getVolume()
	set scjIssueYear to getIssueYear()
	set scjVolume to (scjIssueYear - 1999)
	return scjVolume
end getVolume
