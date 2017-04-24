REBOL [
    Title: "to-ical-date.r"
    Date: 10-Mar-2006
    Name: 'to-ical-date
    Version: 1
    File: %to-ical-date.r
    Author: "RebKodeur"
    Owner: "RebKodeur"
    Purpose: {
      Convert the rebol date into a iCal date string .
   }

    History: [
    1 [10-Mar-2006 "posted to rebol.com" "RebKodeur"]
]
    Language: 'English
    library: [
        level: 'intermediate 
        platform: 'win 
        type: 'tool 
        domain: 'text
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]


to-ical-date: func [dt ti /local temp buf temp2 buf2][
	dt: to-date dt
	ti: to-time ti
	
	temp: ti/1 
	if temp < 10 [temp: join "0" temp]
	
	buf: dt/month
	if buf < 10 [buf: join "0" buf]
	
	temp2: dt/day 
	if temp2 < 10 [temp2: join "0" temp2]
	
	buf2: ti/2
	if buf2 < 10 [buf2: join "0" buf2]
	
	rejoin [dt/year buf temp2 "T" temp buf2 "00Z"]
]