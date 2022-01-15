--=========================
(* Export SCJ Magazine 3.1.1 *)

-- Info: Export the magazine easily, quickly and intuitively in a variety of formats, while bypassing the complexity of the InDesign Package or PDF Export interfaces, which use specific terms that students or non-designers may not be familiar with. Generated files comply with the particular SCJ workflow and print house's requirements, and use the SCJ PDF presets that BaseCode installs on the user's machine. BaseCode ensures that dropping the InDesign .indd file onto the SCJ application's Dock icon calls this program.
-- Created August 24 2020
-- Last updated November 7 2021

---- © 2020–2021 Shay Lari-Hosain. All rights reserved. Unauthorized copying or reproduction of any part of the proprietary contents of this file, via any medium, is strictly prohibited.
--=========================

on run {myDocument, docName, adobeCCver, assets_path, IDver}
	if application id "com.adobe.InDesign" is not running then tell application id "com.adobe.InDesign" to launch
	exportMagazine(myDocument, docName, adobeCCver, assets_path, IDver)
end run

on exportMagazine(myDocument, docName, adobeCCver, assets_path, IDver)
	set currentPrintHouse to ""
	if adobeCCver contains "mismatched" then
		if IDver is greater than or equal to 12 then
			set IDdisplayVersion to (IDver + 2005)
		else if IDver is less than 9 then
			set IDdisplayVersion to ""
		else
			set IDdisplayVersion to (IDver + 2004)
		end if
	else
		set IDdisplayVersion to adobeCCver
	end if
	set docNameNoExt to text 1 thru ((offset of ".indd" in docName) - 1) of docName
	
	set action to button returned of (display alert "Let's start the magazine export process." message "SEND PAGES FOR SENIOR DESIGNER — Along with your InDesign file, which the senior designer needs, a preview PDF is generated, which you and your team can evaluate in design reviews. If you use Apple Mail, you can email your work directly to the senior designer or anyone else, right from here." & return & return & "EXPORT MAGAZINE FOR WEB — Exports a PDF of the magazine with formatting and color best suited for viewing onscreen, online upload, or printing on a home inkjet printer." & return & return & "EXPORT MAGAZINE FOR PRINT — Exports a package of the magazine, which includes a PDF with formatting and color built to specification for our commercial print house, " & currentPrintHouse & "an InDesign CC " & IDdisplayVersion & " master file for archival, separate full-resolution image files of all art pieces, all typeface files used, and a backwards-compatible “emergency” IDML file usable with InDesign CS4." buttons {"Send Pages for Senior Designer", "Export Magazine for Web", "Export Magazine for Print"} default button 1) -- UPDATE
	
	tell application id "com.adobe.InDesign"
		open myDocument
		if action is "Export Magazine for Print" then
			set PDFPreset to "Scripps College Journal — Magazine for Print" as string
		else
			set PDFPreset to "Scripps College Journal — Magazine for Web" as string
		end if
		try
			set MyPDFexportPreset to PDF export preset PDFPreset
			set exportPresetStatus to true
		on error number -1728
			display notification "SCJ PDF presets aren't present, so preview PDFs weren't exported" with title "Export Magazine ⚠️"
			set exportPresetStatus to false
		end try
	end tell
	
	if exportPresetStatus is not false then
		set UsernameDebug to (word 1 of long user name of (system info))
		set loadTime to (((path to me as text) & "::SetTimeHandler.scpt") as alias) as string
		set loadTime to (load script loadTime as alias)
		set scjvolume to getVolume() of loadTime
		set congratsOptions to {"Congrats!", "Aww yeah!"}
		
		if action is "Send Pages for Senior Designer" then
			tell application id "com.adobe.InDesign"
				open myDocument
				tell PDF export preferences
					set page range to all pages
				end tell
				tell active document
					export format PDF type to (assets_path & docNameNoExt & " (Preview).pdf" as string) using MyPDFexportPreset without showing options
				end tell
			end tell
			set emailButton to button returned of (display alert "Do you want to email your page layout work? 📩" message "With Apple Mail, we can send your InDesign file, along with the preview PDF that we can browse together during design review sessions." buttons {"Skip", "Send"} default button 2)
			set pdfAttachment to (assets_path & docNameNoExt & " (Preview).pdf" as string) as alias
			set inddAttachment to myDocument as string as alias
			tell application "Finder"
				activate
				open folder assets_path
				-- set selection to (alias (assets_path & docNameNoExt & " (Preview).pdf" as string))
				set selection to (alias (assets_path & docNameNoExt & ".indd" as string))
			end tell
			if emailButton is "Send" then
				try
					tell application "Mail"
						activate
						set theMessage to make new outgoing message with properties {visible:true, subject:UsernameDebug & "'s SCJ Pages for Vol " & scjvolume, content:"Packaged automatically with Scripps College Journal Design System for Mac"}
						tell content of theMessage
							make new attachment with properties {file name:pdfAttachment} at after last paragraph
							make new attachment with properties {file name:inddAttachment} at after last paragraph
						end tell
					end tell
				on error
					display notification "We couldn't create an email. This could be because Mail is not set up with an account. Please deliver the files to your team however you want!" with title "Export Magazine 📚"
					tell application "Finder" to open folder assets_path
				end try
			end if
		else if action is "Export Magazine for Web" then
			set lastMinuteCancelButton to button returned of (display alert "Starting export of Scripps College Journal Volume " & scjvolume & " for Web…" buttons {"Cancel"} giving up after 2)
			if lastMinuteCancelButton is "Cancel" then
				display notification "was removed from the SCJ InDesign export queue" subtitle docName with title "Export Magazine 📚"
				error number -128
			end if
			tell application id "com.adobe.InDesign"
				open myDocument
				tell PDF export preferences
					set page range to all pages
					set export guides and grids to false
				end tell
				tell active document
					export format PDF type to (assets_path & docNameNoExt & " (Release) [For Web].pdf" as string) using MyPDFexportPreset without showing options
				end tell
			end tell
			tell application "Finder"
				activate
				open folder assets_path
				set selection to alias (assets_path & docNameNoExt & " (Release) [For Web].pdf" as string)
			end tell
			set congrats to some item of congratsOptions
			display notification congrats & " 😍" & return & "This is not a print file. Do not use for print." & return & "Color profile: sRGB" subtitle "SCJ Volume " & scjvolume & " for Web 💻 is ready! ✓" with title "Export Magazine 📚" sound name "triggerTriTone"
		else if action is "Export Magazine for Print" then
			set lastMinuteCancelButton to button returned of (display alert "Starting export of Scripps College Journal Volume " & scjvolume & " for Print…" buttons {"Cancel"} giving up after 2)
			if lastMinuteCancelButton is "Cancel" then
				display notification with title docName subtitle "was removed from the SCJ InDesign export queue"
				error number -128
			end if
			try
				tell application "Finder" to make new folder at (path to desktop) with properties {name:"Scripps College Journal — Volume " & scjvolume & " (Print)"}
			on error
				display alert "There's already an SCJ Magazine Package of Volume " & scjvolume & " on the desktop." message "Please rename or move that folder and try again." buttons {"Cancel", "Try Again"} cancel button 1 default button 2 as critical
				exportMagazine(myDocument, docName, adobeCCver, assets_path, IDver)
			end try
			tell application id "com.adobe.InDesign"
				open myDocument
				set packagePath to ((path to desktop) & "Scripps College Journal — Volume " & scjvolume & " (Print)" as string) as alias
				tell PDF export preferences
					set page range to all pages
					set export guides and grids to false
				end tell
				tell active document
					package to packagePath copying fonts yes copying linked graphics yes including hidden layers yes copying profiles no updating graphics no creating report yes ignore preflight errors yes pdf style PDFPreset with include idml and include pdf
					export format PDF type to (packagePath & docNameNoExt & " (For Web).pdf" as string) using "Scripps College Journal — Magazine for Web" without showing options
				end tell
			end tell
			tell application "Finder" to open folder ((path to desktop) & "Scripps College Journal — Volume " & scjvolume & " (Print)" as string) as alias
			set congrats to some item of congratsOptions
			display notification congrats & " 🔥" & return & "Master package exported to desktop." & return & "Color profile: US Webcoated CMYK" subtitle "SCJ Volume " & scjvolume & " for Print 🖨 is ready! ✓" with title "Export Magazine 📚" sound name "triggerTriTone" -- 🎉🤩
			open location "https://wetransfer.com"
			-- play sound of delight
		end if
		if action is not "Export Magazine for Print" then
			set reExport to button returned of (display alert "Would you like to export the magazine in another format?" buttons {"Quit", "Export Another", "Go Home"})
			if reExport is "Export Another" then
				exportMagazine(myDocument, docName, adobeCCver, assets_path, IDver)
			else if reExport is "Go Home" then
				error number -128
			else if reExport is "Quit" then
				tell application id "edu.scrippsjournal.design" to quit
			end if
		end if
	end if
end exportMagazine
