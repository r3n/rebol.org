REBOL [
    Title: "Common Parse Values"
    Date: 24-Sep-2002
    Name: 'Common-Parse-Values
    Version: 1.3.0
    File: %common-parse-values.r
    Author: "Andrew Martin"
    Needs: [%Map.r]
    Purpose: "Common Parse Values"
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

Octet: charset [#"^(00)" - #"^(FF)"]
Char: charset [#"^(00)" - #"^(7F)"]
Digit: charset "0123456789"
Digits: [some Digit]
Upper: charset [#"A" - #"Z"]
Lower: charset [#"a" - #"z"]
Alpha: union Upper Lower
AlphaDigit: union Alpha Digit
AlphaDigits: [some AlphaDigit]
Control: charset [#"^(00)" - #"^(1F)" #"^(7F)"]
Hex: union Digit charset [#"A" - #"F" #"a" - #"f"]
HT: #"^-"
SP: #" "
LF: #"^(0A)"
LWS: charset reduce [SP HT]
LWS*: [some LWS]
LWS?: [any LWS]
WS: charset reduce [SP HT newline CR LF]
WS*: [some WS]
WS?: [any WS]
Graphic: charset [#"^(21)" - #"^(7E)"]
Printable: union Graphic charset " "
make object! [
	set 'Time^ [1 2 Digit #":" 1 2 Digit opt [#":" 1 2 Digit]]
	Long-Months: remove map Rebol/locale/Months func [Month [string!]] [
		reduce ['| copy Month]
		]
	Short-Months: remove map Rebol/locale/Months func [Month [string!]] [
		reduce ['| copy/part Month 3]
		]
	set 'Month^ [1 2 Digit | Long-Months | Short-Months]
	Separator: charset "/-"
	set 'Date^ [
		[1 2 Digit Separator Month^ Separator [4 Digit | 2 Digit]]
		| [4 Digit Separator Month^ Separator 1 2 Digit]
		]
	Forbidden: {:*?"<>|/\.}	; A Windows file name cannot contain any of these characters.
	Permitted: complement charset Forbidden
	set 'File^ [some Permitted #"." some Permitted]
	set 'Folder^ [[#"/" any [some Permitted #"/"]] | [opt #"/" some [some Permitted #"/"]]]
	set 'Folder-File^ [Folder^ File^]
	]
