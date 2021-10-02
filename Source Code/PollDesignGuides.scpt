--=========================
(* PollDesignGuides 1.0 *)

-- Info: 
-- Created August 21 2021
-- Last updated September 24 2021

---- © 2021 Shay Lari-Hosain. All rights reserved. Unauthorized copying or reproduction of any part of the proprietary contents of this file, via any medium, is strictly prohibited.
--=========================

on run {scjvolume}
	
	set assetsVersionDownload to "https://raw.githubusercontent.com/scrippscollegejournal/design-resources/main/Assets%20Version" -- CHANGE FINAL URL
	try
		set designCheckSuccess to true
		set scjLatestVersion to do shell script "curl --max-time 4 --connect-timeout 4 " & assetsVersionDownload
	on error
		set designCheckSuccess to false
	end try
	
	tell application "Finder"
		set availAssets to (name of every folder of (path to documents folder) whose name contains "Scripps College Journal — Volume ")
		set assetCount to count (every folder of (path to documents folder) whose name contains "Scripps College Journal — Volume ")
	end tell
	
	set aliasAssets to {}
	
	repeat with a from 1 to length of availAssets
		set theCurrentItem to item a of availAssets
		set makeAlias to ((path to documents folder) & theCurrentItem as string) as alias
		copy (makeAlias) to the end of the |aliasAssets|
	end repeat
	
	set versionAssets to {}
	
	repeat with a from 1 to length of aliasAssets
		set theCurrentItem to item a of aliasAssets
		set versionLocation to POSIX path of (theCurrentItem & ".SCJ Design Version.txt" as string)
		try
			set guidesValid to true
			set makeVersion to (paragraphs of (read POSIX file versionLocation) as text)
		on error
			set guidesValid to false
		end try
		if guidesValid is true then
			tell application "Finder" to set makeName to name of folder theCurrentItem as string
			copy {makeName, makeVersion} to the end of the |versionAssets|
		end if
	end repeat
	
	set nameList to parseSublists(versionAssets, 1)
	set versionList to parseSublists(versionAssets, 2)
	set assetCount to count every item of nameList
	
	if assetCount is less than 2 and designCheckSuccess is true then
		set makeAlias to ((path to documents folder) & nameList as string) as alias
		if scjLatestVersion is greater than versionList then
			set chooseOldButton to button returned of (display dialog "The existing SCJ design guide found on this Mac is not for the upcoming issue, Volume " & scjvolume & "." & return & return & "You can get the latest design guides for Volume " & scjvolume & ", or you can continue to use the previous year's, " & nameList & "." buttons {"Get Design Guides…", "Use Existing"} default button 2 with title "Design Guide From Previous Year")
			if chooseOldButton is "Use Existing" then
				set assetsReturned to makeAlias
				-- display alert "Name: " & nameList & return & return & "Path: " & assetsReturned
			else
				set assetsReturned to "download"
			end if
		else
			set assetsReturned to makeAlias
			-- display alert "Name: " & nameList & return & return & "Path: " & assetsReturned
		end if
	else
		if designCheckSuccess is true then
			copy {"↓ Scripps College Journal — Volume " & scjvolume & " (Latest for download)"} to the end of the |nameList| -- can also use beginning
			set downloadMessage to ", or get the latest design guides:"
		else
			set downloadMessage to ", but you can’t get the latest design guides because your Internet connection appears to be offline:"
		end if
		set chooseOldFolder to (choose from list nameList with prompt "Multiple SCJ design guides were found on this Mac, but none of them are for the upcoming issue, Volume " & scjvolume & "." & return & return & "You can select a previous year’s to use" & downloadMessage with title "Design Guides From Previous Years" OK button name {"Use"} cancel button name {"Locate Manually…"})
		if chooseOldFolder is false then
			error number -128
		else
			set chooseOldFolder to chooseOldFolder as string
			if chooseOldFolder contains "Download" then -- change to whatever is necessary
				set assetsReturned to "download"
			else
				set assetsReturned to ((path to documents folder) & chooseOldFolder as string) as alias
				-- display alert "Name: " & chooseOldFolder & return & return & "Path: " & assetsReturned
			end if
		end if
	end if
	
	return assetsReturned
	
end run

on parseSublists(theList, sublistItemIndex)
	set indexedItems to {}
	repeat with i from 1 to (count of theList)
		set end of indexedItems to item sublistItemIndex of item i of theList
	end repeat
	return indexedItems
end parseSublists
