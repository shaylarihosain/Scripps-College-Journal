--=========================
(* Export SCJ Magazine 2.1 (Beta) *)

-- Info: 
-- Created August 24 2020
-- Last updated February 28 2021

---- © 2020–2021 Shay Lari-Hosain. All rights reserved. Unauthorized copying or reproduction of any part of the proprietary contents of this file, via any medium, is strictly prohibited.
--=========================

on run {MyDocument, docName, action}
	
	tell application id "com.adobe.InDesign"
		open MyDocument
		if action is "exportWeb" then
			set PDFPreset to "Scripps College Journal — Magazine for Web" as string
		else if action is "exportPrint" then
			set PDFPreset to "Scripps College Journal — Magazine for Print" as string
		end if
		try
			set MyPDFexportPreset to PDF export preset PDFPreset
			set exportPresetStatus to true
		on error number -1728
			display notification "⚠️ SCJ Adobe PDF export settings aren't present, so preview PDFs weren't exported."
			set exportPresetStatus to false
		end try
	end tell
	-- set MyPath to (file path of MyDocument as alias) as string
	
	if exportPresetStatus is not false then
		tell application id "com.adobe.InDesign"
			tell active document
				export format PDF type to (path to desktop as string) & (docName & ".pdf" as string) using MyPDFexportPreset without showing options
			end tell
		end tell
	end if
	
	
	set emailButton to button returned of (display alert "Let's send your page layout work." message "We'll create an archive that you can send to anyone on your team." & return & return & "It will include your InDesign files, as well as preview PDFs that we can browse together during design review sessions." buttons {"Cancel", "Proceed & Email Files", "Proceed"} cancel button 1 default button 3)
	
	set UsernameDebug to (do shell script "whoami")
	set loadTime to (((path to me as text) & "::SetTimeHandler.scpt") as alias) as string
	set loadTime to (load script loadTime as alias)
	set scjvolume to getVolume() of loadTime
	
	if emailButton is "Proceed & Email Files" then
		set theAttachment to ((path to desktop as string) & (docName & ".pdf" as string) as alias)
		tell application "Mail"
			activate
			set theMessage to make new outgoing message with properties {visible:true, subject:UsernameDebug & "'s SCJ Pages for Vol " & scjvolume, content:"Packaged automatically with Scripps College Journal Design System for Mac"}
			tell content of theMessage
				make new attachment with properties {file name:theAttachment} at after last paragraph
			end tell
		end tell
	end if
	
end run
