REBOL [
    Title: "Clone"
    Date: 20-Dec-2002
    Name: 'Clone
    Version: 1.0.1
    File: %clone.r
    Author: "Andrew Martin"
    Purpose: "Clone objects by copying objects inside."
    eMail: Al.Bri@xtra.co.nz
    Web: http://valley.150m.com
    Acknowledgements: "Erin A. Thomas"
    Example: [
    New_object: Clone Original_Object []
]
    Bug!: {
^-^-Clone destroys 'bind information during copy/deep of block!s!!!!
^-^-}
    library: [
        level: 'advanced 
        platform: none 
        type: 'tool 
        domain: none 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

Clone: function [
	{Clones all sub-objects and hashes, so there are no multiple references.}
	[catch]
	Object [object!] "The object to clone."
	Block [block!] "Extra code for this object."
	] [
	Cloned Member
	] [
	throw-on-error [
		Cloned: make Object Block
		foreach Word next first Object [
			Member: get in Cloned :Word
			if same? :Member get in Object :Word [
				set in Cloned :Word either object? :Member [
					Clone :Member []
					][
					either any [
						series? :Member
						port? :Member
						bitset? :Member
						][
						copy/deep :Member
						][
						:Member
						]
					]
				]
			]
		Cloned
		]
	]
