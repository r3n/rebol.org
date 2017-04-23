REBOL [
    Title: "Wiki"
    Date: 24-Dec-2002
    Name: 'Wiki
    Version: 3.3.2
    File: %wiki.r
    Author: "Andrew Martin"
    Purpose: {Implements a Wiki using Rebol and the Xitami webserver.}
    eMail: Al.Bri@xtra.co.nz
    Web: http://valley.150m.com
    Comments: {
^-^-In %/Xitami/xitami.cfg -- the Xitami configuration file,
^-^-in the [Mime] section, add:
^-^-^-^-htc=text/plain
^-^-^-to allow the %Calender.htc hypertext component to be sent.
^-^-Caution: Hypertext components only work with MSIE!
^-^-Also, change:
^-^-^-^-js=application/x-javascript
^-^-^-to:
^-^-^-^-js=text/javascript
^-^-^-so as to correctly set the MIME for JavaScript files.
^-^-}
    library: [
        level: 'advanced
        platform: none
        type: 'tool
        domain: [other-net markup]
        tested-under: none
        support: none
        license: none
        see-also: none
    ]
]
Wiki_Files: %/C/Rebol/Wiki/Files/
if not value? 'Values [	; Rebol/Core doesn't run %User.r.
	do %/C/Rebol/Values/Values.r
	]
if none? Rebol/options/cgi/script-name [
	use [Remote] [
		Remote: %/C/Xitami/cgi-bin/
		foreach File read %. [
			if #"/" != last File [
				write/binary Remote/:File read/binary File
				]
			]
		browse rejoin [http://localhost/cgi-bin/ Rebol/script/header/File #"?"]
		]
	quit
	]
Script_URL: join make url! compose [
	http (join Rebol/options/cgi/server-name Rebol/options/cgi/script-name)
	] #"?"
Deplus: func [Value [string!]] [
	replace/all dehex replace/all Value #"+" #" " CRLF newline
	]
Encode: func [File [file!]] [
	replace/all to-string copy File #" " "%20"
	]
CGI_Script_File: to-file Rebol/options/cgi/script-name
Folder_File?: func [Folder [file!] File [file!]] [
	any [
		if #"/" != first Folder [
			Folder/:File
			]
		if %/ = Folder [
			File
			]
		all [
			Folder: remove copy Folder
			Folder/:File
			]
		]
	]
Wiki_File: function [Folder [file!] Page [time! date! string!]] [File] [
	File: any [
		if time? Page [
			replace/all form Page #":" #"="
			]
		if date? Page [
			form Page
			]
		Page
		]
	if not empty? File [
		File: join to-file File %.txt
		]
	if #"/" = first File: Folder/:File [
		remove File
		]
	File
	]
UnWiki_File: function [File [file!]] [Ext Name] [
	if %.bak = Ext: extension? File [
		return none
		]
	if %.txt = Ext [
		Clear_Extension File
		Name: name? File
		parse Name [
			[1 2 Digit #"-" 3 Alpha #"-" 4 Digit end] (
				replace/all File #"-" #"/"
				)
			|
			[1 2 Digit #"=" 1 2 Digit opt [#"=" 2 Digit] end] (
				replace/all File #"=" #":"
				)
			]
		]
	File
	]
Folder_Button: function [Folder [file!]] [Name] [
	Name: join name? Folder #"/"
	if all [
		#"/" = first Folder
		1 < length? Folder
		] [
		Folder: next Folder
		]
	compose/deep [
		input/type/value/onclick/title/class "button" (Name) (
			rejoin ["window.location='" Script_URL either %/ = Folder [""] [Folder] {'}]
			) (rejoin ["Click to change folder to: " Name]) "Folders"
		br
		]
	]
Folder_Buttons: function [Folder [file!] Page [file! string! time! date! none!]] [Buttons] [
	if #"/" != first Folder [
		Folder: head insert copy Folder #"/"
		]
	Buttons: make block! 100
	if none? Page [
		Folder: folder? Folder
		]
	if Folder [
		until [
			append Buttons Folder_Button Folder
			none? Folder: folder? Folder
			]
		compose/deep [form [(Buttons)]]
		]
	]
See-Other: func [URL [url!]] [
	print rejoin [
		Rebol/options/cgi/server-protocol " 303 See Other" newline
		"Location: " URL newline
		]
	quit
	]
Envelope: func [Title [string!] Body [block!]] [
	content-type 'text/html
	print newline
	print ML compose/deep [
		<?xml version="1.0" encoding="ISO-8859-1"?>
		<!DOCTYPE html PUBLIC
			"-//W3C//DTD XHTML 1.1 plus MathML 2.0 plus SVG 1.1//EN"
			"http://www.w3.org/2002/04/xhtml-math-svg/xhtml-math-svg.dtd">
		html [
			head [
				title (Title)
				link/rel/type/href "stylesheet" "text/css" (%Tablesort.css)
				script/type/src "text/javascript" (%TableSort.js) ""
				link/rel/type/href "stylesheet" "text/css" (%Wiki.css)
				script/type/src "text/javascript" (%Wiki.js) ""

				;link/rel/type/href "stylesheet" "text/css" (%HtmlArea.css)
				;script/type/src "text/javascript" (%HtmlArea.js) ""

				]
			(Body)
			]
		]
	quit
	]
Nice: func [Title [string!] Folder [file!] Page [file! string! time! date! none!] Center [block!] /Edit] [
	Envelope reform [rebol/script/header/Title #"-" Title] compose/deep [
		body [
			div/id "Left_Column" [
				(Folder_Buttons Folder Page)
				(Random_Page/GUI)
				(Search_Pages/GUI Page)
				(if Edit [Edit_Page/GUI Folder Page])
				]
			div/id "Center_Column" [
				(Center)
				]
			]
		]
	]
Choose_Page: func [
	Title [string!] Folder [file! none!] Files [block!]
	Page [string! time! date!]
	] [
	Nice Title Folder Page compose/deep [
		h1 (Title)
		p/class "Initial" [
			{Matches for: "} span/class "Hilight" (Page) (
				if %/ != Folder [
					compose [{", in the folder: "} span/class "Hilight" (Folder)]
					]
				) {"; include: }
			]
		ul [(
			map Files func [File [file!]] [
				compose/deep [
					li [
						a/href (
							rejoin [
								Rebol/options/cgi/script-name #"?"
								either #"/" = last File [""] [#"/"]
								Encode Folder_File? Folder File
								]
							)
						(File)
						]
					]
				]
			)]
		]
	]
Match_Name: make object! [
	Title: "Match"
	Action: function [Folder [file!] Page [string! time! date!]] [Files] [
		Files: map map recursive-read Wiki_Files/:Folder :UnWiki_File func [File [file!]] [
			if found? find name? File Page [
				File
				]
			]
		if empty? Files [
			See-Other join Script_URL join Folder Page
			]
		if 1 = length? Files [
			See-Other join Script_URL join Folder first Files
			]
		Choose_Page Title Folder Files Page
		]
	Folder: %/
	Page: none
	set 'Match_Name^ compose [
		opt [set Folder file!] set Page [string! | time! | date!] 'Elipsis end
		(make paren! [Action Folder Page])
		]
	]
Search_Pages: make object! [
	Title: "Search"
	Action: function [Phrase [file! string! time! date!]] [Results Index Text] [
		Phrase: form Phrase
		Results: map recursive-read Wiki_Files func [File [file!]] [
			if all [
				%.txt = extension? File
				found? Index: find Text: read Wiki_Files/:File Phrase
				] [
				File: UnWiki_File File
				compose/deep [
					tbody [
						tr [
							td [
								(rejoin ["..." copy/part Index -35])
								span/class "Hilight" (copy/part Index length? Phrase)
								(append copy/part at Index 1 + length? Phrase 35 "...")
								]
							td [a/href (rejoin [CGI_Script_File #"?" File]) (File)]
							]
						]
					]
				]
			]
		Nice rejoin [Title ": " Phrase] %/ Phrase compose/deep [
			table/onclick "sortColumn(event)" [thead [tr [th "Results" th "Page"]] (Results)]
			]
		]
	Phrase: none
	set 'Search_Pages^ compose [
		(to-lit-word Title) set Phrase [file! | string! | time! | date!] end (
			make paren! [Action Phrase]
			)
		]
	GUI: function [Phrase [file! string! time! date! none!]] [Hint] [
		Hint: either none? Phrase [
			Phrase: ""
			{Click button to search for phrase in every page.}
			] [
			rejoin [
				{Click button to search for '} Phrase {' in every page.}
				]
			]
		compose/deep [
			form/id/name/method/action (Title) (Title) "GET" (CGI_Script_File) [
				label [
					(rejoin [Title #" " Rebol/script/header/title ": "]) br
					input/type/name/value/title "text" (join Magic Title) (form Phrase)
						"Enter the search phrase here."
					]
				input/type/value/title "submit" (Title) (Hint)
				]
			]
		]
	]
Magic: #"*"
Random_Page: make object! [
	Title: "Random"
	Action: has [Files File Ext] [
		random/seed now
		Files: random recursive-read Wiki_Files
		File: foreach File Files [
			Ext: extension? File
			if %.txt = Ext [
				Clear_Extension File
				]
			if %.bak != Ext [
				break/return File
				]
			]
		See-Other rejoin [Script_URL File]
		]
	set 'Random_Page^ compose [(to-lit-word Title) (Title) end (make paren! [Action])]
	GUI: does [
		compose/deep [
			form/id/name/method/action (Title) (Title) "GET" (CGI_Script_File) [
				input/type/name/value "hidden" (join Magic Title) (Title)
				input/type/value/title "submit" (Title) "Click for a random page"
				]
			]
		]
	]
Save_Page: make object! [
	Title: "Save"
	Action: function [Folder [file!] Page [string! time! date!] Text [string!]] [File] [
		File: Wiki_File Folder Page
		either empty? Text [
			if exists? Wiki_Files/:File [
				delete Wiki_Files/:File
				]
			See-Other rejoin [Script_URL Encode Folder]
			] [
			either exists? Wiki_Files/:File [
				write extension Wiki_Files/:File %.bak read Wiki_Files/:File
				] [
				md/deep folder? Wiki_Files/:File
				]
			write Wiki_Files/:File Text
			See-Other rejoin [Script_URL Encode Folder Encode to-file Page]
			]
		]
	Page: Folder: Text: none
	set 'Save_Page^ compose [
		'Page set Page [string! | time! | date!]
		'Folder set Folder file!
		'Text set Text string! end
		(make paren! [Action Folder Page Text])
		]
	GUI: func [Folder [file!] Page [time! date! string!] Text [string!]] [
		compose/deep [
			form/id/name/method/action (Title) (Title) "POST" (CGI_Script_File) [
				h1 (Page)
				input/type/name/value "hidden" (join Magic "Page") (Page)
				input/type/name/value "hidden" (join Magic "Folder") (to-string Folder)
				textarea/name/rows/cols/wrap/style (join Magic "Text") 25 80 "virtual" "width:100%;" (Text)
				;textarea/name/id/style "*Text" "*Text" "width:100%; height:200" [(eText/Wiki/Base Text Script_URL)]
				;script/language "javascript1.2" {
				;	editor_generate('*Text');
				;	}
				input/type/value/title "submit" "Save" "Saves your changes"
				]
			]
		]
	]
Get_Page: function [Folder [file!] Page [time! date! string!]] [File Title] [
	File: Wiki_File Folder Page
	either exists? Wiki_Files/:File [
		read Wiki_Files/:File
		] [
		rejoin [
			Title: form Page newline
			head insert/dup copy "" #"*" length? Title newline
			either date? Page [rejoin [weekday? Page newline]] [""]
			]
		]
	]
Edit_Page: make object! [
	Title: "Edit"
	Action: function [Folder [file!] Page [time! date! string!]] [File] [
		File: Wiki_File Folder Page
		Envelope reform [Page #"-" Rebol/script/header/Title] compose/deep [
			body [
				div/id "Left_Column" [
					(Folder_Buttons Folder Page)
					]
				div/id "Center_Column" [
					(Save_Page/GUI Folder Page Get_Page Folder Page)
					]
				]
			]
		]
	Folder: %/
	Page: none
	set 'Edit_Page^ compose [
		'Folder set Folder file! 'Edit set Page [time! | date! | string!] end
		(make paren! [Action Folder Page])
		]
	GUI: func [Folder [file!] Page [time! date! string!]] [
		compose/deep [
			form/id/name/method/action (Title) (Title) "GET" (CGI_Script_File) [
				input/type/name/value "hidden" (join Magic "Folder") (to-string Folder)
				input/type/name/value "hidden" (join Magic Title) (Page)
				input/type/value/title "submit" "Edit" "Click to edit this page"
				]
			]
		]
	]
make object! [
	View_Page: function [Folder [file!] Page [string! time! date!]] [Files File] [
		File: Wiki_File Folder Page
		Nice/Edit reform [Page #"-" Rebol/script/header/Title] Folder Page compose/deep [
			(eText/Wiki/Base Get_Page Folder Page Script_URL)
			]
		]
	Hunt: function [Page [string! time! date!]] [Files File Folder] [
		Files: map recursive-read Wiki_Files func [File [file!]] [
			if all [
				%.txt = extension? File
				Page = name? Unwiki_File File
				] [
				File
				]
			]
		if empty? Files [
			View_Page %/ Page
			]
		if 1 = length? Files [
			File: first Files
			Folder: folder? File
			either Folder [
				See-Other rejoin [Script_URL File]
				] [
				View_Page %/ Page
				]
			]
		if 1 < length? Files [
			Choose_Page "View" %/ Files Page
			]
		]
	Folder: Page: none
	set 'View_Page^ [
		opt [set Folder file!] set Page [string! | time! | date!] end (
			either none? Folder [
				Hunt Page
				] [
				View_Page Folder Page
				]
			)
		]
	]
Delete_Folder: make object! [
	Title: "Delete"
	Action: func [Folder [file!]] [
		delete-dir Wiki_Files/:Folder
		See-Other rejoin [Script_URL any [Folder? Folder ""]]
		]
	Folder: none
	set 'Delete_Folder^ compose [
		(to-lit-word Title) set Folder file! end (make paren! [Action Folder])
		]
	GUI: func [Folder [file!]] [
		compose/deep [
			form/method/action "GET" (CGI_Script_File) [
				input/type/name/value "hidden" (join Magic Title) (to-string Folder)
				input/type/value/title "submit" (Title) "Click to delete folder."
				]
			]
		]
	]
View_Folder: function [Folder [file!]] [Links] [
	if dir? Wiki_Files/:Folder [
		Links: map map read Wiki_Files/:Folder :UnWiki_File func [File [file!]] [
			compose/deep [
				li [
					a/href (
						rejoin [
							Rebol/options/cgi/script-name #"?"
							either #"/" = last File [""] [#"/"]
							Encode Folder_File? Folder
							File
							]
						)
					(File)
					]
				]
			]
		Nice form Folder Folder none compose/deep [
			h1 (form Folder)
			(
				either empty? Links [
					Delete_Folder/GUI Folder
					] [
					reduce ['ul Links]
					]
				)
			]
		]
	]
Mime-Data: func [Mime [path!] Data [binary!]] [
	print ["Content-Type:" :Mime newline]
	write-io system/ports/output Data length? Data
	quit
	]
View_File: func [Folder [file!] File [file!]] [
	if exists? Wiki_Files/:Folder/:File [
		; See: http://support.microsoft.com/default.aspx?scid=KB;EN-US;Q260519&
		; See: http://www.pasteur.fr/cgi-bin/mfs/01/18xx/1806
		if found? find [%.js %.r %.css %.csv %.doc %.rtf %.sdw %.txt %.pub] extension? File [
			print rejoin ["Content-disposition: attachment; filename=" File]
			]
		Mime-Data any [
			select [
				%.bmp image/bmp
				%.css text/css
				%.csv text/csv
; text/plain text/csv text/comma-separated-values text/x-csv application/csv
; application/vnd.ms-excel application/x-excel application/x-msexcel
				%.gif image/gif
				%.htm text/html
				%.html text/html
				%.jpg image/jpeg
				%.js text/javascript
				%.pdf application/pdf
				%.png image/png
				%.r	text/x-rebol
				%.rtf text/richtext	; application/rtf
				%.svg image/svg+xml
				%.tif image/tiff
				%.tiff image/tiff
				%.txt text/plain
				%.wav audio/wav
				%.xml text/xml
				%.xsl text/xml
				%.zip application/x-zip-compressed	; application/unzip
				] Extension? File
			'application/octet-stream
			] read/binary Wiki_Files/:Folder/:File
		]
	]
Column_Type: function [Column [string!]] [Type] [
	if Type: find Column #":" [
		Column: copy/part Column Type
		Type: copy/part next Type tail Type
		]
	reduce [Column Type]
	]
CSV_Page: function [Folder [file!] File [file!]] [CSV Columns Title] [
	if all [
		%.csv = extension? File
		exists? Wiki_Files/:Folder/:File
		] [
		CSV: read/lines Wiki_Files/:Folder/:File
		Columns: parse/all CSV/1 ","
		Title: reform [name? File]
		Envelope reform [rebol/script/header/Title #"-" Title] compose/deep [
			body [
				; http://msdn.microsoft.com/library/default.asp?url=/workshop/database/tdc/overview.asp
				object/id/classid "oTable" "clsid:333C7BC4-460F-11D0-BC04-0080C7055A83" [
					param/name/value "DataURL" (
						rejoin [
							make url! compose [
								http (rejoin [Rebol/options/cgi/server-name folder? CGI_Script_File %Alias.r])
								]
							#"?"
							Encode Folder
							Encode File
							]
						)
					param/name/value "UseHeader" "True"
					param/name/value "CharSet" "ISO-8859-1"
					]
				div/id "Left_Column" [
					(Folder_Buttons Folder File)
					(Random_Page/GUI)
					(Search_Pages/GUI form File)
					]
				div/id "Center_Column" [
					h1 (Title)
					h2 "Filter"
					label [
						"Column: " select/id "Column" [(
							use [Block Type] [
								Block: make block! 2 * length? Columns
								foreach Column Columns [
									set [Column Type] Column_Type Column
									append Block compose/deep [
										option/value (Column) (Column)
										]
									]
								Block
								]
							)]
						]
					select/id "Criteria" [
						option/value "&lt;" "&lt;"	; <
						option/value "&lt;=" "&lt;="	; <=
						option/value/selected "=" "selected" "="	; =
						option/value "&gt;=" "&gt;="	; >=
						option/value "&gt;" "&gt;"	; >
						option/value "&lt;&gt;" "&lt;&gt;"	; <> -- not equal.
						]
					label [
						"Value: " input/type/id/value "text" "Value" ""
						]
					input/type/value/onclick "button" "Filter" "Filter ()"
					input/type/value/onclick "button" "Reset" "Reset ()"
					script/language "JavaScript" {
						function Filter () {
							oTable.FilterColumn= Column.options[Column.selectedIndex].value;
							oTable.FilterCriterion=
								Criteria.options[Criteria.selectedIndex].value;
							oTable.FilterValue= Value.value;
							oTable.Reset ();
							}
						function Reset () {
							oTable.FilterColumn= "";
							oTable.FilterCriterion= "";
							oTable.FilterValue= "no data";
							Value.value= "";
							oTable.Reset ();
							}
						}
					hr
					table/id/datasrc/border/cellspacing "hTable" #oTable 1 0 [
						thead [
							tr [(
								use [Block Type] [
									Block: make block! 5 * length? Columns
									foreach Column Columns [
										set [Column Type] Column_Type Column
										append Block compose/deep [
											th/class/onMouseUp/onMouseDown/onclick
											"CSV" "MouseUp (this)" "MouseDown (this)"
											 (
												rejoin [
													{Sort_Column ('}
													Column
													{', this)}
													]
												) [(Column)]
											]
										]
									Block
									]
								)]
							]
						tbody [
							tr [(
								use [Block Type Right] [
									Block: make block! 2 * length? Columns
									foreach Column Columns [
										set [Column Type] Column_Type Column
										Right: find ["Float" "Int"] Type
										append Block compose/deep either Right [
											[
												td/align "right" [
													span/datafld (Column) ""
													]
												]
											][
											[
												td [
													span/datafld (Column) ""
													]
												]
											]
										]
									Block
									]
								)]
							]
						]
					p/class "Initial" [
						"Records: " (-1 + length? CSV) #"."
						]
					]
				]
			]
		]
	]
RNV_Contents: function [Folder [file!] File [file!]] [Blocks Index Name Title] [
	if not all [
		%.rnv = extension? File
		exists? Wiki_Files/:Folder/:File
		] [
		exit
		]
	RNV/Directory: Wiki_Files/:Folder
	Blocks: RNV/Value to-word name? File
	Index: make block! 2 * length? Blocks
	Name: to-word name? File
	repeat Block length? Blocks [
		insert tail Index reduce [
			RNV/Name Blocks/:Block Name Block
			]
		]
	sort/skip Index 2
	Nice Title: name? File Folder File compose/deep [
		h1 (Title)
		ul [(
			map Index func [Name Index [integer!]] [
				compose/deep [
					li [a/href (rejoin [Script_URL Folder File #"/" Index]) (form Name)]
					]
				]
			)]
		]
	]
RNV_Page: function [
	Folder [file!] File [file!] Index [integer! string!]
	] [Blocks Block Filename BlockName Name Phrase PageName Values] [
	if not all [
		%.rnv = extension? File
		exists? Wiki_Files/:Folder/:File
		] [
		exit
		]
	RNV/Directory: Wiki_Files/:Folder
	Blocks: RNV/Value to-word name? File
	Filename: name? File
	BlockName: to-word Filename
	if string? Index [
		Phrase: Index
		Index: any [
			repeat Index length? Blocks [
				if all [
					Name: Blocks/:Index/:BlockName
					Phrase = form Name
					] [
					break/return Index
					]
				]
			repeat Index length? Blocks [
				if all [
					Name: Blocks/:Index/:BlockName
					found? find form Name Phrase
					] [
					break/return Index
					]
				]
			1
			]
		]
	Block: pick Blocks Index
	Title: rejoin [
		Filename #"/" PageName: any [
			select Block BlockName
			RNV/Name Block BlockName
			]
		]
	Nice Title join Folder File form PageName compose/deep [
		h1 (Title)
		table/onclick "sortColumn(event)" [
			thead [
				tr [
					th "Name" th "Value"
					]
				]
			tbody [(
				map Block func [Name Value] [
					compose/deep [
						tr [
							td (join Name ": ") td [(
								any [
									if all [word? Name integer? Value Name != BlockName] [
										compose [
											a/href (
												rejoin [
													Script_URL Folder Name %.rnv #"/" Value
													]
												) (
												form RNV/NameValue Name Value
												)
											]
										]
									if all [word? Name block? Value] [
										Value: sort/skip map Value func [Value [integer!]] [
											reduce [
												RNV/NameValue Name Value
												rejoin [
													Script_URL Folder Name %.rnv #"/" Value
													]
												]
											] 2
										Values: remove map Value func [Click Link] [
											compose/deep [br a/href (Link) [(form Click)]]
											]
										either empty? Values [
											"Empty!"
											] [
											Values
											]
										]
									if all [file? Value %.png = extension? Value] [
										compose [
											img/src (
												rejoin [Script_URL Folder Name #"/" Value]
												)
											]
										]
									form Value
									]
								)]
							]
						]
					]
				)]
			]
		]
	]
File_Upload: make object! [
	Action: func [Folder [file!] File [file!] Content [string!] Mime [path!] Data [binary!]] [
		if (extension? File) = to-file find/last Content #"." [
			File: Folder/:File
			if exists? File [
				write/binary Extension Wiki_Files/:File %.bak read/binary Wiki_Files/:File
				]
			write/binary Wiki_Files/:File Data
			See-Other rejoin [Script_URL Folder? File]
			]
		]
	Folder: File: Content: Mime: Data: none
	set 'File_Upload^ compose [
		'Folder set Folder string! 'File set File string!
		'Content set Content string! set Mime path! set Data binary! end
		(make paren! [Action to-file Folder to-file File Content Mime Data])
		]
	Page: function [Folder [file!] File [file!]] [Title] [
		Nice Title: "File Upload" Folder name? File compose/deep [
			h1 (Title)
			p/class "Initial" [
				{Folder: "} span/class "Hilight" (Folder)
				{"; File: "} span/class "Hilight" (File) {".}
				]
			form/enctype/method/action "multipart/form-data" "POST" (CGI_Script_File) [
				input/type/name/value "hidden" "Folder" (to-string Folder)
				input/type/name/value "hidden" "File" (File)
				label ["Your file: " input/type/name/value "file" "Content" (File)] br
				input/type/value/title "submit" (Title) "Click button to upload file to Wiki"
				]
			]
		]
	]
Query_String: any [
	if "GET" = Rebol/options/cgi/request-method [
		Rebol/options/cgi/query-string
		]
	if "POST" = Rebol/options/cgi/request-method [
		use [Length] [
			Query_String: make string! 2 +
				Length: to-integer Rebol/options/cgi/content-length
			read-io Rebol/ports/input Query_String Length
			Query_String
			]
		]
	none
	]
if any [
	none? Query_String
	empty? Query_String
	] [
	View_Folder %/
	]
Decode_Multipart: function [String [string!]] [Block Disposition Divider Name Value Type] [
	Block: make block! 10
	Disposition: [{Content-Disposition: form-data; name="} copy Name some Alpha {"}]
	parse/all String [
		copy Divider [some #"-" some Graphic] (insert Divider CRLF)
		some [
			CRLF
			Disposition CRLF
			CRLF
			copy Value to Divider (repend Block [to-word Name Value])
			Divider
			]
		CRLF
		Disposition {; filename="} copy Value to {"} skip CRLF (
			repend Block [to-word Name Value]
			)
		"Content-Type: " copy Value [some Alpha #"/" some [Alpha | #"-" | #"+"]] CRLF (
			append/only Block load Value
			)
		CRLF
		copy Value to Divider (append Block to-binary Value) Divider "--" CRLF
		end
		]
	Block
	]
Decode_Magic_CGI: function [
	{Converts CGI argument string to a block of set-words and value strings.}
	Args [any-string!] "Starts at first argument word."
	] [
	Block Word Attr Value
	] [
	Block: make block! 7
	parse/all Args [
		some [
			Magic copy Word some Alpha #"=" (
				append Block to-word Word
				)
			[copy Attr to #"&" skip | copy Attr to end]
			(
				append Block either none? Attr [
					copy ""
					] [
					Attr: Deplus Attr
					either parse/all Attr [
						copy Value [Date^ | Time^] (Value: load Value)
						| copy Value [Folder-File^ | Folder^ | File^] (Value: to-file Value)
						end
						] [
						Value
						] [
						Attr
						]
					]
				)
			]
		end
		]
	Block
	]
Command: []
make object! [
	Forbidden: {:*?"<>|/\.}	; A Wiki/Windows file name cannot contain any of these characters.
	Permitted: complement charset Forbidden
	Elipsis?: false
	Elipsis^: [opt ["..." (Elipsis?: true)]]
	Value: none
	Time: [copy Value Time^ Elipsis^ (Value: load Value)]
	Date: [copy Value Date^ Elipsis^ (Value: load Value)]
	File: [copy Value File^ (Value: to-file Deplus Value)]
	Name: [copy Value some Permitted Elipsis^ (Value: Deplus Value)]
	Folder: [copy Value Folder^ (Value: to-file Deplus Value)]
	Folder-File: [copy Value Folder-File^ (Value: to-file Deplus Value)]
	Folder_Start: Folder_End: none
	all [
		any [
			not empty? Command: Decode_Multipart Query_String
			not empty? Command: Decode_Magic_CGI Query_String
			all [
				parse Folder_Start: Query_String [
					some [
						[Time | Date | File | Name end] (
							if Elipsis? [
								push Command 'Elipsis
								]
							push Command Value
							)
						| skip Folder_End:
						]
					end
					]
				any [
					none? Folder_End
					parse copy/part Folder_Start Folder_End [Folder (push Command Value)]
					]
				]
			]
		]
	]
Do_Command: has [Folder File Index] [
	parse Command [
		File_Upload^
		| Random_Page^
		| Edit_Page^
		| Save_Page^
		| Match_Name^
		| Delete_Folder^
		| Search_Pages^
		| set Folder file! set Index string! set File file! (
			parse Index [
				Digits end (Index: to-integer Index)
				]
			RNV_Page Folder File Index
			)
		| set Folder file! set File file! end (
			RNV_Contents Folder File
			CSV_Page Folder File
			View_File Folder File
			File_Upload/Page Folder File
			)
		| set File file! end (
			either #"/" = last File [
				View_Folder Folder: File
				md/deep Wiki_Files/:Folder
				View_Folder Folder
				] [
				Folder: %/
				RNV_Contents Folder File
				CSV_Page Folder File
				View_File Folder File
				File_Upload/Page Folder File
				]
			)
		| View_Page^
		]
	]
Do_Command
Envelope Rebol/script/header/Title compose/deep [
	body [
		div/id "Center_Column" [
			h1 (Rebol/script/header/Title)
			p/class "Initial" [
				"Command: " (mold Command) " is unknown!"
				]
			]
		]
	]

