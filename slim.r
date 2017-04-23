rebol [
	; -- basic rebol header --
	file:       %slim.r
	version:    0.9.11
	date:       2006-10-19
	title:      "SLiM - STEEL | Library Manager"
	author:     "Maxim Olivier-Adlhoch"
	copyright:  "Copyright (c) 2002-2006, Maxim Olivier-Adlhoch"
	
	; -- remark stuff --
	status:     'release-candidate

	; -- extended rebol header --
	purpose:    "Loads and Manage Run-time linkable libraries.  Also serves as a specification."
	notes:      "Requires a minimal amount of setup (one or two rebol lines of code) in order to function."
	web:        http://www.pointillistic.com/open-REBOL/moa/steel/slim/index.html
	e-mail:     "%moliad--aei--ca" ; fill in @ and .
	original-author: "Maxim Olivier-Adlhoch"

	library: [
		level: 'intermediate
		platform: 'all
		type: [ tool module ]
		domain: [ external-library file-handling ]
		tested-under: [win view 1.2.1 view 1.2.10 core 2.5.6]
		support: "same as author"
		license: 'mit
		see-also: http://www.pointillistic.com/open-REBOL/moa/steel/slim/index.html
	]

	todo: http://www.pointillistic.com/open-REBOL/moa/steel/slim/slim-to-do.html

	
	
	license:    {Copyright (c) 2004-2006, Maxim Olivier-Adlhoch

		Permission is hereby granted, free of charge, to any person obtaining a copy of this software 
		and associated documentation files (the "Software"), to deal in the Software without restriction, 
		including without limitation the rights to use, copy, modify, merge, publish, distribute, 
		sublicense, and/or sell copies of the Software, and to permit persons to whom the Software 
		is furnished to do so, subject to the following conditions:
		
		The above copyright notice and this permission notice shall be included in all copies or 
		substantial portions of the Software.}
		
	disclaimer: {THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
		INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR 
		PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE 
		FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ]
		ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN 
		THE SOFTWARE.}
]



;-----------------------------------------------------------------
;- SLiM OBJECT / START
;-----------------------------------------------------------------
SLiM: make object! [
	id:         1       ; this holds the next serial number assigned to a library


	slim-path: what-dir


	; LIBRARY LIST
	; each time a library is opened, its name and object pointer get dumped here.
	; this allows us to share the same object for all calls
	libs: []


	; LIBRARY PATHS
	; a list of paths which describe where you place your libs
	; the last spec is the cache dir (so if you have only one dir,
	; then its both a library path and cache path.)
	paths: []
	
	; SLIMLINK SETUP
	; if this is set to false, then all open calls use the paths dir and use find-path and do.
	; otherwise it will only do libs directly from the link-cache variable instead.
	linked-libs: none


	;----------------
	; open-version
	open-version: 0.0.0     ; use this to store the version of currently opening module. is used by validate, afterwards.


	;----------------
	;-    MATCH-TAGS()
	;----
	match-tags: func [
		"return true if the specified tags match an expected template"
		template [block!]
		tags [block! none!]
		/local tag success
	][
		success = False
		if tags [
			foreach tag template [
				if any [
					all [
						; match all the tags at once
						block? tag
						((intersect tag tags) = tag)
					]
					
					all [
						;word? tag
						found? find tags tag
					]
				][
					success: True
					break
				]
			]
		]
		success
	]
	
	
	;----------------
	;-    VPRINT()
	;----
	verbose:    false   ; display console messages
	verbose-count: 0    ; every vprint depth gets calculated here
	vtabs: []
	vtags: none			; setting this to a block of tags to print, allows vtags to function, making console messages very selective.
	vconsole: none ; setting this to a block, means all console messages go here instead of in the console and can be spied on later !"
	
	vprint: func [
		"verbose print"
		data
		/in "indents after printing"
		/out "un indents before printing use none so that nothing is printed"
		/always "always print, even if verbose is off"
		/error "like always, but adds stack trace"
		/tags ftags "only effective if one of the specified tags exist in vtags"
		/local line do
	][
		;if error [always: true]
		verbose-count: verbose-count + 1
		if any [
			error
			all [
				any [verbose always] 
				either (block? vtags) [
					match-tags vtags ftags
				][
					true
				]
			]
		][
			
			line: copy ""
			if out [remove vtabs]
			append line vtabs
			switch/default (type?/word data) [
				object! [append line mold first data]
				block! [append line rejoin data]
				string! [append line data]
				none! []
			][append line mold reduce data]
			
			if in [insert vtabs "^-"]
			either vconsole [
				append/only vconsole line
			][
				print replace/all line "^/" join "^/" vtabs 
			]
		]
	]
	
	
	
	
	
	;----------------
	;-    VPROBE()
	;----
	vprobe: func [
		"verbose probe"
		data
		/in "indents after probing"
		/out "un indents before probing"
		/always "always print, even if verbose is off"
		/tags ftags "only effective if one of the specified tags exist in vtags"
		/error "like always, but adds stack trace"
		/local line
	][
		;if error [always: true]
		verbose-count: verbose-count + 1
		if any [
			error
			all [
				any [verbose always] 
				either (block? vtags) [
					match-tags vtags ftags
				][
					true
				]
			]
		][
			if out [remove vtabs]
			switch/default (type?/word data) [
				object! [line: mold/all data]
			][line: mold data]
			
			print rejoin [ vtabs line]
			if in [insert vtabs "^-"]
			
		]
		data
	]
	
	
	
	
	
	;----------------
	;-    VON()
	;----
	von: func [/tags lit-tags ][
		verbose: on
		if tags [
			unless block? vtags [
				vtags: copy []
			]
			unless block? lit-tags [
				lit-tags: reduce [lit-tags]
			]
			vtags: union vtags lit-tags 
		]
			
	]
	
	
	;----------------
	;-    VOFF()
	;----
	voff: func [/tags dark-tags] [
		either tags [
			vtags: exclude vtags dark-tags
		][
			verbose: off
		]		
	]
	
	
	;----------------
	;-    VOUT()
	;----
	vout: func [
		/always
		/error
		/tags ftags
		/return rdata ; use the supplied data as our return data, allows vout to be placed at end of a function
	][
		;if error [always: true]
		verbose-count: verbose-count + 1
		if any [
			error
			all [
				any [verbose always] 
				either (block? vtags) [
					match-tags vtags ftags
				][
					true
				]
			]
		][
			vprint/out/always/tags  "]" ftags
		][
			vprint/out/tags "]" ftags
		]
		; this mimics print's functionality where not supplying return value will return unset!, causing an error in a func which expects a return value.
		either return [
			rdata
		][]
	]
	
	
	
	;----------------
	;-    VIN()
	;----
	vin: func [
		txt
		/always
		/error
		/tags ftags [block!]
	][
		;if error [always: true]
		verbose-count: verbose-count + 1
		if any [
			error
			all [
				any [verbose always] 
				either (block? vtags) [
					match-tags vtags ftags
				][
					true
				]
			]
		][
			vprint/in/always/tags join txt " [" ftags
		][
			vprint/in/tags join txt " [" ftags
		]
	]
	
	
	
	;----------------
	;-    V??()
	;----
	v??: func [
	    {Prints a variable name followed by its molded value. (for debugging) - (copied from REBOL mezzanines)}
	    'name
	    /tags ftags [block!]
	][
		either tags [
	   		vprint/tags either word? :name [head insert tail form name reduce [": " mold name: get name]] [mold :name] ftags
	   	][
	   		vprint either word? :name [head insert tail form name reduce [": " mold name: get name]] [mold :name]
		]   		
	    :name
	]
	
	
	
	
	
	;----------------
	;-    VFLUSH()
	;----
	vflush: func [/disk logfile [file!]] [
		if block? vconsole [
			forall head vconsole [
				append first vconsole "^/"
			]
			either disk [
				write logfile rejoin head vconsole
			][
				print head vconsole
			]
			clear head vconsole
		]
	]


	;----------------
	;-    VEXPOSE()
	;----
	vexpose: does [
		set in system/words 'von :von
		set in system/words 'voff :voff
		set in system/words 'vprint :vprint
		set in system/words 'vprobe :vprobe
		set in system/words 'vout :vout
		set in system/words 'vin :vin
		set in system/words 'vflush :vflush
		set in system/words 'v?? :v??
	]


	;----------------
	;-    DISK-PRINT()
	;----
	disk-print: func [path][
		if file? path [
			if exists? path [
				; header
				write/append path reduce [
					"^/^/^/---------------------------^/"
					system/script/title
					"^/"
					system/script/path
					"^/"
					now
					"^/---------------------------^/"
				]
					
				; redefine print outs
				system/words/print: func [data] compose  [
					write/append (path) append reform data "^/"
				]
				system/words/prin: func [data] compose [
					write/append (path) reform data
				]
				system/words/probe: func [data] compose [
					write/append (path) append remold data "^/"
				]
			]
		]
	]
	

	;----------------
	;-    FAST()
	;----
	fast: func [ 
		'name
	][
		; probe name
		set name open name none
	]



	;----------------
	;-    OPEN()
	;----
	OPEN: function [ 
		"Open a library module.  If it is already loaded from disk, then it returns the memory cached version instead."
		lib-name [word! string!] "The name of the library module you wish to open.  This is the name of the file on disk.  Also, the name in its header, must match."
		version [integer! decimal! none! tuple! word!] "minimal version of the library which you need, all versions should be backwards compatible."
		/new "Re-load the module from disk, even if one exists in cache."
		/expose exp-words [word! block!] "expose words from the lib after its loaded and bound"
		/prefix pfx-word [word! string! none!] "use this prefix instead of the default setup in the lib as a prefix to exposed words"
	][lib lib-file lib-hdr][
		vprint/in ["SLiM/Open()  [" lib-name " " version " ] ["]
		lib-name: to-word lib-name ; make sure the name is a word.
		
		
		;probe "--------"
		;probe self/paths
		
		
		
		; any word you want to use for version will disable explicit version needs
		if word? version [
			version: none
		]
		
		either none? linked-libs [
			lib-file: self/find-path to-file rejoin [lib-name ".r"]
		][
			lib-file: select linked-libs lib-name
		]
		
		
;		if none? version [version: 0.0]
		self/open-version: version  ; store requested version for validate(), which is called in register.
		
		;-----------------------------------------------------------
		; check for existence of library in cache
		lib: self/cached? lib-name
		
		either ((lib <> none) AND (new = none))[
			vprint [ {STEEL|SLiM/open() reusing "} lib-name {"  module} ]
		][
			vprint [ {STEEL|SLiM/open() loading "} lib-file {"  module} ]
			either lib-file [
				do lib-file
				lib: self/cached? lib-name
			][
				vprint/error ["SLiM/open() ERROR : " lib-name " does not describe an accessible (loadable) library module (paths: " paths ")"]
			]
		]
		
		
		
		
		
		
		; in any case, check if used didn't want to expose new words
		if lib? lib [
			if expose [
				if not none? lib [
					either prefix [
						if string? pfx-word [pfx-word: to-word pfx-word]
						slim/expose/prefix lib exp-words pfx-word
					][
						slim/expose lib exp-words
					]
				]
			]
		]
		
		; clean exit
		lib-name: none
		version: none
		lib-file: none
		lib-hdr: none
		exp-words: none
		pfx-word: none
		vprint/out "]"
		return first reduce [lib lib: none]
	]



	
	;----------------
	;-    REGISTER()
	;----
	REGISTER: func [
		blk
		/header ; private... do not use.  only to be used by slim linker.
			hdrblk [string! block!]
		/local lib-spec pre-io post-io block lib success
	][
		
		vprint/in ["SLiM/REGISTER() ["]
		
		; temporarily set 'lib to self it is later set to the new library
		lib: self
		
		;--------------
		; initialize default library spec
		lib-spec: copy []
		append lib-spec blk

		;--------------
		; link header data when loading library module
		either none? header [
			hdrblk: system/script/header
		][
			if string? hdrblk [
				hdrblk: load hdrblk
			]
			hdrblk: make object! hdrblk
		]
		
		
		;--------------
		; make sure library meets all requirements
		either self/validate(hdrblk) [
			;--------------
			; compile library specification
			lib-spec: head insert lib-spec compose [ 
				header: (hdrblk)
				;just allocate object space
				rsrc-path: copy what-dir
				dir-path: copy what-dir
				read: none
				write: none
				load: none
				save: none
				; temporarily set these to the slim print tools... 
				; once the object is built, they will be bound to that object
				verbose: false
				vprint: get in lib 'vprint
				vprobe: get in lib 'vprobe
				vin: get in lib 'vin
				von: get in lib 'von
				voff: get in lib 'voff
				vout: get in lib 'vout
				v??: get in lib 'vout
				vflush: get in lib 'vflush
				vconsole: none
				vtags: none
				
			]
			
			
			;--------------
			; create library        
			lib:  make object! lib-spec
			
			
			; set resource-dir local to library
			vprint ["setting  resource path for lib " hdrblk/title]
			vprint ["what-dir: " what-dir]
			if not (exists? lib/rsrc-path:  to-file append copy what-dir rejoin ["rsrc-" lib/header/slim-name "/"]) [
				lib/rsrc-path: none
			]
			
	
			;--------------
			; encompass I/O so that we add the /resource refinement.
			;-         extend I/O ('read/'write/'load/'save)
			pre-io: compose/deep [
				if resource [ if (bind 'rsrc-path in lib 'header) [tmp: what-dir change-dir (bind 'rsrc-path in lib 'header)]]
			]
			post-io: compose/deep [
				if resource [if  (bind 'rsrc-path in lib 'header) [change-dir tmp]]
			]
			lib/read: encompass/args/pre/post 'read [/resource /local tmp] pre-io post-io           
			lib/write: encompass/silent/args/pre/post 'write [/resource /local tmp] pre-io post-io
			lib/load: encompass/args/pre/post 'load [/resource /local tmp] pre-io post-io
			lib/save: encompass/silent/args/pre/post 'save [/resource /local tmp] pre-io post-io
			
			;--------------
			; auto-init feature of library if it needs dynamic data (like files to load or opening network ports)...
			; or simply copy blocks
			 
			either (in lib '--init--)[
				success: lib/--init--
			][
				success: true
			]
			
			
			either success [
				;--------------
				; setup verbose print
				; note that each library uses its own verbose value, so you can print only messages
				; from a specific library and ignore ALL other printouts.
				;------------
				lib/vprint: func first get in self 'vprint bind/copy second get in self 'vprint in lib 'self
				lib/vprobe: func first get in self 'vprobe bind/copy second get in self 'vprobe in lib 'self
				lib/vin: func first get in self 'vin bind/copy second get in self 'vin in lib 'self
				lib/vout: func first get in self 'vout bind/copy second get in self 'vout in lib 'self
				lib/v??: func first get in self 'v?? bind/copy second get in self 'v?? in lib 'self
				lib/von: func first get in self 'von bind/copy second get in self 'von in lib 'self
				lib/voff: func first get in self 'voff bind/copy second get in self 'voff in lib 'self
				lib/vflush: func first get in self 'vflush bind/copy second get in self 'vflush in lib 'self
				
				
				;--------------
				; cache library
				; this causes the open library to be able to return the library to the 
				; application which opened the library.  open (after do'ing the library file) will then
				; call cached? to get the library ptr and return it to the user.
				SLiM/cache lib
			][
				vprint/error ["SLiM/REGISTER() initialisation of module: " lib/header/slim-name " failed!"]
				lib: none
			]
		][
			vprint/error ["SLiM/REGISTER() validation of library: " hdrblk/slim-name"  failed!"]
		]
		vprint/out "]"
		lib
	]
	
	
	
	;----------------
	;-    LIB?()
	;----
	LIB?: func [
		"returns true if you supply a valid library module object, else otherwise."
		lib
	][
		if object! = type? lib [
			if in lib 'header [
				if in lib/header 'slim-version [
					return true
				]
			]
		]
		return false
	]
	
	
	
	;----------------
	;-    CACHE
	;----
	CACHE: function [
{
		copy the new library in the libs list.
		NOTE that the current library will be replaced if one is already present. but
		any library pointing to the old version still points to it.
}
		lib "Library module to cache."
	][ptr][
		either lib? lib [
			if (cached? lib/header/slim-name )[
				vprint rejoin [{STEEL|SLiM/cache()  replacing module: "} uppercase to-string lib/header/slim-name {"}]
				; if the library was cached, then remove it from libs block
				remove/part find libs lib/header/slim-name 2
			]
			;---
			; actually add the library in the list...
			vprint rejoin [{STEEL|SLiM/cache() registering module: "} uppercase to-string lib/header/slim-name {"}]
			insert tail libs lib/header/slim-name
			insert tail libs lib
		][
			vprint/error "STEEL|SLiM/cache(): ERROR!! supplied argument is not a library object!"
		]
	]


	;----------------
	;-    CACHED?
	;----
	; find the pointer to an already opened library object 
	;  a return of none, means that a library of that name was not yet registered...
	;----
	CACHED?: function [libname [word!] /list][lib libs libctx][
		either list [
			libs: copy []
			foreach [lib libctx] self/libs [
				append libs lib
			]	
			libs
		][	
			lib: select self/libs libname
			;vprint [{STEEL|SLiM/cached? '} uppercase to-string libname {... } either lib [ true][false]]
		]
		;return lib
	]


	;----------------
	;-    LIST
	;----
	; find the pointer to an already opened library object 
	;  a return of none, means that a library of that name was not yet registered...
	;----
	LIST: has [lib libs libctx][
		libs: copy []
		foreach [lib libctx] self/libs [
			append libs lib
		]	
		libs
	]



	;----------------
	;-    ABSPATH()
	;----
	; return a COPY of path + filename
	;----
	abspath: func [path file][
		append copy path file
	]



	;----------------
	;-    FIND-PATH()
	;----
	; finds the first occurence of file in all paths.
	; if the file does not exist, it checks in urls and if it finds it there, 
	; then it calls the download method.  And returns the path returned by download ()
	; /next switch will attempt to find occurence of file when /next is used, file actually is a filepath.
	;----
	find-path: func [
		file
		/next prevpath
		/lib
		/local path item paths disk-paths
	][
		vprint ["SLiM/find-path(" file ")"]
		
		if next [
			vprint/error "SLiM/find-path() /next refinement not yet supported"
		]
		
		
		; usefull setup which allows slim-relative configuration setup file. (idea and first example provided by Robert M. Muench)
	     disk-paths: either (exists? join slim-path %slim-paths.r) [
	    	reduce load join slim-path %slim-paths.r
	    ][
	    	[]
	    ]

		; variety of methods to have slim running without even having to setup slim/paths explicitely!
		paths: copy []
		
		;probe slim-path
		
		foreach path reduce [ what-dir (join what-dir %libs/) self/paths disk-paths self/slim-path] [	
			append paths path 
		]
		

		;probe "PATHS: " 
		;probe paths
			
		
		foreach item paths [
			if file! = type? item[
				path: abspath item file
				either exists? path [
					either lib [
						data: load/header/all lib-file
						;probe first first data
						either (in data 'slim-name ) [
							break
						][
							path: none
						]
					][
						break
					]
				][
					path: none
				]
			]
		]
		return path
	]
	

	
	
	
	;----------------
	;-    VALIDATE()
	;----
	;----
	VALIDATE: function [header][pkg-blk][
		vprint/in ["SLiM/validate() ["]
		success: false
		ver: system/version
		
		;probe ver
		;probe self/open-version
		
		;strip OS related version
		ver: to-tuple reduce [ver/1 ver/2 ver/3]
		; make sure the lib is sufficiently recent enough
		either(version-check header/version self/open-version "+") [
			;print "."
			; make sure rebol is sufficient
			either all [(in header 'slim-requires) header/slim-requires ] [
				pkg-blk: first next find header/slim-requires 'package
				either pkg-blk [
					foreach [package version] pkg-blk [
						package: to-string package
						;probe package
						if find package to-string system/product [
							;print "library validation was successfull"
							success: version-check ver version package
							package-success: true
							break
						]
					]
					if not success [
						either package-success [
							vprint/error "SLiM/validate() rebol version mismatch"
						][
							vprint/error "SLiM/validate() rebol package mismatch"
						]
					]
				][
					; library does not impose rebol version requisites
					; it should thus work with ALL rebol versions.
					success: true
				]
			][
				success: true
			]
		][
			vprint/error ["SLiM/validate() LIBRARY VERSION mismatch... needs v" self/open-version "   Found: v"header/version]
		]
		vprint/out "]"
		success
	]
	
	
	
	;-------------------
	;-    AS-TUPLE()
	;-------------------
	; enforces any integer or decimal as a 3 digit tuple value (extra digits are ignored... to facilitate rebol version matching)
	; now also allows you to truncate the number of digits in a tuple value... usefull to compare major versions,
	; or removing platform part of rebol version.
	;----
	as-tuple: func [
		value
		/digits dcount
		/local yval i
	][
		value: switch type?/word value [
			none! [0.0.0]
			integer! [to-tuple reduce [value 0 0]]
			decimal! [
				yVal: to-string remainder value 1
				either (length? yVal) > 2 [
					yVal: to-integer at yVal 3
				][
					yVal: 0
				]
				
				to-tuple reduce [(to-integer value)   yVal   0 ]
			]
			tuple! [
				if digits [
					if (length? value) > dcount [
						digits: copy "" ; just reusing mem space... ugly
						repeat i dcount [
							append digits reduce [to-string pick value i "."]
						]
						digits: head remove back tail digits
						value: to-tuple digits
					]
				]
				value
			]
		]
		value
	]

	
	
	;----------------
	;-    VERSION-CHECK()
	;----
	; mode's last character determines validitiy of match.
	;----
	version-check: func [supplied required mode][
		supplied: as-tuple supplied
		required: as-tuple required
		
		;vprobe supplied
		;vprobe required
		
		any [
			all [(#"=" = (last mode)) (supplied = required)]
			all [(#"-" = (last mode)) ( supplied <= required)]
			all [(#"_" = (last mode)) ( supplied < required)]
			all [supplied >= required]
			;all [(#"+" = (last mode)) ( supplied >= required)]
		]
	]



	;----------------
	;-    EXPOSE()
	;----
	; expose words in the global namespace, so that you do not have to use a lib ptr.
	; context is left untouched, so method internals continue to use library object's
	; properties.
	;----------------
	expose: func [
		lib [word! string! object!]
		words [word! block! none!]
		/prefix pword
		/local reserved-words word rwords rsource rdest blk
	][
		vprint/in "SLiM/EXPOSE() ["
		
		; handle alternate lib argument datatypes
		if string? lib [lib: to-word lib]
		if word? lib [lib: cached? lib]
		
		
		; make sure we have a lib object at this point
		if lib? lib [
			
			reserved-words: [--init-- load save read write self rsrc-path header --private--]
			if in lib '--private-- [
				vprint "ADDING PRIVATE WORDS"
				reserved-words: append copy reserved-words lib/--private--
			]
			vprobe reserved-words
				
			;----------------------------
			;----- SELECT WORDS TO EXPOSE
			;----------------------------
			;special case: 'all should expose all words...
			if words = 'all [words: none]
			
			; make sure we have a block of words to work with
			switch type?/word words [
				block! [
					;---------------------------------------------
					; find, set and remove a rename block, if any.
					if (rwords: find words block!)[
						blk: first rwords
						remove rwords
						rwords: blk
					]
					
					either (  ('none = first words) OR (none = first words) )[
						words: copy first lib
					][
						if 0 = length? words [ words: copy first lib ]
					]
				]
				; expose only one word
				word! [
					words:  make block! reduce [words]
				]
				
				; expose all the lib's words
				none! [ words: copy first lib ]
			]

			
			;----------------------------
			;----- SELECT PREFIX TO USE
			;----------------------------
			if not prefix [
				; has the library creator set a default prefix?
				either in lib/header 'slim-prefix [
					pword: lib/header/slim-prefix
				][
					pword: lib/header/slim-name
				]
			]
				
			
			;----------------------------
			;----- BUILD EXPOSE LIST
			;----------------------------
			; create base expose list based on rename words list
			either not rwords [
				rwords: copy []
			][
				if odd? (length? rwords) [
					vprint/error ",--------------------------------------------------------."
					vprint/error "|  SLiM/EXPOSE() ERROR!!:                                |"
					vprint/error "|                                                        |"
					vprint/error head change at "|                                                        |"  7 (rejoin ["module: "lib/header/slim-name ])
					vprint/error "|     invalid rename block has an odd number of entries  |"
					vprint/error "|     Rename block will be ignored                       |"
					vprint/error "`--------------------------------------------------------'"
					rwords: copy []
				]
			]
			
			
			;add all other words which should keep their names      
			foreach word words [
				insert/dup tail rwords word 2
			]
			
			;----------------------------
			;----- REMOVE ANY RESERVED WORDS FROM LIST!
			;----------------------------
			expose-words: make block! (length? rwords)
			expose-list: make block! ((length? rwords) / 2)
			forall rwords [
				worda: to-word first rwords
				wordb: second rwords
				
				; remove the word if its a reserved word
				if not (find reserved-words wordb) [
					;remove the word if its already in the list
					if not (find expose-list wordb)[
						insert tail expose-words worda
						insert tail expose-words wordb
						insert tail expose-list wordb
					]
				]
				
				rwords: next rwords
			]
			

			
			;----------------------------
			;----- EXPOSE WORDS IN GLOBAL CONTEXT
			;----------------------------
			forall expose-words [
				either pword [
					worda: to-word rejoin [to-string pword "-" to-string first expose-words]
				][
					worda: to-word first expose-words
				]
				wordb: second expose-words
				set in system/words worda get in lib wordb
				expose-words: next expose-words
				vprint ["exposing: " wordb " as " worda]
			]
		]
		vprint/out "]"
	]
	
	
	
	
	;----------------
	;-    ENCOMPASS()
	;----
	;----
	encompass: function [
		func-name [word!]
		/args opt-args [block!]
		/pre pre-process
		/post post-process
		/silent
	][
		blk dt func-args func-ptr func-body last-ref item params-blk refinements word arguments args-blk
	][
		func-ptr: get in system/words func-name
		if not any-function? :func-ptr [vprint/error "  error... funcptr is not a function value or word" return none]
		arguments: third :func-ptr 
		func-args: copy []
		last-ref: none
		args-blk: copy compose [([('system)])([('words)])(to paren! to-lit-word func-name)]
		params-blk: copy [] ; stores all info about the params
		FOREACH item arguments [
			SWITCH/default TYPE?/word item [
				block! [
					blk: copy []
					FOREACH dt item [
						word: MOLD dt
						APPEND blk TO-WORD word
					]
					APPEND/only func-args blk
				]
				refinement! [
					last-ref: item
					if last-ref <> /local [
						APPEND func-args item
						append/only args-blk to paren! compose/deep [either (to-word item) [(to-lit-word item)][]]
					]
				]
				word! [
					either last-ref [
						if last-ref <> /local [
							append/only params-blk to paren! copy compose/deep [either (to-word last-ref) [(item)][]]
							append func-args item
						]
					][
						append/only params-blk to paren! item
						append func-args item
					]
				]
			][append/only func-args item]
		]
		
		blk: append append/only copy [] to paren! compose/deep [ to-path compose [(args-blk)]] params-blk
		func-body: append copy [] compose [
			(either pre [pre-process][])
			enclosed-func: compose (append/only copy [] blk)
			(either silent [[
				if error? (set/any 'encompass-err try [do enclosed-func]) [return :encompass-err]]
			][
				[if error? (set/any 'encompass-err try [set/any 'rval do enclosed-func]) [return :encompass-err]]
			])
			
			(either post [post-process][])
			return rval
		]
		;print "------------ slim/encompass debug --------------"
		;probe func-body
		;print "------------------------------------------------^/^/"
		if args [
			refinements: find func-args refinement!
			either refinements[
				func-args: refinements
			][
				func-args: tail func-args
			]
			insert func-args opt-args
		]
		append func-args [/rval /encompass-err]
		func-args: head func-args
		return func func-args func-body
	]
]
;- SLIM / END
