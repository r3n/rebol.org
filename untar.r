REBOL [
	title: "UnTar"
	file: %untar.r
	author: "Marco Antoniazzi"
	email: [luce80 AT libero DOT it]
	date: 09-03-2013
	version: 0.8.3
	Purpose: "Extracts tar archives."
	History: [
		0.0.1 [17-12-2012 "Started"]
		0.8.0 [19-12-2012 "Works"]
		0.8.3 [09-03-2013 "Extracts also directories"]
		0.8.4 [17-03-2013 "Fixed first bytes and prefix bugs"]
	]
	library: [
		level: 'intermediate
		platform: 'all
		type: 'tool
		domain: [file-handling files compression]
		tested-under: [View 2.7.8.3.1]
		support: none
		license: 'public-domain
	]
	notes: {This is only a minimal implementation.}
	Usage: {
		To only list archive contents:

			untar/list/no-extract %test.tar

		To extract archive contents to a specific directory:

			untar/to %test.tar %dir/
	}
]

ctx-untar: context [
	alphadigits: "0123456789ABCDEF"
	enbase: func [value [integer!] /base base-value [integer!] /local result num][
		if value = 0 [return "0"]
		base-value: any [base-value 16]
		result: copy ""
		while [value <> 0][
			num: mod value base-value
			insert result any [alphadigits/(num + 1) "0"]
			value: (value - num) / base-value
		]
		result
	]
	debase: func [value [any-string!] /base base-value [integer!] /local num char pos][
		base-value: any [base-value 16]
		num: 0
		foreach char value [
			if none? pos: find alphadigits char [break]
			num: num * base-value + (index? pos) - 1
		]
		num
	]
	from-octal: func [value][debase/base value 8]

    set 'untar func [[catch]
		"Extracts the files in a tar archive from a binary! or a file."
		value [file! url! binary!] "The archive"
		/to dest [file! url! block!] "The directory or a block where to put extracted files (default is current dir)"
		/list "Show name and size of extracted files"
		/no-extract "Do not extract files"
		/local
		archive current-dir data rounded-size dest-file
		; tar header vars
		name mode uid gid size
		mtime checksum typeflag
		linkname magic version uname gname
		devmajor devminor prefix pad
	    ][

		either any [file? value url? value] [
			if none? file: attempt [open/read/direct/binary value] [throw make error! "Unable to open source file"]
		][
			file: value
		]
		current-dir: what-dir
		if file? dest [
			if not dir? dest [print ["Unable to read" dest ". Using current dir"] dest: current-dir]
			change-dir dest
		]

		if list [print ["Archive contents:" newline]]
		while [all [archive: copy/part file 512 0 <> first archive]][
			if binary? value [file: skip file 512] ; skip header
			parse/all archive [
				copy name 100 skip
				copy mode 8 skip
				copy uid 8 skip
				copy gid 8 skip
				copy size 12 skip
				copy mtime 12 skip
				copy checksum 8 skip
				copy typeflag 1 skip
				copy linkname 100 skip
				copy magic 6 skip
				copy version 2 skip
				copy uname 32 skip
				copy gname 32 skip
				copy devmajor 8 skip
				copy devminor 8 skip
				copy prefix 155 skip
				copy pad 12 skip
			]
			size: from-octal size
			if list [print [name size "bytes"]]
			data: copy/part file rounded-size: round/ceiling/to size 512
			if binary? value [file: skip file rounded-size]
			name: trim/with name "^@"
			prefix: trim/with prefix "^@"
			; only extract regular files and directories
			if all [any [#"5" = first typeflag #"/" = last name] not block? dest not no-extract] [make-dir to-rebol-file name]
			if all [any [#"0" = first typeflag #"^@" = first typeflag] not no-extract] [
				either block? dest [
					insert tail dest copy/part data size
				][
					if prefix <> "" [append prefix "/"]
					dest-file: to-rebol-file join prefix name
					write/binary/part dest-file data size
				]
			]
		]
		change-dir current-dir
		either block? dest [dest][exit]
	]
	;do 
	[
		untar %test.tar
		halt
	]
]