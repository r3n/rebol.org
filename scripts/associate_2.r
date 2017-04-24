REBOL [
    Title: "Associate"
    Date: 15-Aug-2002
    Name: 'Associate
    Version: 1.2.0
    File: %associate.r
    Author: "Andrew Martin"
    Purpose: "Provides an associative memory store."
    eMail: Al.Bri@xtra.co.nz
    Web: http://valley.150m.com
    library: [
        level: 'beginner 
        platform: none 
        type: 'module 
        domain: none 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

Associate?: function [
	"Returns the Value corresponding to the Key from the Association."
	Association [series! port! bitset!]
	Key [any-type!]
	] [
	Associated
	] [
	if found? Associated: select/only/skip Association :Key 2 [
		first Associated
		]
	]

Associate: function [
	"Associates the Value with the Key in the Association."
	Association [series! port! bitset!]
	Key [any-type!]
	Value [any-type!]
	] [
	Associated
	] [
	either found? Associated: find/only/skip Association :Key 2 [
		either none? :Value [
			remove/part Associated 2
			] [
			change/only next Associated :Value
			]
		] [
		if not none? :Value [
			repend Association [Key Value]
			]
		]
	Association
	]

Associate-Many: function [
	"Associates the Value with the Key in the Association, and keeps the previous value."
	Association [series! port! bitset!]
	Key [any-type!]
	Value [any-type!]
	/Only	"Appends a block value as a block."
	] [
	Associated
	] [
	if none? :Value [
		return Associate Association :Key :Value
		]
	either found? Associated: Associate? Association :Key [
		if not block? Associated [
			Associated: reduce [Associated]
			Associate Association :Key Associated
			]
		either Only [
			insert/only tail Associated :Value
			] [
			insert tail Associated :Value
			]
		] [
		associate Association :Key :Value
		]
	Association
	]

Keys: func [Association [series! port! bitset!]][
	extract Association 2
	]
