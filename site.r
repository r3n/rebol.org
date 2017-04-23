REBOL [
    Title: "Site"
    Date: 21-Dec-2002
    Name: 'Site
    Version: 1.2.2
    File: %site.r
    Author: "Andrew Martin"
    Purpose: {
^-^-Site dialect. Creates web sites from plain text, etc.
^-^-I use it to create my own site automatically.
^-^-}
    eMail: Al.Bri@xtra.co.nz
    Web: http://valley.150m.com
    library: [
        level: 'advanced 
        platform: none 
        type: [tool] 
        domain: [web markup] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

Site: make object! [
	Site: none
	Values: none
	Resource: function [Block [block!] File [file!]] [Path] [
		Path: %./
		until [
			if found? find Block File [
				return join Path File
				]
			Path: join Path %../
			none? Block: Block/..
			]
		none
		]
	Page!: make object! [
		Title: string!
		File: file!
		Block: block!
		Location: func [File [file!]] [
			Resource Block File
			]
		Body-Attributes: [
			body/bgcolor/text/link/vlink/alink #FFFFFC #000000 #CC0000 #330099 #FF3300
			]
		Dialect: [
			<?xml version="1.0" encoding="ISO-8859-1"?>
			<!DOCTYPE html PUBLIC
				"-//W3C//DTD XHTML 1.1 plus MathML 2.0 plus SVG 1.1//EN"
				"http://www.w3.org/2002/04/xhtml-math-svg/xhtml-math-svg.dtd">
			html [
				head [
					title (Title)
					]
				(Body-Attributes) [(eText-Dialect)]
				]
			]
		eText-Dialect: block!
		Layout: func [eText [block!]] [
			eText-Dialect: eText
			compose bind Body-Attributes 'self
			compose/deep bind Dialect 'self
			]
		]
	Default: make Page! [
		;Dialect: append select copy Dialect 'Header [
			;StyleSheet (Location %Stylesheet.css)
			;]
		]
	Core: make Page! []
	RecurseDirectory: function [Directory [file!]] [Files Dialect] [
		Files: sort read Directory
		Dialect: make block! length? Files
		foreach File Files [
			append Dialect either #"/" = last File [
				use [Block] [
					Block: RecurseDirectory Directory/:File
					Block/..: Dialect
					reduce [File Block]
					]
				] [
				File
				]
			]
		repend Dialect ['. Dialect '.. none]	; '. = self; '.. = parent
		]
	Generate: function [Remote [file! url!] Local [file!]] [Block Directory] [
		Delete-Directory Remote
		md Remote
		Block: none
		Core/File: join head remove back tail second split-path Local %.html
		Directory: make object! [
			File: none
			Stack: make block! 10
			Rule: [
				any [
					set File file! into [
						(
							Local: Local/:File
							Remote: Remote/:File
							push Stack Core/File
							Core/File: join head remove back tail second split-path File %.html
							md Remote
							push/only Stack Block
							)
						Block: Rule
						(
							Local: clean-path join Local %../
							Remote: clean-path join Remote %../
							Block: pop Stack
							Core/File: pop Stack
							)
						]
					| set File file! (
						any [
							if %.txt = Extension? File [
								Page: Resource Block Extension copy File %.r
								Page: any [
									if not none? Page [
										do join Local Page
										]
									if (name? Core/File) = (name? File) [
										clone Core []
										]
									Default
									]
								Page/Block: Block
								Page/Title: name? File
								Page/File: Extension copy File %.html
								write join Remote Page/File ML Page/Layout
									eText read Local/:File
								write Remote/:File read Local/:File
								]
							if all [
								%.r = extension? File
								not found? find Block Extension copy File %.txt
								] [
								use [R Index] [
									R: load/all Local/:File
									if 'Rebol != first R [
										R: first R
										]
									either found? find second R ['eText] [
										R: at R 3
										do bind R 'File
										] [
										if found? Index: find R first [Site:] [
											change next Index Site
											]
										if found? Index: find R first [Values:] [
											change next Index Values
											]
										save Remote/:File R
										]
									]
								]
							if found? find [%.css %.js %.html %.htm] extension? File [
								write Remote/:File read Local/:File
								]
							write/binary Remote/:File read/binary Local/:File
							]
						)
					]
				'. block!
				'.. [block! | none!]
				]
			]
		parse RecurseDirectory Local repend [Block:] [Directory/Rule 'end]
		]
	]
