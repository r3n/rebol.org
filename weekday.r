REBOL [
    Title: "Weekday"
    Date: 31-Aug-2002
    Name: 'Weekday
    Version: 1.1.2
    File: %weekday.r
    Author: "Andrew Martin"
    Purpose: {Creates Weekday routines to test if a date is a specific weekday.}
    eMail: Al.Bri@xtra.co.nz
    Web: http://valley.150m.com
    Example: [
        Thursday? 16-Nov-2000
        Monday
        Weekday? 15-Aug-2002
    ]
    library: [
        level: 'intermediate
        platform: none
        type: 'tool
        domain: 'dialects
        tested-under: none
        support: none
        license: none
        see-also: none
    ]
]

use [Weekdays Index] [
	Weekdays: system/locale/weekdays
	forall Weekdays [
		Index: index? Weekdays system/locale/weekdays
		do reduce [
			to set-word! first Weekdays Index
			to set-word! join first Weekdays "?" 'func [
				"Is Date this weekday?" Date [date!]
				]
			reduce [Index '= 'Date/weekday]
			]
		]
	]

Weekday?: func [Date [date!]][
	pick system/locale/weekdays Date/weekday
	]
