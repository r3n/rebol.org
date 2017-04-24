rebol [
	title: "Function counter"
	file: %rebol-script-function-counter.r
	date: 2012-02-14
	version: 1.0.0
	author: "Maxim Olivier-Adlhoch"
	license: "public domain"

    library: [
        level: 'intermediate 
        platform: none 
        type: [tool ] 
        domain: [debug file-handling parse text-processing]
        tested-under: [view 2.7.8]
        support: none 
        license: pd
        see-also: none
    ]
	
]


;----------------------------------------------------------------------------------------------------
;
;- GLOBALS
;
;----------------------------------------------------------------------------------------------------
system-words: copy words-of system/words

word-list: []   ; word count 

failed-reads: []

paths: none


;----------------------------------------------------------------------------------------------------
;
;- FUNCTIONS
;
;----------------------------------------------------------------------------------------------------

;-------------------
;-     is-dir?()
;-------------------
is-dir?: func [path [string! file!]][
	path: to-string path
	replace/all path "\" "/"
	
	all [
		path: find/last/tail path "/"
		tail? path
	]
]


;-----------------
;-     dir-tree()
;-----------------
dir-tree: func [
	path [file!]
	/root rootpath [file! none!]
	/absolute "returns absolute paths"
	/local list item data subpath dirpath rval
][
	rval: copy []
	either root [
		unless exists? rootpath [
			to-error rejoin [ "compiler/dir-tree()" path " does not exist" ]
		]
	][
		either is-dir? path [
			rootpath: path
			path: %./
		][
			to-error rejoin [ "compiler/dir-tree()" path " MUST be a directory." ]
		]
	]
	
	dirpath: clean-path append copy rootpath path
	
	either is-dir? dirpath [
		; list directory content
		list: read dirpath
		
		; append that path to the file list
		append rval path
		
		foreach item list [
			subpath: join path item
			
			; list content of this new path item (files are returned directly)
			either absolute [
				data: dir-tree/root/absolute subpath rootpath
			][
				data: dir-tree/root subpath rootpath
			]
			if (length? data) > 0 [
				append rval data
			]
		]
	][
		if absolute [
			path: clean-path join rootpath path
		]
		; when the path is a file, just return it, it will be compiled with the rest.
		rval: path
	]
	
	if block? rval [
		rval: new-line/all  head sort rval true
	]
	
	rval
]


;--------------------------
;-     ext-part()
;--------------------------
ext-part: func [
	file [file! string! none!]
	/local ext
][
	all [
		file
		ext: find/last/tail file "."  
		copy ext ; helps GC.
	]
]

	

;--------------------------
;-     get-arg-paths()
;--------------------------
; purpose:  get all the paths from the command-line args
;
; returns:  a block of file! items or none if no paths where found.
;
; notes:    expects well formed CLI arguments, or none at all
;--------------------------
get-arg-paths: func [
	/local paths args path outpaths
][
	outpaths: none
	if args: system/script/args [
		?? args
		
		args: parse/all system/script/args " "
		?? args
		
		paths: read/lines to-rebol-file args/1
		?? paths
	
		until [
			if path: pick paths 1 [
				if string? path [
					path: to-rebol-file path
				]
				if dir? path [
					path: dirize path
				]
			]
			change paths path
			tail? paths: next paths
		]
		paths: head paths
		
		outpaths: copy []
		
		foreach path paths [
			either dir? path [
				append outpaths dir-tree/absolute dirize path	
			][
				append outpaths path
			]
		]
		outpaths
	]
]





;--------------------------
;-     filter-path-list()
;--------------------------
; purpose:  filter out unrequired files and directories
;
; inputs:   things to use and exclude from the input paths (user selection or command-line args).
;
; returns:  a new filtered block 
;--------------------------
filter-path-list: func [
	paths [block!]
	valid-extensions [string! file! block!] "List of file extensions to load scripts from, no '.' in the name.  If block! is given, a list of strings is expected"
	invalid-path-parts [string! block! file!] "any folder or its children which has this name, is invalid.  If block! is given, a list of strings is expected"
	invalid-paths [block! file!] "if block! is given, a list of explicit, absolute file! paths is expected"
	/local path pat remove?
][
	paths: copy paths
	until [
		path: first paths
	
		pat: parse/all path "/"
		remove?: false
		
		if any [
			string? valid-extensions
			file? valid-extensions
		][
			valid-extensions: compose [(to-string valid-extensions)]
		]
		
		if any [
			string? invalid-path-parts
			file? invalid-path-parts
		][
			invalid-path-parts: compose [(to-string invalid-path-parts)]
		]
		
		if any [
			string? invalid-paths
			file? invalid-paths
		][
			invalid-paths: compose [(invalid-paths)]
		]
		
		; filter invalid path parts
		foreach item invalid-path-parts [
			if find pat item [
				remove?: true
				break
			]
		]
		
		; filter complete ignored paths
		if find invalid-paths path [
			;ask ["removing path: " path ]
			remove?: true
		]
		
		; filter by FILENAME extension (incidently removes most dir paths)
		if all [
			not remove?
			not find valid-extensions (ext-part last pat)
		][
			remove?: true
		]
		
		either remove? [
			; removing the current item implies we are now at next item.
			remove paths
		][
			paths: next paths
		]
		tail? paths
	]
	head paths
]





;--------------------------
;-     count-word()
;--------------------------
; purpose:  given a single word, determine if it should be counted or not based on its type and spelling.
;
; inputs:   a word (binding non-relevant)
;--------------------------
count-word: func [
	word [word! path!] 
	/local counter
][
	
	if path? word [
		word: first to-block word
	]
	
	if all [
		find system-words :word 
		any-function?  get/any in system/words :word
	][
		;prin word
		either counter: find word-list :word [
			change next counter add second counter 1
		][
			append word-list reduce [word 1]
		]
	]
]




;--------------------------
;-     count-words()
;--------------------------
; purpose:  counts the occurence of system function words in files
;
; inputs:   a list of files to scan
;
; returns:  word-count block consisting of word and its occurences in all files
;--------------------------
count-words: func [
	"counts the occurence of system function words in files"
	paths [block!] "a block of file! paths to scan for words... directories are ignored."
][
	rule: [
		some [
			set val word! ( count-word val )
			| set val path! (count-word val)
			| into rule
			| 
			skip
		]
	]
	
	failed-reads: copy []
	foreach path paths [
		path: clean-path path
		print [ "counting: "  path]
		either all [
			not is-dir? path ; just in case
			exists? path 
			script: attempt [load/all path]
		][
			parse script rule
		][
			print "   file read failed!"
			append failed-reads path
		]
	]
	;----------------------------
	; cleanup results
	;----------------------------
	sort/skip/compare/reverse word-list 2 2 ; sort by count, highest count first
	new-line/skip word-list true 2          ; setup the data as two columns 
]




;----------------------------------------------------------------------------------------------------
;
;- SETUP
;
;----------------------------------------------------------------------------------------------------
exclude-path-parts: [ "distribution" "distributions" "backup" "libs-backup" "encap"]
exclude-paths: [%/c/dev/projects/glass/encap/glass-package-source.r]
file-types:    [ "r"  "r3" ]


; uncomment if you want to specify the list directly within the script
;paths: dir-tree/absolute clean-path %./


;----------------------------------------------------------------------------------------------------
;
;- MAIN EXECUTION
;
;----------------------------------------------------------------------------------------------------

;----------------------------
;- generate file list
;----------------------------
unless paths [
	unless paths: get-arg-paths [
		if (path: request-file/only/keep/title/file "Pick file to count, type '[dir]' as filename to list the folder itself" "open" "[dir]") [
			path: to-file dehex path
			;?? path
			either (spath: find/last/tail path "/") = %"[dir]" [
				;?? head spath
				clear spath
				path: head spath
				paths: dir-tree/absolute path
			][
				paths: reduce [path]
			]
		]
	]
]

unless paths [
	halt
]

paths: FILTER-PATH-LIST paths  file-types   exclude-path-parts  exclude-paths



;----------------------------
; accumulate & display word count for ALL files
;----------------------------
count-words paths


probe word-list 

unless empty? failed-reads [
	print "These files failed to load!:"
	probe new-line/all failed-reads true
]


print ["^/^/Count-words:"]
help count-words

print ["^/^/^/try counting another file or foler, using COUNT-WORDS"]
halt
