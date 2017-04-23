REBOL [
    Title: "CSV"
    Date: 29-Sep-2002
    Name: 'CSV
    File: %CSV.r
    Purpose: ".CSV file manipulation functions."
    eMail: Al.Bri@xtra.co.nz
    Web: http://valley.150m.com
    Example: [
    write %Test.csv Mold-CSV [
        ["Column One" "Column Two" "Total Column"] 
        [1 2 3] 
        [2 3 5] 
        [3 4 7]
    ] 
    read %Test.csv 
    delete %Test.csv
]
    library: [
        level: 'beginner 
        platform: none 
        type: 'tool 
        domain: 'DB 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

Mold-CSV: function [
	"Molds an array of values into a CSV formatted string."
	Array [block!]	"The array of values."
	] [Page Line Heading Type] [
	Page: make block! length? Array
	Line: make string! 1000
	if parse Array/1 [
		some [
			set Heading [word! | string!] into [
				'string! (Type: "String")
				| 'date! (Type: "Date")
				| 'logic! (Type: "Boolean")
				| 'integer! (Type: "Int")
				| 'decimal! (Type: "float")
				] (
				all [
					string? Heading
					found? find Heading #","
					Heading: mold Heading
					]
				repend Line [
					Heading #":" Type #","
					]
				)
			]
		end
		] [
		Array: next Array
		remove back tail Line
		append Line newline
		append Page copy Line
		]
	clear Line
	foreach Row Array [
		foreach Item Row [
			all [
				string? :Item
				found? find Item #","
				Item: mold Item
				]
			all [
				none? :Item
				Item: #" "	; A blank/space works better as a "none" value.
				]
			insert tail Line join :Item #","
			]
		remove back tail Line
		append Line newline
		append Page copy Line
		clear Line
		]
	rejoin Page
	]
