REBOL[
	File: %tj-map.r
	Date:  9-Jan-2007
	Title: "Map"
	Purpose: {Applying a function to items in a list}
	Author: ["A J Martin"" Tim Johnson"]
	Needs: [%tj-operators.r]
	email: tim@johnsons-web.com
	Category: [util 1]
	Acknowledgements: [
		"Joel Neely" 
		"Ladislav"
		"Brett Handley"
		]
	Library: [
		level: 'intermediate
		platform: 'all
		type: [Function]
		domain: [dialects ai extension] 
		tested-under: "Linux, CGI"
		support: ["Tim Johnson" tim@johnsons-web.com]
		license: none
		see-also: none
		]
	NOTES: ["An earlier and more verbose edition of 'Arguments is posted"
		"at rebol.org. I received this as part of a download from Martin,"
		"and this deserves exposure"
		]
	History: {This is (hopefully) an enhancement of the original function
			provided to me by Andrew Martin. Additions and changes are
			Noted by (TJ) in code comments}
	Examples: [
		"Map func [n [number!]] [n * n] [1 2 3]"
		"Map [1 2 3] func [n [number!]] [n * n]"
		"Map [1 2 3 4 5 6] func [a] [print [a]]"
		"Map [1 2 3 4 5 6] func [a b] [print [a b]]"
		"Map [1 2 3 4 5 6] func [a b c] [print [a b c]]"
	        {rejoin Map/with ["name" "tim" "age" 40] func[a][a] ["&" "="]}
		]
	]
Arguments: func [
	"Returns the arguments of the function as a block of word! values."
	F [any-function!] "The Function" ] [
	head clear any [
		find first :F refinement!
		tail first :F
		]
	]
Map: function [	{Maps or applies a function to all elements of the series.} 
	[catch]
	Arg1 [any-function! series!] Arg2 [any-function! series!]
	/Only "Inserts the result of the function as a series."
	/Full "Don't ignore none! value."
	/with sep [any-type!] 
	"insert between elements of the series. If block, alternate elements"
	][ Function Series Result Results Words aligned ndx][
	if with[
		sep: compose[(sep)] ;; force to block
		ndx: 1
		] 
	throw-on-error [
		any [
			all [any-function? :Arg1 series? :Arg2
				 (Function: :Arg1 Series: :Arg2)]
			all [any-function? :Arg2 series? :Arg1
				 (Function: :Arg2 Series: :Arg1)
			] ;; changed (TJ)
			throw make error! 
				"'Map must have one argument of type function! and one argument of type series!"
			]
		Results: make Series length? Series
		Words: Arguments :Function ;; added (TJ)
		aligned: length? Words     ;; added (TJ)
		if 0 <> ((length? Series) // aligned)[ ;; added (TJ)
			throw make error! rejoin["'Series length (" length? Series 
				") not evenly divisible by 'Function arguments (" aligned ")"]
			]
		do compose/deep [
			foreach [(Words)] Series [
				if not any [
					unset? set/any 'Result Function (Words)
					(pick [[none? :Result] []] not Full)
					] [
					(pick [insert insert/only] not Only) tail Results :Result
					if with[ ;; block added (TJ)
						append Results sep/:ndx
						++- ndx sep	;; increment or set to 1 if bounds exceeded	
						]
					]
				]
			]
		if with[remove back tail results] ;; drop last 'sep member. Added (TJ)
		Results
		]
	]
