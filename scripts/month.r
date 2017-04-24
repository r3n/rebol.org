REBOL [
    Title: "Month"
    Date: 31-Aug-2002
    Name: 'Month
    Version: 2.0.0
    File: %month.r
    Author: "Andrew Martin"
    Purpose: "Creates Month functions."
    eMail: Al.Bri@xtra.co.nz
    Web: http://valley.150m.com
    Example: [
    November? 16-Nov-2000 
    Month? 16-Nov-2002
]
    library: [
        level: 'advanced 
        platform: none 
        type: 'tool 
        domain: none 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

use [Months Index] [
	Months: system/locale/months
	forall Months [
		Index: index? Months system/locale/months
		do reduce [
			to set-word! join first Months "?" 'func [
				"Is Date this month?" Date [date!]
				]
			reduce [Index '= 'Date/Month]
			]
		]
	]

Month?: func [
	"Returns the Month name of the Date."
	Date [date!]
	][
	pick system/locale/months Date/month
	]
