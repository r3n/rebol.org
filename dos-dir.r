REBOL[
	File: %dos-dir.r
	Date: 18-11-2005
	Title: "DIR"
	Author: "REBolek"
	Purpose: "DOS-like DIR command."
	Library: [
		level: 'intermediate
		platform: 'all
		type: [tutorial tool function]
		domain: [file-handling shell]
		tested-under: [view 1.3.1.3.1 XP]
		support: none
		license: 'public-domain
		see-also: none
	]
	Version: 1.0.0
	History: [1.0.0 18-11-2005 "first public release"]
]

dir: func  [ "Print content of a directory"
	path [any-type!] "Optional path to directory"
	/local fls
][
	if not value? 'path [path: %./]
	if not equal? #"/" last path [append path "/"]
	parse-date: func [dt][
		either none? dt [
			"unknown time and date"
		][
			dt: parse mold dt "/+"
			if equal? 10 length? dt/1 [insert head dt/1 " "]
			if 6 > length? dt/2 [append dt/2 ":00"]
			if 7 = length? dt/2 [insert head dt/2 " "]
			rejoin [dt/1 "  " dt/2]
		]
		;does not return timezone
	]
	parse-size: func [lt /local n][
		lt: mold lt
		n: 12 - length? lt
		insert/dup head lt " " n
		lt
	]
	files: copy []
	dirs: copy []
	fls: read path
	foreach file fls [
		either equal? #"/" last file [
			append dirs file
		][
			append files file
		]
	]
	sort dirs
	sort files
	foreach dr dirs [print rejoin [parse-date modified? join path dr "^-^-<DIR>^-" dr]]
	foreach fl files [print rejoin [parse-date modified? join path fl parse-size size? join path fl "^-" fl]]
]