REBOL [
    Title: "URI"
    Date: 22-Dec-2002
    Name: 'URI
    Version: 1.1.1
    File: %uri.r
    Author: "Andrew Martin"
    Needs: [%Common%20Parse%20Values.r]
    Purpose: "URI parse rules."
    eMail: Al.Bri@xtra.co.nz
    Web: http://valley.150m.com
    library: [
        level: 'advanced 
        platform: 'all 
        type: 'tool 
        domain: [other-net text-processing] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

make object! [
	Char: union AlphaDigit charset "-_~+*'"
	Escape: [#"%" Hex Hex]
	Chars: [some [Char | Escape]]
	User: [some [Char | Escape | #"."]]
	Domain-Label: Chars
	Domain: [Domain-Label any [#"." Domain-Label]]
	IP-Address: [Digits #"." Digits #"." Digits #"." Digits]
	Host: [Domain | IP-Address]
	eMail: [User #"@" Host]
	Pass: Chars
	Port: [1 4 Digit]
	User-Pass-Host-Port: [
		[User #":" Pass #"@" Host #":" Port]
		| [User #":" Pass #"@" Host]
		| [User #":" Host]
		| [Host #":" Port]
		| [Host]
		]
	Fragment: [#"#" Chars]
	Query: [
		#"?" [
			any [opt #"&" Chars #"=" [Chars | Absolute-Path] | Chars]
			]
		]
	Fragment_Or_Query: [Fragment | Query]
	Extension: [#"." 1 4 Chars]
	File: [Chars opt [#"." Chars]]
	Path: [some ["../" | "./" | [File #"/"]]]
	Relative-Path: [
		Path opt File opt Extension opt Fragment_Or_Query
		| opt Path File opt Extension opt Fragment_Or_Query
		| opt Path opt File Extension opt Fragment_Or_Query
		| opt Path opt File opt Extension Fragment_Or_Query
		]
	Absolute-Path: [#"/" opt Relative-Path]
	Net-Path: ["//" User-Pass-Host-Port opt [Absolute-Path]]
	Scheme: [Alpha some Char]
	URL: [Scheme #":" Net-Path]
	Local-File: [#"%" [Absolute-Path | Relative-Path]]
	set 'URI [eMail | URL | Local-File]
	]
