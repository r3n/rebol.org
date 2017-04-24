REBOL[
	File: %dos-dir.r
	Date: 13-7-2007
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
	Version: 1.1.0
	History: [
		1.1.0 13-7-2007 "wildcard support added"
		1.0.0 18-11-2005 "first public release"
	]
]

match: func [
	"Match a string againts wildcards"
	string 
	rules
	/local chars rules= =bset
][
	chars: charset [#"a" - #"z" #"A" - #"Z" #"0" - #"9" "+-!_."]
	rules=: copy []
	parse rules [
		some [
			[
				#"[" (=bset: charset "")
				some [
					copy val1 chars
					#"-"
					copy val2 chars (insert bset charset compose [(val1) - (val2)])
				|	copy val chars (insert =bset val)
				]
				#"]"  (append rules= =bset)
			]
		|	#"*"	(append rules= 'thru)
		|	#"?"	(append rules= [1 skip])
		|	copy val chars (append rules= val)
		]
	]
	if equal? 'thru last rules= [remove back tail rules=] 
	append rules= [to end] ;really?
	parse string rules= 
]

dir: func  [ "Print content of a directory"
	path [any-type!] "Optional path to directory"
	/local fls match-file
][
	if not value? 'path [path: %./]
	either equal? #"/" last path [
		;list directory
		match-file: %*
	][
		;list matching files (?)
		;append path "/"
		set [path match-file] split-path path
	]
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
	foreach fl files [
		if match fl match-file [
			print rejoin [parse-date modified? join path fl parse-size size? join path fl "^-" fl]
		]
	]
	path
]