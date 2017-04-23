rebol [
	Title: "never cache"
	File: %never-cache.r
	Date: 22-Nov-2002
	Version: 1.0.2
	Needs: []
	Author: "Anton Rolls"
	Language: 'English
	Purpose: {function that outputs rebol and javascript code to ensure a page is always freshly
		loaded from the server}
	Library: [
		level: 'advanced
		platform: 'all
		type: 'function
		domain: [html web cgi]
		tested-under: "at least Rebol/View1.2.8 on WinXP, IE6.0"
		support: none
		license: 'mit
		see-also: none
	]
	Usage: {
	make sure never-cache.r is run before using the never-cache function.
	Our system uses Brian Hawley's require function, so I recommend the following
	require line in the server.r script:

		require %public/lib/never-cache.r		
	
	then just include the line:
	
		print never-cache
		
	somewhere in your rebol cgi's (preferably near the top, before images etc.)}
	ToDo: {
	-
	}
	History: [
		1.0.0 [10-Oct-2002 {First version} "Anton"]
		1.0.1 [27-Oct-2002 {now simply returns a string of code, no longer print's it for you, this
			allows it to be used with current implementation of embedded rebol scripting} "Anton"]
		1.0.2 [22-Nov-2002 {increased default delay time to 1500} "Anton"]
	]
	Notes: {
		This function assumes that it will be used in a rebol server-side cgi script,
		and that javascript is enabled in the client browser.

		I saw this as another way to force a reload from the server

				location.reload(force);

	}
]

never-cache: func [{print some code such that the page it appears will always be 
	loaded fresh from the server}
	/delay ms "minimum time in milliseconds after which the page will be forced to reload (default: 1000 ms = 1 second)"
	/debug "write the contents of some variables into the document"
	/local days seconds-per-day time seconds milliseconds
][
	if not delay [ms: 1500] ; set default value
	
	; calculate time in milliseconds, in same format as javascript's Date.getTime()
	days: (now - 1-jan-1970) ; this doesn't account for timezone (now/zone) - see below
	seconds-per-day: 24.0 * 3600
	time: now/time/precise
	seconds: (days * seconds-per-day) + ((time/hour * 3600) + (time/minute * 60) + time/second)
	seconds: seconds - to-integer now/zone ; account for timezone
	milliseconds: seconds * 1000.0

	rejoin [
		{<script language="JavaScript"><!--^/}

		{^-var timestamp = } milliseconds {;^/}

		either debug [{^-document.write(timestamp + " (timestamp)<br>");^/}][""]

		{^-var now = (new Date()).getTime();^/}

		either debug [{^-document.write(now + " (now)<br>");^/}][""]

		{
	if (now - timestamp > } ms ") { // more than " (ms / 1000) { second(s) old?

		//alert("diff=" + (now - lastTime));

		location.reload(true); // force a reload from the server
	}
		"}^/"
	
		either debug [{^-document.write("diff=" + (now - timestamp));^/}][""]

		{//--></script>^/}
	]
]
