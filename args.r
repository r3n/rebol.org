rebol [
	title:		"args - generic command-line argument parser."
	file: 		%args.r
	version:	0.1.10
	date: 		2008-12-17
	author:		"Maxim Olivier-Adlhoch"
	copyright:	"Copyright (c) 2008 Maxim Olivier-Adlhoch"
	license:    'mit
	purpose:	"End to end command-line argument management.  Using a command-line description dialect parse a command-line and if its valid, construct a context which reflects it."
	note:       "requires vprint.r module from rebol.org to be run prior to this one"

	;-- REBOL.ORG header --
	library: [
		level:          'intermediate
		platform:       'all
		type:           [ module ]
		domain:         [ external-library dialects shell  ]
		tested-under:   [win view 2.7.5]
		license:        'MIT
		see also:       "vprint.r args-test.r"
	]


	to-do: {
	-must continue expanding command-line error reporting
	-debug all datatypes when defining optional datatype for arguments (order and mutual inclusion)
	}

	changes: {}
	
	history: {
		v0.1.1 - 2008-04-09/16:50:42 (max)
			-first history entry, after lengthy dev cycle
			-added extended file path notation, to allow paths with spaces. (ex, program files, documents and settings, etc)

		v0.1.6 - 2008-12-10/02:11:32 (max)
			-added a bit more docs about -????? flag
			-started embedded documentation at end of script

		v0.1.7 - 2008-12-15/00:34:48 (max)
			-switch now can act as a toggle between two values, instead of only supporting boolean on/off functionality.
			-added '0' & '1' to the valid boolean notations in command parsing
			-converted to simple rebol 'DO format for rebol.org release

		v0.1.8 - 2008-12-16/04:18:11 (max)
			-added command-line error reporting basics should report missing arguments
			-explicit support for command-line reporting in decimal! and integer! datatypes.

		v0.1.9 - 2008-12-16/20:26:20 (max)
			-fixed command-line parsing bug when specifying integer! and decimal! as both valid for a type...

		v0.1.10 - 2008-12-17/03:31:14 (max)
			-flags now specifically enfore that flags follow string alphanumeric word format (starting with a "-")
	}
]


;; conditional lib execution, simulates C/C++ #ifndef 
do unless (value? 'lib-args) [[

;; declare lib
lib-args: true


lib-args-ctx: context [
	;- LIBS
	;slim/open 'core none ; for slim-link
	;os: slim/open 'os none
	
	;----------
	; GLOBALS
	;- max-args
	max-args: 1000 ; just a safety for parser deadlock or application hacking (too many args could cause some apps to crash)
	
	;- error-index-symbol: 
	error-index-symbol: "<!!!>"
	
	;- load-error:
	; used for storage of error info when parsing command lines.
	load-error: none
	
	;- load-error-offset:
	load-error-offset: none
	
	;- error-msg:
	error-msg: none
	
	
	;- flag-name
	flag-name: none
	
								

	
	
	;----------
	; INTERNALS
	; localise values:
	rlv-str: val: none
	
	
		
	;-  
	;- VALUE-RULES[]
	value-rules: context [
		;-    context locals
		here-text: none
	
	
		;-    bitsets
		space: #" " ; newline and tab are already defined
		digit: charset [#"0" - #"9"]
		letter: charset [#"A" - #"Z"   #"a" - #"z" ]
		upper-case: charset [#"A" - #"Z"]
		alphanumeric: charset [ #"A" - #"Z"  #"a" - #"z"  #"0" - #"9"  #"-" #"_"]
		chars: complement charset [#"\" #"'"]
		block-end: complement charset [#"]"]
		anychar: complement charset [#" "]
		
		xtdpath-char: complement charset "'"
		
		white-space: charset reduce [ space tab newline]
		spaces: [some white-space]
		spacer: _: [any white-space] ; when its not required
		non-white-space: complement white-space
		separator: [[some white-space] | end]
	
	;-    type rules
		escape-char: [#"\" skip]
		string: [
			[
				; one of 3 string syntaxes!
				[{'} copy rlv-str [any [chars | escape-char]] {'}] |
				[{"} copy rlv-str [any [chars | escape-char]] {"}] |
				["{" copy rlv-str [any [chars | escape-char]] "}"]
			]
			
			( rlv-str: any [rlv-str copy ""] )
		
		] ; skip escaped chars{"} ]
		
		integer: [ 0 1 "-" some digit]
		float:   [ 0 1 "-" any digit "." some digit 0 1 ["E" some digit]]
		bool:  ["true" | "false" | "on" | "off" | "0" | "1"]
		flag: [ ["-" 0 1 "-" letter any alphanumeric] ] ; -switches cannot start with a digit
		datatype: [ [some letter "!"] ]
		path: file-path: [ 0 1 "%" ["./" | "/" | "\" | ".\" | [letter ":"]] any [non-white-space ]]
		block: [ "[" copy rlv-str to "]" skip] ; no "]" chars in any way within blocks.
		extended-file-path: [ 
			0 1 "%" 
			(rlv-str: none)
			[
				"'" copy rlv-str [ ["./" | "/" | "\" | ".\" | [letter ":"]]  any xtdpath-char]  "'"
			]|[
				copy rlv-str [["./" | "/" | "\" | ".\" | [letter ":"]] any [non-white-space ]]
			]
		]
		
		; any text (all chars until next flag (but not including it) )
		skip-text-rule: [skip here-text: ]
		skip-rule: none
		here-mem: none
		skip-flag: none
		any-text: [
			( skip-rule: skip-text-rule)
			some [
				here-mem:
				[
					some white-space skip-flag: flag  ( ; note that "-doo" in ski-doo will not match as a flag
						here-text: here-mem
						
						skip-rule: "_" ; we want the next skip to fail, and thus end the skipping, since here will start at a "-"
					)
					 :skip-flag
				]
				| 
				skip-rule 
			]
			:here-text 
		]
		
		error-at: none
		;-    compound rules
		value: [
			[
				error-at:
				copy val string  (append current-rblk rlv-str vprint ["STRING!: " rlv-str] rlv-str: none) | ; here we use rlv-str, because it contains no " chars
				copy val path    (if #"%" = first val [remove val] append current-rblk to-rebol-file val vprint ["PATH!: " val	]) |
				copy val bool    (append current-rblk to-logic do val vprint ["BOOL!: " val]) | 
				copy val float   (append current-rblk to-issue val vprint ["FLOAT!: " val]) | 
				copy val integer (append current-rblk to-issue val vprint ["INT!: " val]) |
				copy val flag  (append current-rblk to-word val vprint ["LABEL!: " val	]) |
				copy val datatype  (append current-rblk to-datatype val vprint ["DATATYPE!: " val	]) |
				copy val block   (append/only current-rblk val: parse/all rlv-str " " vprint ["BLOCK!: " mold/all val]) 
				(arg-load-count: arg-load-count + 1 if arg-load-count > max-args [print "arguments maximum count reached" halt])
				
			]
			(val: none)
		]
		
		; this rule loads ALL values from string, if they obey basic values rules	
		parameters: [ (current-rblk: copy [] arg-load-count: 0) some [ value | spaces]]
		
		arg-load-count: 0
		current-rblk: copy []
		
		
		;-    arg loading rules
		parsed-value: none
;		integer-rule: [
;			(parsed-value: none)
;			[
;				copy val integer 
;				(parsed-value: to-issue val vprint ["INT!: " val])
;				val: none
;			]|
;			[
;				(to-error "FUCK")
;			]
;		]
		
		integer-rule: [(parsed-value: none ) copy val integer separator   (parsed-value: to-issue val vprint ["INT!: " val]) val: none ]
		float-rule:   [(parsed-value: none ) copy val float  separator  (parsed-value: to-issue val vprint ["FLOAT!: " val]) val: none ]
		text-rule:    [(parsed-value: none) copy val any-text separator (parsed-value: trim val vprint ["TEXT!: " parsed-value]) val: none]
		bool-rule:    [(parsed-value: none) copy val bool separator (parsed-value: to-logic do val vprint ["BOOL!: " val] val: none)]
		string-rule:  [(parsed-value: none) string separator (parsed-value: rlv-str vprint ["STRING!: " rlv-str] rlv-str: none)] ; here we use rlv-str, because it contains no ' chars
		file-rule:    [(parsed-value: none) extended-file-path  separator (parsed-value: to-rebol-file rlv-str vprint ["PATH!: " parsed-value] val: none)] ; here we use rlv-str, because it contains no ' chars
	]
		
		
	;-    spec parsing rules
	;---
	; these are in fact words, not actual datatypes, since the spec is not loaded.
	;
	; CRITICAL NOTE!:
	;     Following list must be symmetric with switch list and untyped args in arg-ctx/init()
	;---
	spec-datatypes: ['integer! | 'string! | 'logic! | 'file! | 'decimal! | 'text! ]
		
	
;	
;	either LINKED?: false [
;		args: system/script/args
;	][
;		; just some generic argument
;		args: { -stack [fubar 001 25] plate ball 1 box counter  C:/some/path/to/a/file.txt +LR +BLUR }
;	]
	
	;-  
	;- FUNCTIONS
	;-------------
	;-     load-args()
	;-------------
	load-args: func [
		argstr [string!]
	][
		return either parse/all/case argstr value-rules/parameters [
			
			; all is well with command-line parsing, return loaded block
			first reduce [value-rules/current-rblk value-rules/current-rblk: rlv-str: val: none]
		
		][
			; an error occured, clear all data and return the error
			value-rules/current-rblk: rlv-str: val: none
			value-rules/error-at
		]
	]
	
	
	;-------------
	;-     construct-args()
	;-------------
	set 'construct-args func [
		"returns an object with all fields filled and fully validated, according to spec, an error string otherwise."
		args [string! block!] "either the argument string or a load-args block"
		spec [block!] {
		-flag [
			[switch!] arg type! [type! [...]] [default-value] ; both type and default value are optional
			[|] ; optional, changes flag's mode to mutually exclusive args based on type
			arg [...] 
			[|] ; as above
			arg [...]
		]
		-flag [...]

		
		; trailing args by type OR nothing, in which case any additional args are put in values: field
		
		integer! [default-value]
		file! [...]		
		...
}
		/local arg-ctx flag-name arg-name arg-type arg-value-when-set arg-value-when-unset arg-default 
			subrule flag-type here-error spec-error
			current-flag-rule new-flag-rule cmd-line-rule flag-ctx flags
			arg-val args-ctx error-msg entry-args
	][
		;---------------------
		;-         args-ctx:
		; used to store all arg names and default values, later on is converted to an object and filled up
		; *supplied-flags is used to know what flags where actually supplied on the command-line,
		;    in case some app features need this data (two flags sharing the same args).
		args-ctx: copy/deep [*supplied-flags: [] *error: none]
		
		;---------------------
		;-         flags:
		; we store all generated flag ctx here.
		; once spec parsing is done, we will run through this list and create a compiled command-line parse rule
		; and it will fill up the end-result args-ctx.
		flags: copy []
		
		;---------------------
		;-         cmd-line-rule:
		; this stores the compiled command-line parse rule, with all flags and args within.
		cmd-line-rule: copy []
		

		;---------------------
		; entry-args
		entry-args: args  ; <FIXME> potentially deprecated ????
		
		
		;---------------------
		; perform parsing within a safe and verbose error recovery
		;
		if error? spec-error: try [
			;--------------------------------------------------------------------
			;---                                                              ---    
			;---                   DEFINE ARG SPEC CONTEXTS                   ---
			;---                                                              ---    
			;--------------------------------------------------------------------
			vprobe args
			vprint "^/----------------------^/starting args-context()"

			;-------------
			;-         flag-ctx[]
			; 
			; each flag in your command-line spec, will generate one flag-ctx and add it to the flags block.
			;-------------
			flag-ctx: context [
				;-             name:
				name: none
				;-             type:
				type: 'arg
				;-             args:
				args: none
				;-             rule:
				rule: none
				;-             required?:
				required?: false

				;------------------------------
				;-             apply-defaults()
				;------------------------------
				apply-defaults: func [/local arg][
					foreach arg args [
						arg/apply-default
					]
				]
				
				;------------------------------
				;-             link-args()
				;------------------------------
				; here we check if all supplied args are valid amongst themselves.
				;
				; possible errors:
				; 	-a required arg is specified AFTER optional ones
				;------------------------------
				link-args: func [
					/local required? arg rule-tmp paren
				][
					vin "link-args()"
					required?: true
					
					
					foreach arg args [
						;-----------------------------------------------------------------
						; -????? is a shadow tag which never gets linked in the system.
						; its purpose is to modify the args-ctx directly, without really
						; adding args to your spec.
						unless name = '-????? [
							; make sure required args are not specified after optional ones.
							rule-tmp: tail rule
							any [
								all [
									not required? 
									arg/required?
									(make error! rejoin ["ERROR: Required arg '" arg/name "' follows optional args in " name " flag spec!"])
								]
								all [
									not arg/required?
									required?: false
								]
							]
							
							append rule arg/rule
							new-line rule-tmp true
						]
						; add args and defaults to args-ctx
						append args-ctx to-set-word arg/name
						append args-ctx arg/default
					]
					if rule [
						paren: [vout] 
						append/only rule to-paren paren
					]
					vout
				]
				
				;------------------------------
				;-             register()
				;------------------------------
				register: func [][
					;-----------------------------------------------------------------
					; -????? is a shadow tag which never gets linked in the system.
					; its purpose is to modify the args-ctx directly, without really
					; adding args to your spec.
					unless name = '-????? [
						append flags self
					]
				]
				
				;-----------------
				;-             confirm-flag-name()
				;-----------------
				confirm-flag-name: func [
				][
					vin [{confirm-flag-name()}]
					unless parse/all to-string name value-rules/flag [
						to-error join "ARGS.r template dialect ERROR:  Invalid flag name: " to-string name
					]
					vout
				]
				
				

				;------------------------------
				;-             init()
				;----------
				; NOTE before calling init, ALL object fields MUST be filled-in
				;------------------------------
				init: func [
					/local paren
				][
					vin "init-flag()"
					
					confirm-flag-name
					
					;----------
					;<TODO> support required? in flag spec
					;----------
					
					args: copy []
					
					
					
					
					
					;-----------------------------------------------------------------
					; -????? is a shadow tag which never gets linked in the system.
					; its purpose is to modify the args-ctx directly, without really
					; adding args to your spec.
					;
					; use it to set default values, without specifying any tag on the command line, for example
					unless name = '-????? [
					
						; the required? mode will be a post parse op, where we check if all required flags where specified at least
						; once in the *supplied-flags field
						append/only cmd-line-rule rule: compose/deep [(to-string name) value-rules/separator ]
						append cmd-line-rule '|

						paren: compose[vin flag-name: (to-string name)] 
						append/only rule to-paren paren 
						
						paren: compose [append args-ctx/*supplied-flags (to-lit-word name)]
						unless type = 'switch [
							append paren bind 'apply-defaults self
						]
						new-line/skip paren false 0
						paren: to paren! paren
						append/only rule paren


					]
					vout
				]
			]
			
			;-------------
			;-         arg-ctx[]
			;-------------
			arg-ctx: context [
				;-             name:
				name: none
				;-             type:
				type: 'arg
				;-             flag:
				flag: none
				;-             rule:
				rule: none
				;-             default:
				default: none
				;-             required?:
				required?: true
				;-             types:
				types: none
				
				;------------------------------
				;-             apply-default()
				;------------------------------
				apply-default: func [][
					set in args-ctx name default
				]
				
				;------------------------------
				;-             apply-arg()
				;------------------------------
				apply-arg: func [/using value][
					switch type [
						arg [
							set in args-ctx name value
						]
						switch [
							vprint "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
							set in args-ctx name self/value
							vprobe name
							vprobe args-ctx
						]
					]
				]
				
				;------------------------------
				;-             init()
				;------------------------------
				init: func [
					/local real-type datatype paren src-rule
				][
					vin "init-arg()"
					;----------
					; NOTE before calling init, object fields must be filled-in
					;----------
					
					;-----------------------------------------------------------------
					; -????? is a shadow tag which never gets linked in the system.
					; its purpose is to modify the args-ctx directly, without really
					; adding args to your spec.
					;
					; use it so set default values, without specifying any tag on the command line, for example
					unless name = '-????? [
						; we start by creating the type rule
						
						switch type [
							arg [
								either types [
									rule: copy []
									foreach datatype types [
										;---
										; NOTE: switch list must be symmetric with all allowed 
										; types below and in spec-parsing arg-rule
										src-rule: switch datatype [
											; the switch value is a word, the return value is a datatype parse block
											integer! [ 'integer-rule ]
											decimal! [ 'float-rule   ]
											logic! [ 'bool-rule]
											text! [ 'text-rule]
											string! [ 'string-rule]
											file! [ 'file-rule]
										]
										append/only rule get in value-rules src-rule
										append rule '|
									]
									remove back tail rule
								][
									;---
									; NOTE: This list must be symmetric with switch list above and in spec-parsing arg-rule
									rule:  [integer-rule | float-rule | bool-rule | text-rule | string-rule | file-rule]
									bind rule value-rules
								]
								
								src-rule: rule
								
								paren: compose [apply-arg/using value-rules/parsed-value]
								bind paren 'paren
								
								rule: compose/only [(rule) (to-paren paren )]
								;append/only rule value-rules/separator
								unless required? [
									rule: compose/only [0 1 (rule)]
								]
								vprobe mold/all rule
								
								;---------------------
								; add error handling to value-loading rule!
								vprint "^/^/-----------------------------------------"
								vprobe rule
								
								rule: compose/only/deep [
									(
										to-paren compose [vprint (join "argument: " name)]
									)
									[
									load-error-offset: [
										(rule) 
										load-error-offset: (
											to-paren [
												vprint "RULE OK!"
												vprint load-error-offset
												;ask "?"
											]
										)
									] | [
										( 
											to-paren compose/deep [
												load-error: rejoin [ "Expecting " (mold types) " for '" (to-string name) "' argument" ]
												vprint "RULE FAILED"
												vprint load-error-offset
												;ask "!"
											print load-error
											]
										)
									 	(src-rule) ; this will always fail if first rule failed!
									]
								]]
								
								vprobe rule
								
							]
							
							switch [
								if name [
									paren: compose [ (bind 'apply-arg 'flag) ]
									rule: compose/only [ (to-paren paren)]
								]
							]
						]
					]	

					append flag/args self

					vout
				]
			]

			;--------------------------------------------------------------------
			;---                                                              ---    
			;---                DEFINE ARG SPEC PARSING RULES                 ---
			;---                                                              ---    
			;--------------------------------------------------------------------
			
			;------------------------------------
			;-         text-flag-rule:
			;
			; this is a special flag which will load up ALL character data up to 
			; the next specified flag on the command-line (or its end).
			;------------------------------------
			text-flag-rule: [
				(vout) ; previous rule failed, get out of previous vin
				(
					vin "trying text subrule"
				)
				[
					here:
					( arg-name: arg-type: arg-default: none)
					copy arg-name word!
					here-error:
					'text!
					here-error:
					copy arg-default 0 1 block!
					here-error:
					(
						current-flag: make flag-ctx [
							name: flag-name
							init
						]
						vprint "VALID ARG FOUND" 
						vprobe here
						arg-name: arg-name/1
						vprint rejoin ["add flag argument: " arg-name " of type: " arg-type " with default: " arg-default]
						new-arg: make arg-ctx [
							name: arg-name
							required?: not block? arg-default
							default: all [arg-default pick first arg-default 1]
							types: [text!]
							flag: current-flag
							init
						]
						
					)
				] 
				[
					;----------
					; if we reach end of args block, then we finalize flag
					end 
					(
					current-flag/link-args
					current-flag/register
					vprint "---"
					vprint "FLAG:"
					vprobe current-flag
					)
				]
				|
				here:
				[
					;----------
					; we didn't reach the end for some reason, this means the spec is invalid
					;-                -arg flag error
					(
						error-msg: rejoin [
							"ERROR: unexpected item in '" flag-name "' specification.  Value: " 
							mold pick here-error 1 "^/ NEAR: " 
							remove head remove back tail mold here-error
						]
						make error! error-msg
					)
				]
			]
			
			
			
			;------------------------------------
			;-         flag-rule:
			;
			; a flag is the basic building block of command line parsing.  
			;
			; each word preceded by a dash ('-') is identified as a flag.
			;
			; note that scalar values (integers, decimals, etc) which 
			; start by a minus sign are NOT considered flags so cannot be 
			; used as flag names.
			; 
			;    (note: -1e isn't a valid scalar, so its a valid flag name)
			;------------------------------------
			flag-rule: [
				[ 
					;-------------------------------------
					;-            -switch flags
					;-------------------------------------
					(
						vin "trying flag switch subrule"
						current-flag: none
						new-arg: none
					)
					'switch! [
						[
							(vprint "SWITCH!")
							(
								current-flag: make flag-ctx [
									name: flag-name
									type: 'switch
									init
								]
							)
							(
								arg-value-when-unset: arg-name
								arg-value-when-set: none
								default-value: false
								arg-value-when-set: true 
							)
							here-error: [
								; assigning the flag to an argument is optional...
								; you can just look in args-ctx/flags if that is all you need.
								0 1 [
									copy arg-name word!
									here-error:
									0 1 [ into [
										; toggle setup (two values)
										[
											; value when set
											copy arg-value-when-set 
											skip
											here-error:
											
											; value when unset
											copy default-value
											skip 
											here-error:

											
											; there musn't be more than two values
											end
											
											(
												arg-value-when-set: first arg-value-when-set
												default-value: first default-value
												
												if find ['true | 'false | 'on | 'off] default-value [
													default-value: do default-value
												]
												if find ['true | 'false | 'on | 'off] arg-value-when-set [
													arg-value-when-set: do arg-value-when-set
												]
												
												vprint "^^---^/TOGGLE-type switch flag setup" 
												vprobe arg-name
												vprint "-"
												v??  arg-value-when-set
												vprint "-"
												v??  default-value ; default value
											)
										] 
										|
										
										; boolean setup
										[
											; default value (must be boolean)
											copy default-value ['true | 'false | 'on | 'off]
											here-error:
											
											; there must not be more than one value
											end
											(
												default-value: do first default-value
												arg-value-when-set: not default-value
												
												vprint "^^---^/BOOLEAN-type switch flag setup" 
												vprobe arg-name
												vprint "-"
												v??  arg-value-when-set
												vprint "-"
												v??  default-value ; default value
											)
											
										]
										
									]]	
								]
								here-error:
								(
									; create the flag's argument if its specified and valid
									if arg-name [
										arg-name: arg-name/1
										vprint rejoin ["add flag argument: " arg-name " of type: " arg-type " with default: " arg-default]
										new-arg: make arg-ctx [
											name: arg-name
											type: 'switch
											default: default-value
											value: arg-value-when-set
											flag: current-flag
											required?: false
											init
										]
									]
									
									vprobe new-arg
								)
							]
						]
						
						[
							;----------
							; if we reach end of args block, then we finalize flag
							end 
							(
							current-flag/link-args
							current-flag/register
							vprint "---"
							vprint "FLAG:"
							vprobe current-flag
							)
						]
						|
						here:
						[
							;----------
							; we didn't reach the end for some reason, this means the spec is invalid
							;-                -switch  error
							(
								error-msg: rejoin [
									"ERROR: unexpected item in '" flag-name "' specification.  Value: " 
									mold pick here-error 1 "^/ NEAR: " 
									remove head remove back tail mold here-error
								]
								make error! error-msg
							)
						]
					]
				]|[
					;-------------------------------------
					;-            -arg flags
					;-------------------------------------
					;

					(vout) ; previous rule failed, get out of previous vin
					(
						vin "trying flag value subrule"
						current-flag: make flag-ctx [
							name: flag-name
							init
						]
					)
					some [
						here:
						( arg-name: arg-type: arg-default: none)
						copy arg-name word!
						here-error:
						copy arg-type any spec-datatypes
						here-error:
						copy arg-default 0 1 block!
						here-error:
						(
							vprint "VALID ARG FOUND" 
							vprobe here
							arg-name: arg-name/1
							vprobe arg-type
							vprint rejoin ["add flag argument: " arg-name " of type: " mold arg-type " with default: "  arg-default]
							new-arg: make arg-ctx [
								name: arg-name
								required?: not block? arg-default
								default: all [arg-default pick first arg-default 1]
								types: arg-type
								flag: current-flag
								init
							]
							
						)
					] 
					[
						;----------
						; if we reach end of args block, then we finalize flag
						end 
						(
						current-flag/link-args
						current-flag/register
						vprint "---"
						vprint "FLAG:"
						vprobe current-flag
						)
					]
					|
					here:
					[
						;----------
						; we didn't reach the end for some reason, this means the spec is invalid
						;-                -arg flag error
						(
							error-msg: rejoin [
								"ERROR: unexpected item in '" flag-name "' specification.  Value: " 
								mold pick here-error 1 "^/ NEAR: " 
								remove head remove back tail mold here-error
							]
							make error! error-msg
						)
					]
				]
				(vout)
			]
			
			;------------------------------------
			;-        type-rule:
			;-------------------------------------
			type-rule: [
				(vin)
				(
					vprint "entering subrule flag"
				)
				copy arg-default block!
				(
					vprint rejoin ["add argument: trailing-" flag-type " with default: " arg-default]
				)
				(vout)
			]
			




			;--------------------------------------------------------------------
			;---                                                              ---    
			;---                          PARSE SPEC                          ---
			;---                                                              ---    
			;--------------------------------------------------------------------
			;-        PARSE SPEC
			vprobe parse spec [
				(subrule: none) 
				any [
					here:
					(vin rejoin ["PARSING: " head replace/all mold pick here 1 "^/" " "])
					[
						copy flag-name word! ( 
							vprint "flag name detected"
							flag-name: first flag-name
							vprobe flag-name
							subrule: flag-rule 
						)
						(vout)
					]|[
						into subrule
						(vout)
					]|[
						copy flag-type datatype! (
							vprint "trailing datatype values detected"
							vprobe flag-type
							subrule: type-rule 
						)
						(vout)
					]
					here:
					(
						to-error rejoin ["ERROR, invalid template near: " mold here]
					)
				]
			]
			
			
			
			;--------------------------------------------------------------------
			;---                                                              ---    
			;---                     PARSE COMMAND LINE                       ---
			;---                                                              ---    
			;--------------------------------------------------------------------
			;-        PARSE CMD
			vprint "^/^/---------------------------------^/PARSING COMMAND LINE ARGUMENTS^/---------------------------------" 

			; remove trailing '|
			remove back tail cmd-line-rule
			
			cmd-line-rule: compose/only copy [value-rules/spacer some (cmd-line-rule)]
			vprobe mold/all cmd-line-rule
			
			
			args-ctx: context args-ctx
			; temporary
			arg-load-blk: copy []
			vprobe args
			
			;probe args-ctx
			
			unless vprobe parse/all args cmd-line-rule [
				args-ctx/*error: rejoin [
					"Command-line error in '" flag-name "' flag"
					"^/Description: " load-error
					"^/Location : "	args
					"^/         "
					head insert/dup copy "" " " index? load-error-offset 
					;#"^^"
					;"A"
					;#"^(a4)" ; ¤
					"_" #"^(18)" "_"  ; 
					"^/"
					
				]
				vprint "^/^/"
				vprint error-msg
				vprint "^/^/"
			]
			vprobe arg-load-blk
			vprobe args-ctx
			
		][
			;--------------------------------------------------------------------
			;---                                                              ---    
			;---                args-context() error recovery                 ---
			;---                                                              ---    
			;--------------------------------------------------------------------
			vprint "------------------------"
			catch-error: false
			either catch-error [
				spec-error: disarm spec-error
				vprint spec-error/arg1
			][
				spec-error
			]
		]
		args-ctx
	]
]]]




