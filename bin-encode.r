REBOL [
	title: "Encode binary data to plain text and decode it"
	file: %bin-encode.r
	author: "Marco Antoniazzi"
	email: [luce80 AT libero DOT it]
	date: 14-12-2012
	version: 0.9.0
	Purpose: "Converts from and to Base64, UUencode, XXencode, BinHex 4.0, Ascii85, FScode, Quoted-printable, Q-encoding, Percent-encoding"
	History: [
		0.0.1 [01-12-2012 "Started"]
		0.9.0 [14-12-2012 "Finished"]
	]
	library: [
		level: 'intermediate
		platform: 'all
		type: 'tool
		domain: [text]
		tested-under: [View 2.7.8.3.1]
		support: none
		license: "Public domain"
	]
	Notes: {
		NO WARRANTIES. USE AT YOUR OWN RISK.
		
		Feel free to improve this script
		Bugs:
		- Decoded data of UUencode, XXencode and BinHex 4.0 may contain extra null bytes
		- Checksums checks not implemented
	}
]

ctx-bin-enc: context [
	b64:	{ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/} ; last 2 chars can vary in different implementations
	gedcom:	{./0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz} ; not used but useful (also used by Apache)
	uu:		{ !"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^^_}
	xx:		{+-0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz}
	bhex:	{!"#$%&'()*+,-012345689@ABCDEFGHIJKLMNPQRSTUVXYZ[`abcdefhijklmpqr}

	b64-encode: func [
		value [binary!] "The data to convert"
		decoder [any-string!] "The string used for the translation (see above)"
		trail [logic! string!] "Optionals trailing characters"
		/local
		pad mask dst src out
		][
		pad: 3 - mod length? value 3
		if pad = 3 [pad: 0]
		insert/dup tail value #"^@" pad
		mask: to-integer #{0000003F}
		dst: copy {}
		while [not tail? value] [
			src: to-integer copy/part value 3
			out: mask and shift/logical src 18
			insert tail dst pick decoder out + 1
			out: mask and shift/logical src 12
			insert tail dst pick decoder out + 1
			out: mask and shift/logical src 6
			insert tail dst pick decoder out + 1
			out: mask and shift/logical src 0
			insert tail dst pick decoder out + 1
			value: skip value 3
		]
		if trail <> true [
			if pad >= 1 [change back tail dst trail]
			if pad >= 2 [change back back tail dst trail]
		]
		dst
	]
	split-in-lines: func [
		value [any-string!] length [integer!] begin [any-string! function!] end [any-string!] /deco decoder [string!]
		/local
		dst line beg
		][
		dst: copy {}
		until [
			line: copy/part value length
			beg: either function? :begin [begin decoder][begin]
			insert line beg
			insert tail line end
			append dst line
			value: skip value length
			tail? value
		]
		dst
	]
	set 'base64-encode: func [
		{Converts data to Base64 encoding}
		value [any-string!] "The string to convert"
		/with chars [any-string!] "The alphabet to use for encoding"
		/wrap line [integer!] "Insert a newline after every line characters (default is no wrap)"
		/no-pad {Avoid padding with trailing #"="}
		/local
		dst
		][
		value: to-binary value
		chars: any [chars b64] ; this can change in different implementations

		dst: b64-encode value chars any [no-pad "="]

		; insert line separators
		if line [dst: split-in-lines dst line "" "^/"]
		head dst
	]
	int-to-bin: func [num [integer!]][debase/base to-hex num 16]
	get-char: func [src decoder pos [integer!] shif /local c][
		c: any [find/case decoder to-char pick src pos ""]
		shift/left ((index? c) - 1) shif
	]
	b64-decode: func [
		value [string!] "The data to convert"
		decoder [string!] "The string used for the translation (see above)"
		/trail char [string!] "Optional trailing char(s)"
		/length end [integer!] "Length of original data"
		/local
		pad dst src out
		][
		pad: 4 - mod length? value 4
		if pad = 4 [pad: 0]
		insert/dup tail value #"^@" pad
		if not end [
			end: (length? value) / 4 * 3
			if end < 4 [end: 4]
		]
		dst: copy #{}
		while [not tail? value] [
			if char [
				if value/3 = char/1  [value/3: #"^@" end: end - 1]
				if value/4 = char/1  [value/4: #"^@" end: end - 1]
			]
			src: copy/part value 4
			out: get-char src decoder 1 18
			out: out or get-char src decoder 2 12
			out: out or get-char src decoder 3 6
			out: out or get-char src decoder 4 0
			insert tail dst next int-to-bin out 
			value: skip value 4
		]
		head clear at dst end + 1
	]
	set 'base64-decode: func [
		{Decodes a string encoded with Base64}
		value [string!] "The encoded string to convert"
		/with chars [any-string!] "The last two characters used in decoding characters (defaut are +/)"
		][
		value: copy value
		trim/with value " ^-^/^M" ;remove white spaces and newlines
		chars: any [chars b64] ; this can change in different implementations

		b64-decode/trail value chars "="
	]

	uuxx-encode: func [
		value name decoder trail
		/local dst orig-len linelen
		][
		value: to-binary value
		orig-len: length? value

		dst: b64-encode value decoder true

		linelen: func [decoder /local rest line][
			rest: orig-len // 45
			line: either rest = orig-len [orig-len][45]
			orig-len: orig-len - 45
			decoder/(line + 1)
		]
		; insert line separators
		dst: split-in-lines/deco dst 60 :linelen "^/" decoder
		name: any [name ""]
		insert dst join "begin 644 " [name "^/^/"]
		if (length? value) <= 61 [insert tail dst "^/"]
		insert tail dst join trail "^/end"
		head dst
	]
	uuxx-decode: func [[catch]
		value decoder trail
		/local
		pos len start last-head
		][
		value: any [find/tail value "^/" value]; skip header
		; calculate "real" length
		pos: value len: 0
		while [pos: find/tail pos "^/"] [
			if pos/1 = trail [break]
			len: len + (index? any [find/case decoder pos/1 ""]) - 1
		]
		; remove unwanted chars
		value: next value
		start: skip value 1 ; skip first char
		pos: decoder/46 ; line header
		replace/all value join "^/" pos "" ; remove newlines and line headers
		if last-head: find value "^/" [
			if last-head/2 <> trail [remove/part last-head 2]; remove last line header
			clear find last-head "^/" ; remove tail
		]

		b64-decode/length start decoder len
	]
	set 'uu-encode: func [
		{Converts data to UUencoding}
		value [any-string!] "The data to convert"
		/file name [string!] "Name of output file inserted in output string"
		][
		name: any [name ""]
		uuxx-encode value name uu "`"
	]
	set 'uu-decode: func [
		{Decodes a string uu-encoded}
		value [string!] "The encoded string to convert"
		][
		if not equal? "begin" copy/part value 5 [throw make error! "Wrong header in UU-encoded data"]
		uuxx-decode value uu #"`"
	]
	set 'xx-encode: func [
		{Converts data to XXencoding}
		value [any-string!] "The string to convert"
		/file name "Name of output file inserted in output string"
		][
		name: any [name ""]
		uuxx-encode value name xx " "
	]
	set 'xx-decode: func [
		{Decodes a string XX-encoded}
		value [string!] "The encoded string to convert"
		][
		if not equal? "begin" copy/part value 5 [throw make error! "Wrong header in XX-encoded data"]
		uuxx-decode value xx #" "
	]

	set 'binhex4-encode: func [
		{Converts data to BinHex 4.0 encoding}
		value [any-string!] "The data to convert"
		/local
		dst
		][
		value: to-binary value

		dst: b64-encode value bhex true

		insert dst ":"
		append dst ":"
		; insert line separators
		dst: split-in-lines dst 64 "" "^/"
		insert dst "(This file must be converted with BinHex 4.0)^/^/"
		head dst
	]
	set 'binhex4-decode: func [
		{Decodes a string encoded with BinHex 4.0}
		value [string!] "The encoded string to convert"
		/local
		start
		][
		value: any [find/tail value "^/^/" value]; skip header
		start: remove/part head value skip value 1 ; skip first char
		trim/with start " ^-^/^M" ; remove white spaces and newlines
		clear find start ":" value ; remove tail

		b64-decode start bhex
	]

	; see Jeff Atwood http://www.codinghorror.com/blog/archives/000410.html. Based on C code from http://www.stillhq.com/cgi-bin/cvsweb/ascii85/
	_encodedBlock: [0 0 0 0 0]
	a85-encode-tuple: func [count dst _tuple offset][
		for i 5 1 -1 [
			_encodedBlock/(i): _tuple // 85 + offset 
			_tuple: _tuple / 85
		]

		for i 1 count 1	[append dst to-char _encodedBlock/(i)]
	]
	a85-encode: func [
		value [binary!]
		offset [integer!]
		trim
		/fs
		/local
		dst count _tuple
		][
		dst: make string! (length? value) * 5 / 4 

		count: 1
		_tuple: 0
		foreach byte value [
			either count >= 4 [
				_tuple: _tuple or byte
				either all [not fs _tuple = 0] [ ; 4 nulls
					insert tail dst "z" 
				][
					either all [not fs trim _tuple = 538976288][ ; 4 spaces
						insert tail dst "y" 
					][
						a85-encode-tuple 5 dst _tuple offset
					]
				]
				_tuple: 0
				count: 1
			][
				_tuple: _tuple or shift/left byte 24 - ((count - 1) * 8) 
				count: count + 1
			]
		]
		; if we have some bytes left over at the end..
		if count > 1 [
			either fs [
				count: 5 - count
				a85-encode-tuple 5 dst shift/logical _tuple (count * 8) 42
				change/part/dup skip tail dst -5 "#" count count
			][
				a85-encode-tuple count dst _tuple offset
			]
		]
		head dst
	]
	set 'ascii85-encode func [
		{Converts data into a plain text Ascii85 encoding}
		value [any-string!] "The string to convert"
		/wrap line [integer!] "Insert a newline after every line characters (default is no wrap)"
		/trim "Tries to reduce encoded length by also encoding 4 spaces with a 'y' (not compatible with Adobe)"
		/local
		dst
		][
		value: to-binary value

		dst: a85-encode value 33 trim

		insert dst "<~"
		append dst "~>"
		; insert line separators
		if line [dst: split-in-lines dst line "" "^/"]
		dst 
	]
	pow85: reduce [85 * 85 * 85 * 85 85 * 85 * 85 85 * 85 85 1]
	a85-decode-tuple: func [bytes _tuple][
		bytes: head clear skip to-hex _tuple bytes * 2
		debase/base bytes 16
	]
	a85-decode: func [[catch throw]
		value [string!]
		/asciioff offset [integer!]
		/fs
		/local
		dst count processChar _tuple
		][
		dst: copy #{}

		count: 0
		processChar: false
		_tuple: 0

		foreach char value [
			case [
				all [not fs char = #"z"] [
					if count <> 0 [throw make error! "The character 'z' is invalid inside an ASCII85 block." ]
					insert/dup tail dst #"^@" 4
					processChar: false
				]
				all [not fs char = #"y"] [
					if count <> 0 [throw make error! "The character 'y' is invalid inside an ASCII85 block." ]
					insert/dup tail dst #" " 4
					processChar: false
				]
				true [
					either any [char < #"!" char > #"~"][
						;	throw make error! join "Bad character '" [char "' found. ASCII85 only allows characters '!' to 'u'."]]
						processChar: false
						value: next value
					][
						processChar: true
					]
				]
			]

			if processChar [
				_tuple: _tuple + ((to-integer char - offset) * pow85/(count + 1))
				count: count + 1
				if count = 5 [
					insert tail dst a85-decode-tuple 4 _tuple
					_tuple: 0
					count: 0
				] 
			]
		]

		; if we have some bytes left over at the end..
		if count <> 0 [
			if count = 1 [throw make error! "The last block of ASCII85 data cannot be a single byte."]
			count: count - 1
			_tuple: _tuple + pow85/(count + 1)
			insert tail dst a85-decode-tuple count _tuple
		]

		head dst 
	]
	set 'ascii85-decode func [[catch]
		{Decodes a string encoded with Ascii85}
		value [string!] "The encoded string to convert"
		][
		value: copy value
		trim/with value " ^-^/^M" ;remove white spaces and newlines
		; strip prefix and suffix if present
		replace value "<~" ""
		replace value "~>" ""

		a85-decode/asciioff value 33

	]

	; see http://aminet.net/util/arc/FSCode.lha
	set 'fs-encode func [
		{Converts data into a plain text using FS encoding (only single-part)}
		value [any-string!] "The string to convert"
		/wrap line [integer!] "Insert a newline after every line characters (default is no wrap)"
		/local
		dst len
		][
		len: length? value: to-binary value

		dst: a85-encode/fs value 42 false

		; insert line separators
		if line [dst: split-in-lines dst line "" "^/"]

		insert dst "!start FSfile^/"
		append dst join "^/!end " [len " " 0]
		dst 
	]
	set 'fs-decode func [[catch]
		{Decodes a string encoded with FScode (only single-part)}
		value [string!] "The encoded string to convert"
		/local
		dst digit space fs end
		][
		digit: charset [#"0" - #"9"]
		space: charset " ^-"
		fs: [thru "!start" any space copy fname to "^/" "^/"  
			copy value to "!end" "!end" any space copy size some digit
			to end
		]
		if not parse/all value fs [throw make error! "Not a proper Fscode string"]
		trim/with value " ^-^/^M" ; remove white spaces and newlines
		; convert last padded chars
		end: 0 dst: skip tail value -5
		while [not tail? dst] [if dst/1 = #"#" [end: end + 1 dst/1: #"*"] dst: next dst]

		dst: a85-decode/fs/asciioff value 42
		
		if end > 0 [remove/part skip tail dst -4 end]

		head dst 
	]
	
	non-printable: charset [#"^(00)" - #"^(08)" #"^(0A)" - #"^(1F)" #"^(3D)" #"^(7E)" - #"^(FF)"]
	set 'qp-encode: func [
		{Converts data to quoted-printable encoding}
		value [any-string!] "The string to convert"
		/no-wrap "Do not truncate output (default is to keep lines shorter then 75 bytes)"
		/space
		/local
		dst len char hex
		][
		dst: copy ""
		len: 1
		while [not tail? value][
			char: first value
			; split output in lines with at most 76 bytes
			unless no-wrap [if (len > 73) [insert tail dst "=^/" len: 1]] ; truncate line before it is too late
			if find non-printable char[
				hex: back back tail form to-hex to-integer char
				char: join "=" hex
				len: len + 2
			]
			if all [space char = #" "][char: "_"]
			insert tail dst char
			len: len + 1
			value: next value
		]
		head dst
	]
	set 'qp-decode: func [
		{Decodes a string encoded as quoted-printable}
		value [string!] "The encoded string to convert"
		/space
		/local
		dst char
		][
		dst: copy #{}
		while [not tail? value][
			char: first value
			if char = #"=" [
				either #"^/" = second value [
					char: ""
					value: skip value 1
				][
					char: copy/part next value 2
					char: to-char to-integer to-issue char
					value: skip value 2
				]
			]
			if all [space char = #"_"] [char: " "]
			insert tail dst char
			value: next value
		]
		head dst
	]
	set 'q-encode: func [
		{Converts data to q-encoding}
		value [any-string!] "The string to convert"
		/local
		dst
		][
		non-printable: union non-printable charset "_"
		dst: qp-encode/no-wrap/space value
		non-printable: exclude non-printable charset "_" ; restore original charset
		dst
	]
	set 'q-decode: func [
		{Decodes a string encoded with q-encoding}
		value [string!] "The encoded string to convert"
		][
		qp-decode/space value
	]

	reserved: complement charset {ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.~}
	set 'percent-encode func [
		{Converts data to percent encoding}
		value [any-string!] "The string to convert"
		/www-form "The output must be of type application/x-www-form-urlencoded"
		/local
		dst pos char hex
		][
		dst: copy to-string value
		pos: dst
		while [pos: find pos reserved][
			char: first pos
			hex: back back tail form to-hex to-integer char
			char: join "%" hex
			pos: change/part pos char 1
		]
		if www-form [replace/all head dst " " "+"]
		head dst
	]
	set 'percent-decode: func [
		{Decodes a string encoded with percent encoding}
		value [string!] "The encoded string to convert"
		/www-form "The input is of type application/x-www-form-urlencoded"
		/local
		dst pos char
		][
		dst: copy to-binary value
		pos: dst
		while [pos: find pos "%"][
			char: copy/part next pos 2
			char: to-char to-integer to-issue char
			pos: change/part pos char 3
		]
		if www-form [replace/all head dst "+" " "]
		head dst
	]

]
;comment [
do [
	probe s: {Man is distinguished,= not only by his reason, but by this singular passion from other animals, which is a lust of the mind, that by a perseverance of delight in the continued and indefatigable generation of knowledge, exceeds the short vehemence of any carnal pleasure.}
	;s: "Cat";
	;s: "Man"

	print "^/Base64 encode^/"
	probe s: base64-encode/wrap s 40 ; random wrap length
	print "^/Base64 decode^/"
	probe s: to-string base64-decode s
	print "^/UUencode^/"
	probe s: uu-encode/file s "test.txt"
	print "^/UUdecode^/"
	probe s: to-string uu-decode s
	print "^/XXencode^/"
	probe s: xx-encode s
	print "^/XXdecode^/"
	probe s: to-string xx-decode s
	print "^/BinHex 4.0 encode^/"
	probe s: binhex4-encode s
	print "^/BinHex 4.0 decode^/"
	probe s: to-string binhex4-decode s
	print "^/Ascii85 encode^/"
	probe s: ascii85-encode/wrap s 75
	print "^/Ascii85 decode^/"
	probe s: to-string ascii85-decode s
	print "^/Quoted-printable encode^/"
	probe s: qp-encode s
	print "^/Quoted-printable decode^/"
	probe s: to-string qp-decode s
	print "^/Q-encoding encode^/"
	probe s: q-encode s
	print "^/Q-encoding decode^/"
	probe s: to-string q-decode s
	print "^/Percent encode^/"
	probe s: percent-encode s
	print "^/Percent decode^/"
	probe s: to-string percent-decode s
	print "^/FScode encode^/"
	probe s: fs-encode/wrap s 75
	print "^/FScode decode^/"
	probe s: to-string fs-decode s

	halt
]