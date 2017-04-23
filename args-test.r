;--------------------------------------------------------------------------------------------------------
;    example app.
;--------------------------------------------------------------------------------------------------------
rebol [
	title: 		"args.r test"
	file: 		%args-test.r
	version:	0.1.6
	date: 		2008-12-10
	author:		"Maxim Olivier-Adlhoch"
	copyright:	"Copyright (c) 2008 Maxim Olivier-Adlhoch"
	license:    'mit
	purpose:	"Demonstrate the use of the args.r module on rebol.org"
	note:       "requires vprint.r and args.r modules from rebol.org to be fetched prior."
	note2:      "above modules should be in the same dir as this app.  Optionally, you can put them in a subdir called libs ."

	;-- REBOL.ORG header --
	library: [
		level:          'intermediate
		platform:       'all
		type:           [ how-to ]
		domain:         [ shell  ]
		tested-under:   [win view 2.7.5]
		license:        'MIT
		see also:       "vprint.r args.r"
	]
]



either exists? %libs/ [
	do %libs/vprint.r
	do %libs/args.r
][
	do %vprint.r
	do %args.r
]


; remove following comment, if you want to see every parse step in action!
;von

args: construct-args  " -label this is a -33 negative test -value 44" compose/deep [
	-address [
		number integer! 
		
		; note that following args are optional, since they have default values.
		; once defaut args are specified, ALL following args must also be optional, or an error is raised.
		; note that in order to reach an optional arg, all previous args mush be given on the command-line
		; eventually, we will allow the use of ** as a fill-in for the default value.
		street string! ["styx lane"] ; here the street has a default, so if ungiven, this is assumed

		; these are even more optional, since no value need be given, each one will be assigned a value of none.
		office integer! [#11]
		
		zip-code string! [#[none]]
	]
	
	-value [
		number integer! decimal! [#222]
	]
	
	-label [
		lbl text! ["no label"]
	]
	-quiet [switch! verbose [true]]
	-logfile [ logpath file! [ (join what-dir %test-args.log)] log? logic! [(true)]]
	-????? [switch! log? [false]]
]

probe args

if args/*error [
	print args/*error
]

; here we use the verbose argument from the constructed args context.
; since -quiet wasn't given on the command-line, verbose is set.
if args/verbose [
	von
]

vprint ["LABEL:    " args/lbl]
vprint ["logfile:  " to-local-file args/logpath]
vprint ["ADDRESS:  " args/number " " args/street " #" args/office ",   Abyssal city.  Pandemonium "]
vprint ["ZIP CODE: " args/zip-code]

ask "..."
