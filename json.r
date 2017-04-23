{json.r JSON to Rebol converter for REBOL(TM)
Copyright (C) 2003  Romano Paolo Tenca

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
}

rebol [
	File: %json.r
	Title: "JSON to Rebol converter"
	Author: "Romano Paolo Tenca"
	Date: 13/11/03
	Version: 0.0.1
	History: [
		0.0.1 13/11/03 "First release"
	]
	Purpose: "Convert a JSON string in Rebol data"
	Notes: {
		- parse rules can be more robust if loops are used instead of recursion
		 i used recursion to remain near the bnf grammar

		- todo: better error handling

		- todo: add JSON comments
		
		- do not handle \u0000 in strings (parsed but not converted)
		
		- because json has relaxed limits about property names
		  in the rebol object can appear words that load cannot understand
		  for example:
				;json
				{"/word": 3}
			become
				;rebol
				make object! [
					/word: 3
				]
			can be a problem if you do:
			
				load mold json-to-rebol str
				
	}
	library: [level: 'intermediate platform: 'all type: [tool] domain: [xml parse] tested-under: none support: none license: "GPL" see-also: none ]
]

json-ctx: context [
	cache: copy []
	push: func [val] [cache: insert/only cache val]
	pop: has [tmp] [tmp: first cache: back cache remove cache tmp]
	out: res: s: none
	emit: func [value][res: insert/only res value]

	;rules
	space-char: charset " ^-^/"
	space: [any space-char]
	JSON-object: [
		#"{" (push res: insert/only res copy [] res: res/-1)
		space opt property-list	space
		#"}" (res: back pop res: change res make object! first res)
	]
	property-list: [property opt [#"," space property-list]]
	property: [
		string-literal #":" (emit to-set-word s)
		space
		json-value
	]
	array-list: [json-value opt [#"," space array-list]]
	JSON-array: [
		#"[" (push emit copy [] res: res/-1)
		any array-list
		#"]" (res: pop)
	]
	json-value: [
		"true" (emit true ) |
		"false" (emit false ) |
		"null" (emit none) |
		JSON-object |
		JSON-array |
		string-literal (emit s) |
		copy s numeric-literal (emit load s)
	]
	ex-chars: charset {\"}
	chars: complement ex-chars
	escaped: charset {"\>bfnrt}
	escape-table: [
		{\"} "^""
		{\\} "\"
		{\>} ">"
		{\b} "^H"
		{\f} "^L"
		{\r} "^M"
		{\n} "^/"
		{\t} "^-"
	]
	digits: charset "0123456789"
	hex-c: union digits charset "ABCDEFabcdef"
	string-literal: [
		#"^"" copy s [any [some chars | #"\" [#"u" 4 hex-c | escaped]]] #"^"" (
			foreach [from to] escape-table [replace/all s from to]
		)
	]
	numeric-literal: [opt #"-" some digits opt [#"." some digits] opt [#"e" opt [#"+" | #"-"] some digits]]

	;public functions
	system/words/json-to-rebol: json-to-rebol: func [
		[catch]
		"Convert a json string to rebol data"
		str [string!] "The JSON string"
	][
		out: res: copy []
		either parse/all str [space json-value space][
			pick out 1
		][
			make error! "Invalid JSON string"
		]
	]
]
comment [
	str: {
		{"menu": {
		  "id": "file",
		  "string": "File:",
		  "number": -3,
		  "bolean": true,
		  "bolean2": false,
		  "null": null,
		  "array": [1, 0.1e3, null, true, false, "\t"]
			}
		}
	}
	probe result: json-to-rebol str
	halt
]
