REBOL [
    Title: "Map"
    Date: 17-Nov-2002
    Name: 'Map
    Version: 1.4.1
    File: %map.r
    Author: "Andrew Martin"
    Needs: [%Arguments.r]
    Purpose: {Maps or applies the function to all elements of the series.}
    eMail: Al.Bri@xtra.co.nz
    Web: http://valley.150m.com
    Acknowledgements: [
    "Joel Neely" 
    "Ladislav"
]
    Example: [
    Map func [n [number!]] [n * n] [1 2 3] 
    Map [1 2 3] func [n [number!]] [n * n] 
    Map [1 2 3 4 5 6] func [a] [print [a]] 
    Map [1 2 3 4 5 6] func [a b] [print [a b]] 
    Map [1 2 3 4 5 6] func [a b c] [print [a b c]]
]
    library: [
        level: 'beginner 
        platform: none 
        type: 'tool 
        domain: none 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

Map: function [
	{Maps or applies the function to all elements of the series.} [catch]
	Arg1 [any-function! series!]
	Arg2 [any-function! series!]
	/Only "Inserts the result of the function as a series."
	/Full "Doesn't ignore none! values."
	][
	Result Results Function Series
	][
	throw-on-error [
		any [
			all [
				any-function? :Arg1 series? :Arg2
				(Function: :Arg1 Series: :Arg2)
				]
			all [
				any-function? :Arg2 series? :Arg1
				(Function: :Arg2 Series: :Arg1)
				]
			throw make error! reduce [
				'script 'cannot-use rejoin [
					{"} mold 'Map " " mold type? :Arg1 {"}
					]
				rejoin [
					{"} mold type? :Arg2 {"}
					]
				]
			]
		Results: make Series length? Series
		do compose/deep [
			foreach [(Arguments :Function)] Series [
				if (
					either Full [
						compose [not unset? set/any 'Result Function (Arguments :Function)]
						] [
						compose/deep [
							all [
								not unset? set/any 'Result Function (Arguments :Function)
								not none? Result
								]
							]
						]
					)
				[
					(either Only ['insert/only] ['insert]) tail Results :Result
					]
				]
			]
		Results
		]
	]
