REBOL [
	Title: "NIST clock"
	File: %nistclock.r
	Author: "Ladislav Mecir"
	Date: 10-Nov-2012/12:01:16+1:00
	Purpose: {
		Get the current time using the NIST service.
		
		Defines NIST-TIME, NIST-CORRECTED-TIME and SET-SYSTEM-TIME functions.

		Uses a GUI to display and (eventually) set system time.
	}
	Notes: {
		The servers that have been commented out seem to not work reliably
		at present.
		
		In some operating systems you may want to run the script as
		an administrator to be able to modify the system time.
	}
]

use [
	correction-interval nist-correction correction-time
	set-system-time-win set-system-time-lin time-servers
	server-no
] [
	time-servers: [
		daytime://nist1.aol-va.symmetricom.com
		daytime://nist1-atl.ustiming.org
		daytime://nist.expertsmi.com
		daytime://time.nist.gov
	]
	
	server-no: 0

	nist-time: func [
		{Never use this function more often than once in four seconds!}
		/local nist-time mjd hms
	] [
		until [
			server-no: server-no + 1
			if server-no > length? time-servers [server-no: 1]
			all [
				not error? try [nist-time: read pick time-servers server-no]
				parse/all nist-time [
					skip copy mjd 5 skip 2 thru " " copy hms 8 skip to end
				]
			]
		]
		nist-time: 17/Nov/1858 + to integer! mjd
		nist-time/time: to time! hms
		nist-time
	]

	correction-interval: 0:8:0
	correction-time: now - correction-interval
	nist-correction: 0:0:0

	nist-corrected-time: func [
		{
		    this function may be used as often as desired
		    assuming that the system clock does not change faster
		    than by CORRECTION-INTERVAL in four seconds
		}
		/local result
	] [
		result: now + nist-correction
		if correction-interval <= difference result correction-time [
			correction-time: nist-time
			nist-correction: difference correction-time now
			result: now + nist-correction
		]
		result
	]

	set-system-time-win: func [
		{set system time in Windows; return True in case of success}
		[catch]
		date
		/local set-system-time
	] [
		unless value? 'kernel32 [kernel32: load/library %kernel32.dll]
	
		set-system-time: make routine! [
			systemtime [struct! []]
			return: [int]
		] kernel32 "SetSystemTime"
		
		; date to UTC
		date: date - date/zone
		date/zone: 0:0
	
		0 <> set-system-time make struct! [
			wYear [short]
			wMonth [short]
			wDayOfWeek [short]
			wDay [short]
			wHour [short]
			wMinute [short]
			wSecond [short]
			wMilliseconds [short]
		] reduce [
			date/year
			date/month
			date/weekday
			date/day
			date/time/hour
			date/time/minute
			to integer! date/time/second
			0
		]
	]
	
	set-system-time-lin: func [
		{set system time in Linux; return True in case of success}
		[catch]
		date
		/local settimeofday
	] [
		unless value? 'libc.so [libc.so: load/library %/lib/libc.so.6]
		unless value? 'null-struct [
			null-struct: make struct! [struct [struct! []]] none
			null-struct: null-struct/struct
		]
	
		settimeofday: make routine! [
			tv [struct! []]
			tz [struct! []]
			return: [integer!]
		] libc.so "settimeofday"
		
		; date to UTC
		date: date - date/zone
		date/zone: 0:0
		
		date: make struct! [
			tv_sec [int]
			tv_usec [int]
		] reduce [
			date - 1/1/1970 * 86400 + to integer! date/time
			0
		]
	
		0 = settimeofday date null-struct
	]

	set-system-time: switch system/version and 0.0.0.255.255 [
		0.0.0.3.1 [:set-system-time-win]
		0.0.0.4.2 [:set-system-time-lin]
	]

	; View version
	current-time: nist-corrected-time
	current-time: form current-time/time
	view/new layout [
		banner 140x32 rate 1 current-time feel [
			engage: func [face action event] [
				current-time: nist-corrected-time
				face/text: current-time/time
				show face
			]
		]
		button 140x20 "Set System Time" [
			if set-system-time nist-corrected-time [nist-correction: 0:0]
		] 
	]
	do-events
]
