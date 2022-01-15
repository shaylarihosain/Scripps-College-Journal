--=========================
(* Tips 3.0 *)

-- Info: Displays random InDesign tips, offers a searchable database of actionable information, and provides quick access to certain materials
-- Created July 28 2020
-- Last updated January 14 2022

---- © 2020–2022 Shay Lari-Hosain. All rights reserved. Unauthorized copying or reproduction of any part of the proprietary contents of this file, via any medium, is strictly prohibited.
--=========================

on run {assets_path}
	RandomTips(assets_path)
end run

on RandomTips(assets_path)
	
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
	
	set myList to {"You can export an .IDML (InDesign Markup Language) file to open it in an earlier version of InDesign than the one the document was created with. (File ➜ Export…)", "Text Frame Options:" & return & "⌘ + B", "Paste in Place:" & return & "OPT + SHIFT + ⌘ + V", "Fit Content Proportionally:" & return & "OPT + SHIFT + ⌘ + E", "Fit Frame to Content:" & return & "OPT + ⌘ + C", "Toggle All Grids, Columns & Guides:" & return & "W", "Toggle Document Grid:" & return & "⌘ + “ ", "Toggle Typography Grid:" & return & "OPT + ⌘ + “ ", "SCJ always delivers a CMYK color PDF to the printer, and an RGB color PDF for all other uses, including onscreen display and preview.", "Tutorial — How to Use InDesign’s Clipping Paths (adobe.com)", "Tutorial — How to Become a Pro at Reflowing Text (adobe.com)", "Tutorial — SCJ Tutorials (drive.google.com)"}
	set theItem to some item of myList
	
	if slackInstalled is true then
		if application "Slack" is running then
			set slackButton to "Actions…"
		else
			set buttonOptions to {"Actions…", "Open Slack…"}
			set slackButton to some item of buttonOptions
		end if
	else if slackInstalled is false then
		set slackButton to "Get Slack"
	end if
	
	if theItem contains "Tutorial" then
		set slackButton to "Open Tutorial"
	end if
	
	set rnbutton to button returned of (display alert "Random InDesign Tips 💭😃🤔" message theItem buttons {slackButton, "Close", "Shuffle"} default button "Shuffle" giving up after 9)
	if rnbutton is "Shuffle" then
		RandomTips(assets_path)
	else if rnbutton is "Close" then
		--- Welcome()
		error number -128
	else if rnbutton is "Open Slack…" then
		try
			tell application "Slack" to launch -- com.tinyspeck.slackmacgap
		end try
		RandomTips(assets_path)
	else if rnbutton is "Get Slack" then
		open location "https://apps.apple.com/us/app/slack/id803453959" -- "?mt=12"
	else if rnbutton is "Open Tutorial" then
		if theItem contains "clipping" then
			set tutorialLink to "http://helpx.adobe.com/indesign/using/clipping-paths.html"
		else if theItem contains "reflowing" then
			set tutorialLink to "https://helpx.adobe.com/indesign/using/threading-text.html#cut_or_delete_threaded_text_frames"
		else if theItem contains "SCJ Tutorials" then
			set tutorialLink to "https://drive.google.com/drive/folders/1TEU21ZBLcriMadFMfd3cOdeJdUx1SS69"
		end if
		open location tutorialLink
		RandomTips(assets_path)
	else if rnbutton is "Actions…" then
		searchTips("Type a topic (e.g. “art” to reveal Artwork folder in Finder)", assets_path, slackInstalled)
	else
		RandomTips(assets_path)
	end if
	
end RandomTips

-- Search lookup function
-- ===============
on searchTips(defaultText, assets_path, slackInstalled)
	
	if slackInstalled is true then
		if application "Slack" is running then
			set alreadyOpenSlack to true
		else
			set alreadyOpenSlack to false
		end if
	end if
	
	if slackInstalled is true and alreadyOpenSlack is false then
		set slackButton to "Open Slack…"
	else
		set slackButton to "Close"
	end if
	
	set tipsDialog to (display dialog "Ask for help. If we can’t find what you’re looking for, you’ll return here." & return & return & "You can also ask Slackbot. Go to your Slack DMs, and type ‘scj help.’" buttons {"Back…", slackButton, "Search"} default answer defaultText default button "Search" with title "Tips 💭" with icon note)
	
	if text returned of tipsDialog is "fonts" or text returned of tipsDialog is "typography" or text returned of tipsDialog is "type" or text returned of tipsDialog is "font" then
		set windowHeader to "Consult the style guide for the latest information about the fonts we use."
		set windowText to "The fonts included with the style guide are already installed on your Mac."
		standardTipsExplainer(windowHeader, windowText, assets_path, slackInstalled)
		searchTips("Type a topic", assets_path, slackInstalled)
	else if text returned of tipsDialog is "Duplicating" then
		set duplicatingCollege to button returned of (display dialog "Which college’s duplicating services would you like to contact?" buttons {"Pitzer", "Pomona"} with title "Tips 💭 — Duplicating")
		if duplicatingCollege is "Pitzer" then
			set dupContact to {"facetime-audio:9096218461", "https://www.pitzer.edu/duplicating/", "mailto:duplicating@pitzer.edu", "Located on the first floor of Bernard Hall 111 next to the Pit Stop Café." & return & return & "Renders a wide range of printing and copy services." & return & return & "We used them to print tabloid-size (11” × 17”) promo posters for the Journal in 2019, and they look great."}
		else if duplicatingCollege is "Pomona" then
			set dupContact to {"facetime-audio:9096072820", "https://www.pomona.edu/administration/facilities-campus-services/offices/duplicating", "mailto:duplicating@pomona.edu​", "Located on South Campus in Harvard/McCarthy Building at 201 W 4th. St." & return & return & "Provides economical and convenient high-quality copying services." & return & return & "It’s on South Campus; a bit of a walk from Scripps."}
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
		searchTips("Type a topic", assets_path, slackInstalled)
	else if text returned of tipsDialog contains "tutorial" then
		open location "https://drive.google.com/drive/folders/1TEU21ZBLcriMadFMfd3cOdeJdUx1SS69"
		searchTips("Type a topic", assets_path, slackInstalled)
	else if text returned of tipsDialog contains "meeting" or text returned of tipsDialog contains "workshop" then
		open location "https://drive.google.com/drive/u/3/folders/1xtubOESfrhelZYPabR3Kd38a-rOpDgEx"
		searchTips("Type a topic", assets_path, slackInstalled)
	else if text returned of tipsDialog contains "video" or text returned of tipsDialog is "video tutorial" then
		tell application "QuickTime Player" to open URL "https://github.com/scrippscollegejournal/video-tutorials/blob/main/Assets%20Tutorial.mov?raw=true"
		searchTips("Type a topic", assets_path, slackInstalled)
	else if text returned of tipsDialog is "art" or text returned of tipsDialog is "artwork" or text returned of tipsDialog contains "place art" or text returned of tipsDialog contains "open artwork" or text returned of tipsDialog is "artowrk" or text returned of tipsDialog is "artowork" then
		try
			tell application "Finder"
				open folder ((assets_path & "Artwork" as string) as alias)
				set frontmost to true
			end tell
		end try
		tell me to activate
		set windowHeader to "Here’s the SCJ Artwork folder. And here’s how to place visual art."
		set windowText to "In InDesign, pull up the magazine page you want artwork on. Then drag and drop an image from this folder onto the SCJ icon in the Dock to place it." & return & return & "If you drag and drop the piece now, it will be placed once you close Tips."
		standardTipsExplainer(windowHeader, windowText, assets_path, slackInstalled)
	else if text returned of tipsDialog contains "design guide" or text returned of tipsDialog is "guide" or text returned of tipsDialog is "indesign file" or text returned of tipsDialog is "indesign doc" or text returned of tipsDialog is "indd" or text returned of tipsDialog is "master file" then
		try
			tell application "Finder"
				activate
				open folder ((assets_path as string) as alias)
			end tell
		on error
			do shell script "open ~/Documents"
		end try
		-- searchTips("Type a topic", assets_path, slackInstalled)
	else if text returned of tipsDialog is "slack" or text returned of tipsDialog is "open slack" or text returned of tipsDialog contains "slack dm" then
		try
			tell application "Slack" -- com.tinyspeck.slackmacgap
				launch
				activate
			end tell
		end try
		error number -128
	else if text returned of tipsDialog is "tracker" or text returned of tipsDialog contains "submitted work" then
		set appPrefsLocation to ("https://raw.githubusercontent.com/scrippscollegejournal/preferences/main/Master%20Settings")
		set appPrefs to do shell script "curl --max-time 4 --connect-timeout 4 " & appPrefsLocation
		set trackerLink to paragraph 2 of appPrefs
		try
			open location trackerLink
		on error
			display alert "Tracker couldn’t be located." message "We’re sorry." buttons {""} giving up after 2
			searchTips("Type a topic", assets_path, slackInstalled)
		end try
	else if text returned of tipsDialog is "intro" or text returned of tipsDialog contains "what can you do" then
		set windowHeader to "Here’s a few things you can do with Scripps College Journal:"
		set windowText to "✒️ To place a writing piece on the current page, drag and drop a Word doc onto the SCJ icon in the Dock. We’ll place and format it automatically." & return & return & "🎨 To place visual art on the current spread, drag and drop an image on the SCJ icon." & return & return & "📚 To export the magazine with a click, drag and drop the InDesign file from the Finder onto the SCJ icon."
		standardTipsExplainer(windowHeader, windowText, assets_path, slackInstalled)
	else if button returned of tipsDialog is "Open Slack…" then
		try
			tell application "Slack" to launch -- com.tinyspeck.slackmacgap
		end try
		searchTips("Type a topic", assets_path, slackInstalled)
	else if button returned of tipsDialog is "Back…" then
		RandomTips(assets_path)
	else if button returned of tipsDialog is "Close" then
		error number -128
	else
		try
			do shell script "afplay /System/Library/PrivateFrameworks/ScreenReader.framework/Versions/A/Resources/Sounds/EnterVisibleArea.aiff"
		end try
		searchTips("Try another topic", assets_path, slackInstalled)
	end if
	
end searchTips

on standardTipsExplainer(windowHeader, windowText, assets_path, slackInstalled)
	set windowButton to button returned of (display alert windowHeader message windowText buttons {"Tips…", "Close"} default button 2)
	if windowButton is "Tips…" then
		searchTips("Type a topic", assets_path, slackInstalled)
	else
		error number -128
	end if
end standardTipsExplainer
