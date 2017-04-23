REBOL [
	Title: "secure-clean-path"
	File: %secure-clean-path.r
	Date: 19-Sep-2002
	Version: 1.0.1
	Needs: []
	Author: ["Brian Hawley" "Anton Rolls"]
	Rights: {
		Copyright (C) Brian Hawley and Anton Rolls 2002. License for
		redistribution, use and modification is granted only if this
		copyright notice is included, and does not in any way confer
		ownership. It is requested, but not required, that the authors
		be notified of any use or modification, for quality-control
		purposes.
	}
	Library: [
		level: 'intermediate
		platform: 'all
		type: 'function
		domain: [cgi file-handling files]
		tested-under: [view 1.3.1.3.1 on "Windows XP"]
		support: none
		license: 'bsd
		see-also: none
	]
	Language: 'English
	Purpose: {Cleans up parent markers in a path, whilst restricting the output to a sandbox directory}
	Usage: {
		For help, type:

			help secure-clean-path

		Example:

			do %secure-clean-path.r

			; now some examples

			secure-clean-path %my-dir/
			;== %my-dir/

			secure-clean-path %my-dir/../
			;== %""

			secure-clean-path %my-dir/../../
			;== %""

		Use the inbuilt tests

			do/args %secure-clean-path.r "test"
	}
	ToDo: {
	- decide how to handle ~ character as used in linux (to access home directories of users etc) ?
	  It is supported by rebol on linux, but it is also used in urls, eg: http://server.org/~volker
	  - this raises the issue of how to handle all symbolic links. As is, links are not resolved.
	    secure-clean-path basically works only on text, it does not access the filesystem, but
		accurately resolving links seems to require that.
	- add more secure tests
	- implement limit refinement within parse rule like Brian's version (done 1.0.1)
	- /intolerant refinement
	  - parenting beyond the root should make an error, eg. leading ../ should not just be lopped off
	  - or parenting beyond the root should leave the parent-marker intact ?
	}
	History: [
		1.0.0 [12-Sep-2002 {First version, chopped secure-clean-path from simple-clean-path.r,
			implemented nocopy & limit refinements, added secure-tests, changed testing a bit} "Anton"]
		1.0.1 [19-Sep-2002 {Applied simple-clean-path 1.0.6 bug fix to a refined version
            of Brian's secure-clean-path. Added test wrapper: do/args filename "test".
            Fixed some security holes and a misconception of limit in the tests.} "Brian"]
	]
	Notes: {}
]

comment { ; Previous versions

; Brian's first renamed version of simple-clean-path

secure-clean-path: func [
{Cleans-up '.' and '..' in path; returns the cleaned path.
Does not convert to absolute path from current directory.
Considers multiple '/' to be erroneous, removes them. Only
cleans relative to root value. Works on strings as well.}
     target [any-string!] {The path to be cleaned}
     /limit               {Limit paths relative to this root}
     root   [any-string!] {The root path (Default "", not applied if "")}
     /nocopy              {Modify target instead of copy}
     /local root-rule a b c x
] [
     ; Make copy of target if required (preserves any offset)
     if not nocopy [target: at copy head target index? target]

     ; Set root rule based on nature of root
     root-rule: either all [root not empty? root] [
         ; Root rule applies, set to match root dir with /
         either (#"/" = pick root length? root) [root] [[root "/"]]
     ] [
         ["/" | none] ; No root, just skip leading / if any
     ]

     ; Return cleaned target path starting with root-rule
     if parse/all target [
         root-rule limit:
         any [
             ; Quickly remove ./
             a: "./" (remove/part a 2) :a |
             ; Remove (considered erroneous) multiple /
             a: some "/" b: (remove/part a b) :a |
             ; Apply any relative dots within limit
             a: some "." b: "/" c: (
                 ; Set x to the number of dots
                 x: (index? b) - (index? a)
                 ; For every . set 'a back one / within limit
                 while [all [
                     positive? x: x - 1
                     b: find/reverse back a "/"
                     (index? limit) < (index? b)
                 ]] [a: next b]
                 ; Remove the marked portion
                 remove/part a c
             ) :a |
             thru "/"  ; Regular directory, skip
         ] to end
     ] [target]

] ; End secure-clean-path


; Anton's version based on Anton's simple-clean-path version 5

secure-clean-path: func [{Cleans-up '.' and '..' in path; returns the cleaned path.
Does not take absolute path from current directory (like clean-path does).}
	target [any-string!] "The path to be cleaned"
	/nocopy              {Modify target instead of copy}
	/limit               {Limit paths relative to this root}
	root [any-string! none!] {The root path (Default "", not applied if "")}
	/local blk result start pos prev post
][
	; Make copy of target if required (preserves any offset)
	if not nocopy [target: at copy head target index? target]

	; clean the path
	if parse/all target [
		["/" |] ; leading slash or nothing
		start:
		pos:
		any [

			end break |
			["/" (remove pos) :pos] |
			[["./" :pos (remove/part pos 2)] | ["." end :pos (remove pos)]] |
			[["../" | ".." end] post: (

				; find previous slash
				prev: either prev: find/reverse back pos "/" [next prev][start]
			)
			:prev ; set internal pointer back so it isn't left outside the string by the remove
			(
				; Remove the previous path section and set pos
				pos: remove/part prev post

			)] |
			[thru "/" pos:] | to end

		]
	][
		; handle limit refinement
		;?? target
		;?? limit
		;?? root
		;print ["all [limit root not empty? root] =" all [limit root not empty? root]]

		either all [limit root not empty? root][
			if not-equal? #"/" last root [append root "/"] ; ensure root has a final slash
			find/match target root ; return portion of target path left over after the root
		][target]
	]
]

} ; End previous versions


; Brian's new version, refined while trying to solve the crash,
; with the crash fix from Anton's simple-clean-path v5 adopted.
; Further refined after examining (and fixing) tests.

secure-clean-path: func [
{Cleans-up '.', '..' and so on in path; returns cleaned path.
Does not convert to absolute path from current directory.
Considers multiple '/' to be erroneous, removes them. Only
cleans relative to root value. Works on strings as well.}
    target [any-string!] {The path to be cleaned}
    /limit               {Limit paths relative to this root}
    root   [any-string!] {The root path (Default "", not applied if "")}
    /nocopy              {Modify target instead of copy}
    /local root-rule a b c
] [
    ; Make copy of target if required (preserves any offset)
    if not nocopy [target: at copy head target index? target]
    
    ; Set root rule based on nature of root
    root-rule: either all [root not empty? root] [
        ; Root rule applies, set to match root dir with /
        either (#"/" = pick root length? root) [root] [[root "/"]]
    ] [
        ["/" | none] ; No root, just skip leading / if any
    ]
    
    ; Return cleaned target path that starts with root-rule
    if parse/all target [
        root-rule limit:
        any [
            ; Quickly remove ./ or ending .
            a: "." ["/" | end] (remove/part a 2) :a |
            ; Remove (considered erroneous) multiple /
            a: some "/" b: (remove/part a b) :a |
            ; Apply any relative dots within limit
            a: some "." b: ["/" | end] c: (
                ; For every extra . set 'a back one / within limit
                loop ((index? b) - (index? a)) - 1 [
                    either all [
                        b: find/reverse back a "/"
                        (index? limit) <= (1 + index? b)
                    ] [a: next b] [a: limit  break]
                ]
            ) :a ( ; Set new position of a, or else crash!
                ; Remove the marked portion
                remove/part a c
            ) |
            thru "/"  ; Regular directory, skip
        ] to end  ; Skip any trailing stuff
    ] [target]
    
] ; End secure-clean-path


; Test cases!
if system/script/args = "test" [
use [
    simple-tests secure-tests do-test-block
    limit path correct-result result err
] [

; tests without limit refinement
simple-tests: [
	%""		%""
	%one	%one
	%one/	%one/
	%one/two %one/two
	%one/two/ %one/two/
	%../			%""
	%..				%""
	%./				%""
	%.				%""
	%one/../		%""
	%one/..			%""
	%one/./../		%""
	%one/./..		%""
	%one/.././../	%""
	%one/.././..	%""

	%one/two/../	%one/
	%one/two/..		%one/
	%one/../two		%two
	%one/../two/	%two/
	%one/.././two/three/../ %two/
	%one/two/../../.././/../../hello////../././there/path	%there/path

	; these are the same as above, except beginning with a slash
	%/	%/
	%/one %/one
	%/one/ %/one/
	%/one/two %/one/two
	%/one/two/ %/one/two/
	%/../	%/
	%/..	%/
	%/./	%/
	%/.	%/
	%/one/../		%/
	%/one/..		%/
	%/one/./../		%/
	%/one/./..		%/
	%/one/.././../	%/
	%/one/.././..	%/

	%/one/two/../	%/one/
	%/one/two/..	%/one/
	%/one/../two		%/two
	%/one/../two/	%/two/
	%/one/.././two/three/../ %/two/
	%/one/two/../../.././/../../hello////../././there/path	%/there/path

	%//		%/

	; Multiple dots, to deal with REBOL's behavior on Brian's system
    %/////one/two/../../../.././././../../.../....////five/six/seven?/?/
		%/five/six/seven?/?/
    %/one/two/three/.../  %/one/
    %/one/two/three/.../four/  %/one/four/
	
	"risqué%filename" "risqué%filename"
	"risqué//%filename" "risqué/%filename"
]

; Tests with limit refinement, fixed to reflect proper behavior.
secure-tests: compose [

	%one/	%one/	%one/
	(none)	%one/	%one/
	%one/	%one/two/three//..	%one/two/
	%one/	%one/two/three//../ %one/two/
	%one/two/	%one/two/three	%one/two/three
	%one/two	%one/two/three	%one/two/three

	; these are the same as above, except beginning with a slash
	%/one/	%/one/	%/one/
	(none)	%/one/	%/one/
	%/one/	%/one/two/three//..	%/one/two/
	%/one/	%/one/two/three//../ %/one/two/
	%/one/two/	%/one/two/three	%/one/two/three
	%/one/two	%/one/two/three	%/one/two/three

	; Testing for improperly late limit application - allowing
	; such would let an attacker get info about your system!
	%one/two/      %one/../one/two/     (none)
	%/one/two/     %/one/../one/two/    (none)
	%one/../two/   %two/                (none)
	%/one/../two/  %/two/               (none)
	%one/../two/   %one/../two/         %one/../two/
	%/one/../two/  %/one/../two/        %/one/../two/
	%one/../two/   %one/../two/three/   %one/../two/three/
	%/one/../two/  %/one/../two/three/  %/one/../two/three/
	
	; Testing for proper failure
	%/one/	%one/	(none)

]

do-test-block: [
	if error? set/any 'err try [
		result: either none? limit [
		    secure-clean-path path
        ] [
            secure-clean-path/limit path limit
        ]
	][
		print [
			"Error" newline
			tab "limit:" mold limit newline
			tab "path:" mold path newline
			tab "correct-result:" mold correct-result newline
			mold disarm err
		]
		err
		break
	]

	either not-equal? result correct-result [
		print [
			"[Wrong] " mold limit " ^-" mold path "^- -> ^-" mold result " "
			"should be " mold correct-result
		]
		;break
	][
		print ["[OK]	" mold limit " ^-" mold path "^- -> ^-" mold result]
	]
]

print "Simple Tests:"
limit: none
foreach [path correct-result] simple-tests do-test-block

print "Tests with /Limit:"
foreach [limit path correct-result] secure-tests do-test-block

] ; End use
] ; End if "tests"
