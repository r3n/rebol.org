REBOL [
    Title: "Days Per Month"
    Date: 3-Jul-2002
    Name: 'Days-Per-Month
    Version: 1.0.0
    File: %days-per-month.r
    Author: "Andrew Martin"
    Purpose: "Adds Days per Month to system/locale."
    eMail: Al.Bri@xtra.co.nz
    Web: http://valley.150m.com
    library: [
        level: 'beginner 
        platform: none 
        type: 'tool 
        domain: none 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

system/locale: make system/locale [
	Days-Per-Month: [
		31	; January
		28	; February
		31	; March
		30	; April
		31	; May
		30	; June
		31	; July
		31	; August
		30	; September
		31	; October
		30	; November
		31	; December
		]
	]
