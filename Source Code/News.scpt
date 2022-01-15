--=========================
(* AnnouncementsSystem 1.4.3) *)

-- Info: 
-- Created July 8 2021
-- Last updated November 19 2021

---- © 2021 Shay Lari-Hosain. All rights reserved. Unauthorized copying or reproduction of any part of the proprietary contents of this file, via any medium, is strictly prohibited.
--=========================

on fetchNews(displayActive)
	
	try
		set announcementRaw to do shell script "curl --max-time 0.75 --connect-timeout 0.75 https://raw.githubusercontent.com/scrippscollegejournal/preferences/main/Announcements"
		if announcementRaw is not "404: Not Found" or announcementRaw is not "" then
			if announcementRaw contains "NOTIFICATION TEXT" then
				set userFacingAnnouncement to paragraph 2 of announcementRaw
				set announcementDate to paragraph 4 of announcementRaw
				set priority to paragraph 6 of announcementRaw
			end if
		else
			set userFacingAnnouncement to "none"
		end if
	on error
		set userFacingAnnouncement to "none"
	end try
	
	if displayActive is true and userFacingAnnouncement is not "none" and userFacingAnnouncement is not " " and userFacingAnnouncement is not return then displayNews(userFacingAnnouncement, announcementDate, priority)
	
	return userFacingAnnouncement
end fetchNews


on displayNews(userFacingAnnouncement, announcementDate, priority)
	
	if userFacingAnnouncement is not "none" then
		set dateString to do shell script "date '+%m.%d.%Y'"
		
		if userFacingAnnouncement contains "today" then
			if priority is "yes" then
				if announcementDate is dateString then display alert "Announcements & News 📣" message userFacingAnnouncement giving up after 4 buttons {"Dismiss"} default button 1
			else
				if announcementDate is dateString then display notification userFacingAnnouncement with title "Announcements & News 📣"
			end if
		else
			if priority is "yes" then
				display alert "Announcements & News 📣" message userFacingAnnouncement giving up after 4 buttons {"Dismiss"} default button 1
				
			else
				display notification userFacingAnnouncement with title "Announcements & News 📣"
			end if
		end if
	end if
	
end displayNews
