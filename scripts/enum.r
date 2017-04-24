REBOL [
	Title: "Enumerated Type"
	Purpose: "Safe Enumerated Type for REBOL"
	Description: { These functions allow you to detect at runtime when
	you have tried to assign a value to a variable which is known to be
	an illegal possibility.  It determines this by checking against 
	a list you provide when the variable is declared.  There is also
	a "safe" variation of switch which ensures you have provided a
	case for all legal possibilities in the set.

	Script includes a regression test that you should enable after making
	changes to the implementation (to ensure nothing breaks).
	}

	Author: "Hostile Fork"
	Home: http://hostilefork.com/2009/06/13/enumerated-type-for-rebol2/
	License: mit

	File: %enum.r
	Date: 12-Jun-2009
	Version: 0.1.1

	; Header conventions: http://www.rebol.org/one-click-submission-help.r
	Type: function
	Level: intermediate
	
	Usage: { To declare a new enum type & initialize its 
	possibilities, use make-enum-type:

		fruit: make-enum-type [apple orange banana mango]

	To create an instance of the enum, use make-enum:

		favorite_fruit: make-enum fruit 'apple

	To set its value, use the set-enum function:
  
		set-enum favorite_fruit 'banana ; works
		set-enum favorite_fruit 'shoe ; throws error
  
	To get its value, use the get-enum accessor:
 
		print get-enum favorite_fruit

	There's a special switch function you can use on enums which
	does some nifty added checking.  If you don't supply a /default
	branch, it will ensure there is a case for every legal value
	and no illegal values are present (though the cases can be 
	in any order):
 
		switch-enum favorite_fruit [
			mango [print "mango"]
			apple [print "apple"]
			banana [print "banana"]
			orange [print "orange"]
		] ; works

		switch-enum favorite_fruit [
			orange [print "orange"]
			mango [print "mango"]
			apple [print "apple"]
		] ; throws error

		switch-enum favorite_fruit [
			mango [print "mango"]
			apple [print "apple"]
			banana [print "banana"]
			orange [print "orange"]
			shoe [print "shoe"]
		] ; throws error

	If you use the /default refinement, then you can provide fewer
	than the entire set of cases.  It will still make sure that all 
	the possibilities you provide are valid:

		switch-enum/default favorite_fruit [
			mango [print "mango"]
			apple [print "apple"]
		] [print "orange or banana"] ; works

		switch-enum/default favorite_fruit [
			mango [print "mango"]
			apple [print "apple"]
			shoe [print "shoe"]
		] [print "orange or banana"] ; throws error

	There's an added protection ensuring that you have more than one
	missing case from the set which would run in the default:

		switch-enum/default favorite_fruit [
			mango [print "mango"]
			apple [print "apple"]
			banana [print "banana"]
			orange [print "orange"]
		] [print "would never run"] ; throws error

		switch-enum/default favorite_fruit [
			mango [print "mango"]
			apple [print "apple"]
			banana [print "banana"]
		] [print "explicit orange is clearer"] ; throws error

	If you don't want this kind of safety and enforced clarity, then 
	you are probably designing something which is anticipating future
	expansion.  Adding a couple of extra states will make this 
	intention explicit, and ensure all code paths are providing
	a default branch:

		fruit: make-enum-type [apple orange banana mango RESERVED1 RESERVED2]

	Unsafe switches are not advised, but can be achieved using the 
	ordinary switch:

		switch/default get-enum favorite_fruit [
			apple [print "apple"]
			bananana [print "banana"]	
		] [
			print "Doing mango/orange stuff..."
			print "...and mysterious errors happen..."
			print "...because we accidentally typed banana wrong!!!"
		] ; no error thrown

	}

	History: [
		0.1.0 [31-Mar-2007 {Initial version created with help 
		and suggestions from the AltME user community.  Not released to
		general public.} "Fork"]

		0.1.1 [12-Jun-2009 {Found on old drive of miscellaneous projects.
		Completed an unfinished conversion from "e/set_value v" style of
		calls to "set_enum e v" (better performance).  Custom error types.
		Implemented the default refinement.  Modified for REBOL.org header
		conventions and uploaded to REBOL.org } "Fork"]
	]
]

; enum error definitions
system/error/user: make system/error/user [
	enum-no-possibilities: ["make-enum-type expects a block of possibilities containing at least one element"]
	enum-illegal-value: ["illegal enum value (" :arg1 ") when possibilities are [" :arg2 "]"]
	enum-incomplete-switch-cases: ["missing switch-enum cases for [" :arg1 "]"]
	enum-illegal-switch-cases: ["illegal case values for switch-enum [" :arg1 "] when possibilities are [" :arg2 "]"]
	enum-unreachable-switch-default: ["/default specified for switch-enum is unreachable because all cases are specified"]
	enum-switch-list-not-even: ["switch-enum needs an even number of 'value [action]' pairs"]
	enum-switch-default-single: ["switch-enum specifies a /default which is more clearly expressed as case (" :arg1 ")"]
]

;
; enum generation
;
enum!: make object! [
	_possibilities: none ; possibilities, hashed... speeds comparison check
	_value: none ; current value
]
make-enum-type: function [possibilities [block!]] [] [
	if 0 == length? possibilities [throw make error! [user enum-no-possibilities]]
	make enum! [
		_possibilities: to-hash possibilities
	]
]
make-enum: function [type [object!] value [word!]] [ret] [
	ret: make type []
	set-enum ret value
	ret
]

;
; enum operations
;
get-enum: function [e [object!]] [] [e/_value]
set-enum: function [e [object!] value [word!]] [] [
	either none? find e/_possibilities value [
		throw make error! reduce ['user 'enum-illegal-value (value) (form to-block e/_possibilities)]
	] [
		e/_value: value
		value
	]
]
switch-enum: function [e [object!] cases [block!] /default case] [p bad_values case_value num_cases missing_values single_default] [
	bad_values: copy []
	if (mod length? cases 2) == 1 [
		throw make error! reduce ['user 'enum-switch-list-not-even]
	]
	num_cases: (length? cases) / 2
	forskip cases 2 [
		if none? find e/_possibilities first cases [append bad_values first cases]
	]
	if not empty? bad_values [
		throw make error! reduce ['user 'enum-illegal-switch-cases (form bad_values) (form to-block e/_possibilities)]
	]
	either (none? default) [
		if (num_cases <> (length? e/_possibilities)) [
			missing_values: copy []
			p: e/_possibilities
			forskip p 2 [
				if none? find cases first p [append missing_values first p]
			]
			throw make error! reduce ['user 'enum-incomplete-switch-cases (form missing_values)]
		]
		switch/default e/_value cases [
			; this should not be able to happen, unless user modified enum value without set-enum
			throw make error! reduce ['user 'enum-illegal-value (e/_value) (form to-block e/_possibilities)]
		]
	] [
		if (num_cases >= ((length? e/_possibilities) - 1)) [
			if (num_cases == (length? e/_possibilities)) [
				throw make error! reduce ['user 'enum-unreachable-switch-default]
			]
			if (num_cases == ((length? e/_possibilities) - 1)) [
				foreach p e/_possibilities [
					if none? find cases p [
						throw make error! reduce ['user 'enum-switch-default-single p]
					]
				]
			]
		] 
		switch/default e/_value cases case
	]
]


;
; REGRESSION TESTS FOR SAFE ENUM
;
; If you wish to run the tests when this module is loaded, then
; make the next line of code a "do".  However, if you wish to not 
; run the tests, then the next line should say "comment"...
;
comment [
	context [
		test-block: function [
			section-name [string!]
			block [block!] 
			/reps times [integer!]
		] [start end] [
			print "----------------------------^/"
			print rejoin reduce ["Current test is ==> " section-name "^/"]

			; http://www.rebol.org/cgi-bin/cgiwrap/rebol/documentation.r?script=timeblk.r
			if not reps [times: 1]
			start: do now/time/precise
			loop times [context [do :block]]
			end: now/time/precise

			print rejoin reduce ["^/SUCCESS (" end - start "): " section-name "^/"]
		]

		; http://www.mail-archive.com/rebol-list@rebol.com/msg20148.html
		form-error: func [
			"Forms an error message"
			errobj [object!] "Disarmed error"
			/all "Use the same format as the REBOL console"
			/local errtype text
		] [
			errtype: get in system/error errobj/type
			text: get in errtype errobj/id
			if block? text [text: reform bind/copy text in errobj 'self]
			either all [
				rejoin [
					"** " errtype/type ": " text newline
					either errobj/where [join "** Where: " [errobj/where newline]] [""]
					either errobj/near [join "** Near: " [mold/only errobj/near newline]] [""]
				]
			] [
				text
			]
		]

		reps: 10000

		; picked REBOL function names instead of fruit to catch any evaluations
		command_names: [usage print help]

		test-block/reps reduce rejoin ["Native REBOL switch with " reps " repetitions"] [
			v: pick command_names random length? command_names
			case_ran: false
			switch v [
				usage [ either v = 'usage [case_ran: true] [
					throw make error! "FAILED: usage case ran" 
					]
				]
				print [ either v = 'print [case_ran: true] [
					throw make error! "FAILED: print case ran"
					]
				]
				help [ either v = 'help [case_ran: true] [
					throw make error! "FAILED: help case ran"
					]
				]
			]
			if not case_ran [ throw make error! "FAILED: required case was not run" ]
		] reps

		test-block "Illegal enum with no possibilities alert" [
			either error? err: catch [
				cmd_bad!: make-enum-type []
				none
			] [
				disarmed: disarm err
				if disarmed/id <> 'enum-no-possibilities [ err ]
				print form-error disarmed
			] [
				throw make error! "FAILURE: illegal enum with no possibilities was NOT detected"
			]
		]

		cmd!: make-enum-type command_names

		current_command: make-enum cmd! 'usage

		test-block "Illegal enum value setting alert" [
			either error? err: catch [
				set-enum current_command to-word "usage^/"
				none
			] [
				disarmed: disarm err
				if disarmed/id <> 'enum-illegal-value [ err ]
				print form-error disarmed
			] [
				throw make error! "FAILURE: illegal enum setting was NOT detected"
			]
		]

		test-block "Legal enum value setting" [
			foreach name command_names [
				set-enum current_command name
			]
		]

		test-block/reps (reduce rejoin ["Guarded switch-enum with " reps " repetitions"]) [
			v: pick command_names random length? command_names
			set-enum current_command v
			case_ran: false
			switch [
				usage [ either v = 'usage [case_ran: true] [
					throw make error! "FAILED: usage case ran" 
					]
				]
				print [ either v = 'print [case_ran: true] [
					throw make error! "FAILED: print case ran"
					]
				]
				help [ either v = 'help [case_ran: true] [
					throw make error! "FAILED: help case ran"
					]
				]
			]
			if not case_ran [ throw make error! "FAILED: required case was not run" ]
		] reps

		test-block "Incomplete switch cases alert" [
			if error? err: catch [
				switch-enum current_command [
					usage [ throw make error! "FAILED: usage case ran" ]
					print [ throw make error! "FAILED: print case ran" ]
				]
				none
			] [
				disarmed: disarm err
				if disarmed/id <> 'enum-incomplete-switch-cases [ err ]
				print form-error disarmed
			] [
				throw make error! "FAILURE: incomplete switch cases was NOT detected"
			]
		]

		test-block "Illegal switch case values alert" [
			either error? err: catch [
				switch-enum current_command [
					usaage [ throw make error! "FAILED: usaage case ran" ]
					print [ throw make error! "FAILED: print case ran" ]
					hellp [ throw make error! "FAILED: hellp case ran" ]
				]
				none
			] [
				disarmed: disarm err
				if disarmed/id <> 'enum-illegal-switch-cases [ err ]
				print form-error disarmed
			] [
				throw make error! "FAILURE: incomplete switch cases was NOT detected"
			]
		]

		test-block "Unreachable default case values alert" [
			either error? err: catch [
				switch-enum/default current_command [
					usage [ throw make error! "FAILED: usage case ran" ]
					print [ throw make error! "FAILED: print case ran" ]
					help [ throw make error! "FAILED: help case ran" ]
				] [ throw make error! "FAILED: unreachable default ran" ]
				none
			] [
				disarmed: disarm err
				if disarmed/id <> 'enum-unreachable-switch-default [ err ]
				print form-error disarmed
			] [
				throw make error! "FAILURE: unreachable case in default switch not detected"
			]
		]

		test-block "Default for switch is single case alert" [
			either error? err: catch [
				switch-enum/default current_command [
					usage [ throw make error! "FAILED: usage case ran" ]
					print [ throw make error! "FAILED: print case ran" ]
				] [ throw make error! "FAILED: default case ran for single possibility 'help'" ]
				none
			] [
				disarmed: disarm err
				if disarmed/id <> 'enum-switch-default-single [ err ]
				print form-error disarmed
			] [
				throw make error! "FAILURE: single case default not detected as error"
			]
		]
	]
]