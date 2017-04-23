Rebol [
	File: %printf.r
	Date: 06-Jun-2006
	Title: "printf and sprintf implementation"
	Version: 1.0.1
	Author: ["Jaime Vargas" "Ladislav Mecir"]
	Rights: {Copyright © Why Wire, Inc. 2005}
	Purpose: {Wrapper for the printf and sprintf C routines}
	library: [
	    level: 'advanced
	    platform: 'all
	    type: 'tool
	    domain: [extension external-library text-processing]
	    tested-under: none
	    support: none
	    license: 'BSD
	    see-also: none
	]
	History: {
		1.0.0 "Initial release"
		1.0.1 "Fixes bug on windows,  we were using an incorrect DLL."
	}
]

comment [
	; example usage
	date: now
	sprintf ["%s %d, %d at %s" pick system/locale/months date/month date/day date/year to string! date/time]
	;== "December 30, 2005 at 15:02"
	
	; sprintf: returns a rebol string!
	; printf:  prints the result to the console
]

use [libc zero-char routine-call as-rebol-string malloc][

	libc: load/library switch system/version/4 [
		 2 [%libc.dylib]		; OSX
		 3 [%msvcrt.dll]		; Windows
		 4 [%libc.so]			; Linux
		 7 [%libc.so]			; FreeBSD
		 8 [%libc.so]			; NetBSD
		 9 [%libc.so]			; OpenBSD
		10 [%libc.so]			; Solaris
	]
	
	zero-char: #"^@"

	routine-call: func [
		library [library!]
		routine-name [string!]
		return-spec [block!]
		arguments [block!]
		/typed {Arguments block structure is: [argument-value [datatype] ...]}
		/local routine spec call argument type rule values pos
	] [
		arguments: reduce arguments
		spec: make block! 2 * length? arguments
		call: make block! 2 + length? arguments
		values: make block! length? arguments
		insert call [return routine]
		rule: either typed [
			[
				set argument skip
				set type skip
				(
					insert/only tail spec 'argument
					insert/only tail spec type
					insert tail call reduce [:first tail values]
					insert/only tail values get/any 'argument
				)
			]
		][
			[
				set argument skip
				(
					type: reduce [type?/word get/any 'argument]
					insert/only tail spec 'argument
					insert/only tail spec type
					insert tail call reduce [:first tail values]
					insert/only tail values get/any 'argument
				)
			]
		]
		parse arguments [any rule]
		insert tail spec [return:]
		insert/only tail spec return-spec
		routine: make routine! spec library routine-name
		do call
	]

	as-rebol-string: func [
		[catch]
		s [string!] 
		/local pos
	][
		unless pos: find s zero-char [throw make error! "s is not a c-string"]
		s: head remove/part pos tail s
		replace/all s "\n" newline
		replace/all s "\t" tab
	]
	
	malloc: func [
		size [integer!] "size in bytes"
	][
		head insert/dup copy {} zero-char size
	]

	sprintf: func [
		spec {block structure is: [format values ...]}
		/local s
	][
		s: malloc 32768
		spec: head insert copy spec 's
		routine-call libc "sprintf" [int] spec
		as-rebol-string s
	]
	
	printf: func [
		spec {block structure is: [format values ...]}
	][
		prin sprintf spec
	]
]