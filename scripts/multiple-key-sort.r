REBOL [
    Title: "Sort by multiple keys"
    Date: 17-Apr-2006
    File: %multiple-key-sort.r
    Author: "Cesar Chavez"
    Purpose: {	Function to sort series with more than one field per record, by multiple keys, in any position and in ascending
				or descending order each one of them.}
    Comment: {	How to use:
					Suppose that you have a serie with four fields per record like this:

						serie-to-sort: [name1 date1 amount1 address1 name2 date2 amount2 address2 ... ... ... ...]

					If you want to sort this serie by address, and then by date and then by name, all in ascending order, 
					you simply must do this:

						sort/skip/compare/all serie-to-sort 4 [4 2 1]

					But, if you want to sort by address in descending order, then by name in ascending order, then by amount in 
					descending order, you need to write a function for the /compare refinement, and here is where this function 
					will help you, writing this sentence:

						sort/skip/compare/all serie-to-sort 4 mks [-4 1 -3]

					The absolute values of integers in block are references to field position in record, positive values imply 
					ASCending order, and negative ones imply DESCending order, mks is the name of the function. The function
					only validations are simple ones for non integers or zero elements in block argument, letting to the sort 
					action all the others validations.

					Examples:

						sf: mks [1 3 -2]								You can make the function and then use it
						sort/skip/compare/all fields 3 get 'sf

						sort/skip/compare/all fields 3 mks [1 3 -2]		Or you can make and use the function on the fly

	}
    Version: 1.1.1 ; majorv.minorv.status
                   ; status: 0: unfinished; 1: testing; 2: stable
    History: [
        17-Apr-2006 1.1.1 "History start"
    ]

	Library: [
    	level: 'intermediate
        platform: [all]
        type: [function]
        domain: [text text-processing]
        tested-under: ["REBOL/View 1.3.1.3.1 WinXP"]
        support: none
        license: 'bsd
	]
]

mks: func [keys [block!]/local keyr f1 f2 i j x y o][
	o: copy "> <"
	keyr: reverse copy keys
	x: copy ""
	y: copy ""
	f2: copy []
	foreach e keyr [
		if error? try [i: abs e][return [0]]
		if error? try [j: (e / i) + 2][return [0]]
		append f2 rejoin [x "a/" i " " o/:j " b/" i y]
		x: "]["
		y: "]"
	]
	f1: copy []
	repeat k (length? keys) - 1 [
		i: abs keys/:k
		append f1 rejoin ["either = a/" i " b/" i " ["]
	]
	first reduce load rejoin ["func [a b] [" f1 f2 "]"]
]

