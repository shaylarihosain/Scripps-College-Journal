on run
	try
		tell application "Creative Cloud" to activate
	on error
		tell application id "com.adobe.acc.AdobeCreativeCloud" to launch
	end try
end run
