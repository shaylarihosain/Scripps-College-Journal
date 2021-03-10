--=========================
(* PickRandom 1.3 *)

-- Info: Displays random InDesign tips
-- Created July 28 2020
-- Last updated October 13 2020

---- © 2020 Shay Lari-Hosain. All rights reserved. Unauthorized copying or reproduction of any part of the proprietary contents of this file, via any medium, is strictly prohibited.
--=========================

RandomTips()

on RandomTips()
	
	set myList to {"You can export an .IDML (InDesign Markup Language) file to open it in an earlier version of InDesign than the one the document was created with. (File ➜ Export…)", "Text Frame Options: ⌘ + B", "Paste in Place: OPT + SHIFT + ⌘ + V", "Fit Content Proportionally: OPT + SHIFT + ⌘ + E", "Fit Frame to Content: OPT + ⌘ + C", "Toggle All Grids, Columns & Guides: W", "Toggle Document Grid: ⌘ + “ ", "Toggle Typography Grid: OPT + ⌘ + “ ", "How to use InDesign's clipping paths: http://helpx.adobe.com/indesign/using/clipping-paths.html", "How to become a pro at reflowing text: https://helpx.adobe.com/indesign/using/threading-text.html#cut_or_delete_threaded_text_frames"}
	set theItem to some item of myList
	
	set rnbutton to button returned of (display alert "Random InDesign Tips 😃🤔" message theItem buttons {"Stop…", "Shuffle Tips"} default button "Shuffle Tips" giving up after 8)
	if rnbutton is "Shuffle Tips" then
		RandomTips()
	else if rnbutton is "Stop…" then
		--- Welcome()
		error number -128
	else
		RandomTips()
	end if
	
end RandomTips

-- Future features
-- ===============
-- 
