rebol [
	File: %addr.r
	Date: 10/03/2005
	Version: 1.0.0
	Title: "Addr"
	Purpose:  "Convert C data to Rebol - get the memory address and cast* to a given struct or array"
	Author: "Romano Paolo Tenca"
	Note: {
		Define 2 functions:
			& 		to get the address of a Rebol string! binary! or struct!
			cast*	to get the content of an address and cast it to a Rebol struct

		The Type argument of the cast* function can be a Rebol struct spec, es.:

			[i [integer!] i2 [short] i3 [short] i4 [char]]

		or a block with a sequence of [number type ...], es.

			[1 long 2 short 2 char]

		or a number followed by a block. This can be useful for arrays, es.:

			[30 [1 long 2 short 1 char 1 char]]

		an array of 30 C struct of the type {long; short; short; char; char}

			[25	[i [integer!] i2 [short] i3 [short]]]

		an array of 25 C struct of the type {long; short; short}

		Pay attention to alignement of C type!!
	}
	Date: 10/03/2005
	Library: [
        level: 'intermediate
        platform: 'all
        type: [function]
        domain: [external-library]
        tested-under: none
        support: none
        license: none
        see-also: none
    ]
]
context [
	mode: get-modes system:// 'endian
	system/words/addr-to-int: func [
		"Convert a binary in an integer - little of big endian aware"
		b [binary!]
		/endian "Force an endian mode" lmode [word!] "'little or 'big"
	] [
		to integer! either 'little = any [lmode mode] [head reverse copy b][b]
	]
	system/words/&: func [
		"Return the memory address of a binary, string or struct as a binary value"
		b [binary! string! struct!]
	][
		third make struct! [s [string!]] reduce [either struct? b [third b][b]]
	]
	system/words/cast*: func [
		"Return the content of a binary memory address as a struct!"
		pointer [binary!]
		type [block!] "Spec for data: es. [2 short 1 long] or [i [integer!]]"
		/local spec n
	][
		spec: copy/deep [inner [struct! []]]
		n: 1
		if all [integer? type/1 block? type/2] [n: type/1 type: type/2]
		loop n [
			either integer? type/1 [
				foreach [size type] type [
					insert/dup tail spec/2/2 reduce ['. reduce [type]] size
				]
			][insert spec/2/2 type]
		]
		spec: make struct! spec none
		change third spec pointer
		spec/inner
	]
]
do [
	;examples and tests
	probe value: #{0100 0200 0300 0400}
	print ["address of binary! is" & value "=" addr-to-int & value]
	print ["content is"  mold second cast* & value [8 char]]
	print ["content is"  mold second cast* & value [4 short]]
	print ["content is"  mold second cast* & value [i [short] i2 [short] i3 [short] i4 [short]]]
	print ["content is"  mold second cast* & value [2 long]]
	probe value: make struct! [i [integer!] i2 [integer!]] [6 33]
	print ["address of struct! is" & value "=" addr-to-int & value]
	print ["content is"  mold third value]
	print ["content is"  mold second cast* & value [8 char]]
	print ["content is"  mold second cast* & value [4 short]]
	print ["content is"  mold second cast* & value [2 long]]
	print ["content is"  mold second cast* & value [2 char 1 long 1 short]]
	probe value: make struct! [s [string!] i [integer!]] ["C string" 33]
	print ["address of struct! is" & value "=" addr-to-int & value]
	print ["content is"  mold third value]
	print ["content is"  mold second cast* & value [8 char]]
	print ["content is"  mold second cast* & value [4 short]]
	print ["content is"  mold second cast* & value [2 long]]
	print ["content is"  mold second cast* & value [1 char* 1 long]]
	probe value: make struct! [s [string!] i [struct! [i [integer!]]]] ["C string" 1134]
	print ["address of struct! is" & value "=" addr-to-int & value]
	print ["content is"  mold third value]
	print ["content is"  mold second cast* & value [1 long 2 short]]
	print ["content is"  mold second cast* & value [i [integer!] i2 [short] i3 [short]]]
	print ["content is"  mold second cast* & value [2 long]]
	print ["content of inner struct is"  mold second cast* & value [s [string!] i [struct! [i [integer!]]]]]
	probe value: #{0100 0200 0300 0400 0100 0200 0300 0400}
	print ["address of binary! is" & value "=" addr-to-int & value]
	print ["content is"  mold second cast* & value [8 short]]
	print ["content is"  mold second cast* & value [4 [1 short 1 char]]]
	probe value: make struct! [s [string!] i [integer!] s [string!] i [integer!] s [string!] i [integer!]] ["C string 1" 10 "C string 2" 20 "C string 3" 30]
	print ["address of struct! is" & value "=" addr-to-int & value]
	print ["content is"  mold second cast* & value [3 [1 string! 1 long]]]
	print ["content is"  mold second cast* & value [3 [i [string!] n [long]]]]
	halt
]
