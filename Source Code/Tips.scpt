--=========================
(* Tips 2.0 *)

-- Info: Displays random InDesign tips
-- Created July 28 2020
-- Last updated April 23 2021

---- © 2020–2021 Shay Lari-Hosain. All rights reserved. Unauthorized copying or reproduction of any part of the proprietary contents of this file, via any medium, is strictly prohibited.
--=========================

RandomTips()

on RandomTips()
	
	try
		tell application "Finder" to get application "Slack"
		set slackInstalled to true
	on error
		set slackInstalled to false
		try
			tell application "Finder" to get application file id "com.tinyspeck.slackmacgap"
			set slackInstalled to true
		on error
			set slackInstalled to false
		end try
	end try
	
	if slackInstalled is true then
		if application "Slack" is running then
			set alreadyOpenSlack to true
		else
			set alreadyOpenSlack to false
		end if
	end if
	
	set myList to {"You can export an .IDML (InDesign Markup Language) file to open it in an earlier version of InDesign than the one the document was created with. (File ➜ Export…)", "Text Frame Options:" & return & "⌘ + B", "Paste in Place:" & return & "OPT + SHIFT + ⌘ + V", "Fit Content Proportionally:" & return & "OPT + SHIFT + ⌘ + E", "Fit Frame to Content:" & return & "OPT + ⌘ + C", "Toggle All Grids, Columns & Guides:" & return & "W", "Toggle Document Grid:" & return & "⌘ + “ ", "Toggle Typography Grid:" & return & "OPT + ⌘ + “ ", "SCJ always delivers a CMYK color PDF to the printer, and an RGB color PDF for all other uses, including onscreen display and preview.", "Tutorial — How to Use InDesign's Clipping Paths (adobe.com)", "Tutorial — How to Become a Pro at Reflowing Text (adobe.com)"}
	set theItem to some item of myList
	
	if slackInstalled is true then
		if alreadyOpenSlack is true then
			set slackButton to "Search…"
		else if alreadyOpenSlack is false then
			set slackButton to "Open Slack…"
		end if
	else if slackInstalled is false then
		set slackButton to "Get Slack"
	end if
	
	if theItem contains "Tutorial" then
		set slackButton to "Open Tutorial"
	end if
	
	set rnbutton to button returned of (display alert "Random InDesign Tips 😃🤔" message theItem buttons {slackButton, "Stop", "Shuffle"} default button "Shuffle" giving up after 9)
	if rnbutton is "Shuffle" then
		RandomTips()
	else if rnbutton is "Stop" then
		--- Welcome()
		error number -128
	else if rnbutton is "Open Slack…" then
		try
			tell application "Slack" to launch -- com.tinyspeck.slackmacgap
		end try
		RandomTips()
	else if rnbutton is "Get Slack" then
		open location "https://apps.apple.com/us/app/slack/id803453959" -- "?mt=12"
	else if rnbutton is "Open Tutorial" then
		if theItem contains "clipping" then
			set tutorialLink to "http://helpx.adobe.com/indesign/using/clipping-paths.html"
		else if theItem contains "reflowing" then
			set tutorialLink to "https://helpx.adobe.com/indesign/using/threading-text.html#cut_or_delete_threaded_text_frames"
		end if
		open location tutorialLink
		RandomTips()
	else if rnbutton is "Search…" then
		searchTips()
	else
		RandomTips()
	end if
	
end RandomTips

-- Search lookup function
-- ===============
on searchTips()
	
	set tipsDialog to (display dialog "Ask for help. If we can't find what you're looking for, you'll return here." & return & return & "You can also use Slackbot. Go to your Slack DMs, and type ‘scj help.’" buttons {"Stop", "Back…", "Search"} default answer "Type a topic" default button "Search" with title "Tips" with icon note)
	
	if text returned of tipsDialog is "fonts" or text returned of tipsDialog is "typography" or text returned of tipsDialog is "type" or text returned of tipsDialog is "font" then
		display alert "Consult the style guide for the latest information about the fonts we use." buttons {"Back…"}
		searchTips()
	else if text returned of tipsDialog is "Duplicating" then
		set duplicatingCollege to button returned of (display dialog "Which college's duplicating services would you like to contact?" buttons {"Pitzer", "Pomona"} with title "Tips — Duplicating")
		if duplicatingCollege is "Pitzer" then
			set dupContact to {"facetime-audio:9096218461", "https://www.pitzer.edu/duplicating/", "mailto:duplicating@pitzer.edu", "Located on the first floor of Bernard Hall 111 next to the Pit Stop Café." & return & return & "Renders a wide range of printing and copy services." & return & return & "We used them to print tabloid-size (11” × 17”) promo posters for the Journal in 2019, and they look great."}
		else if duplicatingCollege is "Pomona" then
			set dupContact to {"facetime-audio:9096072820", "https://www.pomona.edu/administration/facilities-campus-services/offices/duplicating", "mailto:duplicating@pomona.edu​", "Located on South Campus in Harvard/McCarthy Building at 201 W 4th. St." & return & return & "Provides economical and convenient high-quality copying services." & return & return & "It's on South Campus; a bit of a walk from Scripps."}
		end if
		set duplicatingHelp to button returned of (display alert duplicatingCollege & " Duplicating Services" message item 4 of dupContact buttons {"Website", "Email", "Call"}) -- replace Website with Location"?
		if duplicatingHelp is "Call" then
			-- load osver from CCC
			open location item 1 of dupContact
		else if duplicatingHelp is "Website" then
			open location item 2 of dupContact
		else if duplicatingHelp is "Email" then
			open location item 3 of dupContact
		end if
		searchTips()
	else if text returned of tipsDialog is "tutorial" or text returned of tipsDialog is "tutorials" then
		open location "https://drive.google.com/drive/folders/1TEU21ZBLcriMadFMfd3cOdeJdUx1SS69"
		searchTips()
	else if button returned of tipsDialog is "Back…" then
		RandomTips()
	else if button returned of tipsDialog is "Stop" then
		error number -128
	else
		searchTips()
	end if
	
end searchTips
