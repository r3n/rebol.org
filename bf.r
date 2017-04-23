REBOL [
	Title:	"Brainfuck"
	Author:	"John Niclasen"
	Date:	21-Mar-2009
	File:	%bf.r
	Purpose: {
		REBOL implementation of this language: http://en.wikipedia.org/wiki/Brainfuck
		bf is 232 bytes compressed (see end of script).
	}
]

bf: func [s] [
	p: make string! 3e4
	insert/dup p #{00} 3e4

	while [not tail? s] [
		switch s/1 [
			#">"	[p: next p s: next s]
			#"<"	[p: back p s: next s]
			#"+"	[p/1: either p/1 = 255 [#{00}][p/1 + 1] s: next s]
			#"-"	[p/1: either p/1 = 0 [#{ff}][p/1 - 1] s: next s]
			#"."	[prin p/1 s: next s]
			#","	[change p input s: next s]
			#"["	[
				if p/1 = 0 [
					c: 1
					until [
						switch first s: next s [
							#"["	[c: c + 1]
							#"]"	[c: c - 1]
						]
						c = 0
					]
				]
				s: next s
			]
			#"]"	[
				c: 1
				until [
					switch first s: back s [
						#"]"	[c: c + 1]
						#"["	[c: c - 1]
					]
					c = 0
				]
			]
		]
	]
]

bf: do decompress #{
789C7590DD6E83300C855FC50B97FD01D6F506F5E741AC5CB02C2956698A8851
2B4D7BF739199BA0EA72E5F8F83B398E1BBCC1A0B1ABE0529F2D04EEC99F5E60
63DF807CB03DE71F43071D649F45F195DAB7865A8BFECAC035B547103ADC884D
03212F31530715DDBCBDB36061AC82CED42E09EFB5393F080B11F2B2024BDCD8
1EA4863DBC6EB7981ED5518405947ACAAC9E318510CE8DC4EA81580B21CBA5D1
697FA9D034B53F594945BE1B78A6A242727FF6A6821206CFD4FEEEECA80F1302
1321632625CE941E6F318D36D144CF52FDE8FF99A6CF8AA67A668A4F4CE57C03
F00D8B8FCD010000
}
