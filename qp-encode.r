rebol [
	encoding: 'cp1250
	title: "quoted-printable encoder"
	file:  %qp-encode.r
	purpose: {Encodes the string data to quoted-printable format}
	author: "Oldes"
	email: oliva.david@seznam.cz
	date: 27-Mar-2008/9:16:36+1:00
	version: 2.0.0
	history: [
		2.0.0 [27-Mar-2008 "oldes" "completely new version"]
		1.0.0 [20-Jun-2002 "oldes" "first version"]
	]
	usage: [
		qp-encode "nejzajímavìjší"
		;== "nejzaj=EDmav=ECj=9A=ED"
	]
	comment: {More info about this encoding:
		http://www.faqs.org/rfcs/rfc2045.html}
  	library: [
		level: intermediate 
		platform: all
		type: function 
		domain: [email text-processing] 
		tested-under: none 
		support: none 
		license: 'pd 
		see-also: none
	]
]
qp-encode: func[
  "Encodes the string data to quoted-printable format"
  str [any-string!] "string to encode"
  /with chars [string! bitset!] "additional characters to encode"
  /local tmp r safe-chars rest out h
][
	r: 76
	safe-chars: charset [#"!" - #"<" #">" - #"~" #" "]
	if with [
		safe-chars: exclude safe-chars either string? chars [charset chars][chars]
	]
	rest: complement safe-chars
	out: copy ""
	parse/all copy str [
		any [
			(
				;test, if there is space on row
				if r = 0 [
					out: insert out "=^M^/"
					r: 76
				]
			)
			  copy tmp r safe-chars h: (
			  	; if there is enough safe-chars to fill the max row length
				out: insert out tmp
				unless tail? h [out: insert out "=^M^/"]
				r: 76
			)
			| copy tmp some safe-chars (
				; takes safe-chars, still some space left on row
				out: insert out tmp
				r: r - length? tmp
			)
			| copy tmp rest (
				; encode not safe-char
				if r < 3 [
					out: insert out "=^M^/"
					r: 76
				]
				out: insert out join "=" enbase/base tmp 16
				r: r - 3
			)
		]
	]
	head out
]
