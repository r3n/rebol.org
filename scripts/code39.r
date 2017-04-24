REBOL [
	Title: "Code 3 of 9 (Code 39) Barcode Generator"
	Date: 16-Apr-2006
	Author: "Bohdan Lechnowsky"
	File: %code39.r
	Purpose: {
		Generates Code 39 barcode images which can be printed out and read with a
		standard barcode reader.

		Code 39 is limited to the alphanumeric characters listed in the 'code39
		block within the function.

		It is a very popular barcode format in the US and doesn't need to conform
		to any particular length of characters and has no limitations placed on it
		by any sanctioning body regarding what it can be used for.

		This version does not support checksum digits, but this could be added
		easily.  Perhaps in a future version.

		Wrote this to generate barcodes for my corporation, "RespecTech, Inc.", to
		internally track inventory.
	}
    Library: [
        level: 'intermediate
        platform: 'all
        type: [tool how-to]
        domain: [printing]
        tested-under: none
        support: none
        license: none
        see-also: none
        ]

]

barcode: func [
	{Barcode Image Generator}
	data [string!] {String to be converted into Code 39 format}
	/barcode-height height [integer!] {Height to make the barcode}
	/outfile name [file! url!] {Name to save barcode as - should be followed by ".png"}
	/local code39 convfrom out x pattern
][
	if not value? 'height [height: 40]	;Default is 40
	if not value? 'name [name: %code39.png]

	code39: [
		"1"	"110100101011"
		"2" "101100101011"
		"3" "110110010101"
		"4" "101001101011"
		"5"	"110100110101"
		"6" "101100110101"
		"7" "101001011011"
		"8"	"110100101101"
		"9"	"101100101101"
		"0" "101001101101"
		"A" "110101001011"
		"B" "101101001011"
		"C" "110110100101"
		"D"	"101011001011"
		"E"	"110101100101"
		"F"	"101101100101"
		"G"	"101010011011"
		"H"	"110101001101"
		"I"	"101101001101"
		"J" "101011001101"
		"K" "110101010011"
		"L" "101101010011"
		"M" "110110101001"
		"N" "101011010011"
		"O" "110101101001"
		"P" "101101101001"
		"Q" "101010110011"
		"R" "110101011001"
		"S" "101101011001"
		"T" "101011011001"
		"U" "110010101011"
		"V" "100110101011"
		"W" "110011010101"
		"X" "100101101011"
		"Y" "110010110101"
		"Z" "100110110101"
		"-" "100101011011"
		"."	"110010101101"
		" " "100110101101"
		"*" "100101101101"
		"$" "100100100101"
		"/" "100100101001"
		"+"	"100101001001"
		"%" "101001001001"
	]

	convfrom: rejoin ["*" data "*"]

	out: copy [backdrop white]

	x: 0
	foreach char convfrom [
		pattern: select code39 form char
		foreach bit pattern [
			x: x + 1
			if bit = #"1" [
				append out compose [
					at (to-pair reduce [x + 20 20])
					box (to-pair reduce [1 height]) black
				]
			]
		]
		x: x + 1
	]

	save/png name to-image layout out
	browse name
]

barcode ask "Data to convert to Code 39: "
