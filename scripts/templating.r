rebol [

	Title: {Templating}
	File: %templating.r
	Date: 08-Nov-2009
	Purpose: {
		Use a template (a master html document) to maintain 
		child document(s) that hold individual editable content(s).
		Editable content are delimited by the following two tags:
		<!-- b_editable name="title1" -->
		<!-- e_editable name="title1" -->
	}
	Usage: {
		>> do %Templating.r
		>> ot: Templating/contructor %master.htm [%child1.html %child2.htm]
		>> ot/sync ; Sync master change into the childs
		note: if a child file doesn't exists then it will be created 
			(that is, childs are at first plain master copy)
	}	
	History: [
		08-Nov-2009 {Make parse rules stronger}
		18-May-2009	{Initial}
	]
	Author: {Cedric G.}
]

Templating: context [
	
	spacers: charset {^A^B^C^D^E^F^G^H^-^/^K^L^M^N^O^P^Q^R^S^T^U^V^W^X^Y^Z^[^\^]^!^_ ^~ }
	
	begin-etag-name: {b_editable}
	end-etag-name: {e_editable}
	
	write-child: "Yes" ; Try "All" or "None" to bypass user input
	
	childs: copy []
	master: copy {}
	
	constructor: func [ 
		master' [file!]
		childs' [block!]  
	][
		return make self [ 
			master: master'
			childs: childs'			
		]
    ]    

	sync: has [f-cindata f-coutdata child d child-changed? msg-out begin ending ask-it?] [
		{ (Re)generate child file(s) from a master template keeping child(s) editable content(s) }
		{ How: For each child files 
			If some editable contents delimiters, holded in the master document, 
			have their correspond in the child then 
				Insert into the master (a copy of the master) editable content(s) 
				the correspondant child editable content(s) value.
				Save that modified master copy as a child (overwrite or create) }
		msg-out: copy {}
		foreach child childs [
			child-changed?: false
			f-cindata: either exists? child [read child][child-changed?: true copy {}]
			f-coutdata: read master
			d: none			
			parse/all f-coutdata [ 
				some [ 
					{<!--} any spacers begin-etag-name some spacers {name="} 
						copy editable_name to 
					{"} skip any spacers {-->}
					begin: 					
					some [
						ending: 
						{<!--} any spacers end-etag-name some spacers {name="} 
							editable_name {"} any spacers 
						{-->}  
							(
								if d: read-editable f-cindata editable_name [
									change/part begin d ending	
									child-changed?: true						
								]
							)	
							break 
						|
						skip
					]					
					| 
					skip
				]				 
			]
			if child-changed? [ 				
				ask-it?: not find ["a" "All" "o" "None"] write-child
				while [ask-it?] [	
					ask-it?: error? try [ 
						write-child: first find ["a" "All" "o" "None" "y" "Yes" "n" "No"] ask rejoin [
							"Write '" child "' [All|None|Yes|No] ? "]]
				]
				either find ["a" "All" "y" "Yes"] write-child [	
					if not exists? child [ write child {} ]
					either not (checksum read child) = (checksum f-coutdata) [
						write child f-coutdata
						append msg-out rejoin [tab {'} child {', } newline]
					] [
						append msg-out rejoin [tab {'} child {' (skip unchanged), } newline] 
					]
				][
					append msg-out rejoin [tab {'} child { (skipped by user input)', } newline]
				]													
			]
		]
		if 0 < (length? msg-out) [
			print rejoin [{Synchronized file(s): } newline head clear back back tail msg-out]
		]
	]
	
	read-editable: func [
		{ read editable content from 'f-cdata' named by 'editable-name' }
		f-cdata
		editable-name 
		/local editable_content begin ending
	] [
		editable_content: none
		parse/all f-cdata [ 
			some [ 
				{<!--} any spacers begin-etag-name some spacers {name="} 
					editable-name 
				{"} any spacers {-->}
				begin:				
				some [ 
					ending: 
					{<!--} any spacers end-etag-name some spacers {name="} 
						editable-name {"} any spacers 
					{-->} 
						(
							editable_content: copy/part begin ending
						)
						break
					|
					skip					
				]				
				| 
				skip
			] 
		]		
		return editable_content	
	]
]

