--=========================
(* PollTextFramesInDesign 1.0 *)

-- Info: 
-- Created September 11 2021
-- Last updated September 18 2021

---- © 2021 Shay Lari-Hosain. All rights reserved. Unauthorized copying or reproduction of any part of the proprietary contents of this file, via any medium, is strictly prohibited.
--=========================

tell application id "com.adobe.InDesign"
	tell active page of layout window 1 of active document
		set everyTextFrame to every text frame
		set allTextFrameSizes to {}
		set allTextFrameAreas to {}
		set allTextFrameIDs to {}
		set allTextFrameIndexes to {}
		set countTextFrames to the count of text frames
		repeat with thisTextFrame in everyTextFrame
			set geoBounds to 0
			set theWidth to 0
			set theHeight to 0
			set geoBounds to geometric bounds of thisTextFrame
			set theHeight to ((item 3 of geoBounds) - (item 1 of geoBounds))
			set theWidth to ((item 4 of geoBounds) - (item 2 of geoBounds))
			set textFrameSize to {theHeight, theWidth}
			set textFrameArea to (theHeight * theWidth)
			copy textFrameSize to the end of the |allTextFrameSizes|
			copy textFrameArea to the end of the |allTextFrameAreas|
			copy id to the end of the |allTextFrameIDs|
		end repeat
		repeat with x from 1 to countTextFrames
			copy x to the end of the |allTextFrameIndexes|
		end repeat
	end tell
end tell


set largestFrame to allTextFrameAreas's first item

repeat with x in allTextFrameAreas
	if x > largestFrame then set largestFrame to x's contents
end repeat


set aRes to chooseListItemWithNumber(allTextFrameAreas, largestFrame) of me

on chooseListItemWithNumber(aList, aRes)
	
	set chooseNumber to 1
	repeat with a in aList
		set h to contents of a
		if h is equal to aRes then
			exit repeat
		end if
		set chooseNumber to chooseNumber + 1
	end repeat
	return chooseNumber
end chooseListItemWithNumber


set largestTextFrameID to item aRes of allTextFrameIDs
set largestTextFrameArea to item aRes of allTextFrameAreas
set largestTextFrameSize to item aRes of allTextFrameSizes
set largestTextFrameIndex to item aRes of allTextFrameIndexes

return {largestTextFrameID, largestTextFrameArea, largestTextFrameSize, largestTextFrameIndex}
