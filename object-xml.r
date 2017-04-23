rebol [
	title: {object to xml converter}
	file: %object-xml.r
	date: 15-sep-2010
	version: 1.1.0
	author: {James Nakakihara}
	email: james@rebsoft.com
	purpose: {Takes the output and/or object format from xml-object.r by Brian Wisti and Gavin F. McKenzie and formats it back into xml. See also xml-parse by the same authors to provide the input from an xml file to xml-object.r. }
	Acknowledgements: {Brian and Gavin for creating those tools and from the Rebol3 Altme World: Maxim, Oldes, Graham, Gregg, and Izkata. Without whom, I'd still be stuck.
	}
	Usage: {out: object-xml obj 
		- where 'out' is a string to hold output and 'obj' is your xml object(s) from xml-object.r
		See also comment at end of this document.
		}
	]
        library: [
	        level: 'intermediate
	        platform: 'all
	        type: 'module
	        domain: [markup web xml]
	        tested-under: {View 2.7.7.3.1}
	        license: {BSD}
	        see-also: "xml-parse.r,xml-object.r"
	]

	history: [
		1.1.0 [16-Oct-2010 "First public release."]	
	]
	caveats: {
		Only tested with some relatively simple scripts. 
		Relies on output of xml-objects and/or this format to work.
		Namespaces apparently not supported in above so, no workee - hint: check the objects for unusual translations
		
	}

context [
	tabs: copy ""
	set 'test func [ {my test function. usage example: test [probe o]} d  /local dotest][
		dotest: false ;true	
		if dotest [do d]
	]
	
	set 'discover func [{Looks into the object given and converts to xml} 
	o [OBJECT!] {The xml object}
	out {string to hold}
	/init {initialize tabs}
	/local i newo s a attributes
	][
	
		append tabs #"^-"
		if init [
			tabs: copy ""	
		]
		foreach i next first o [ ;go through the contents of this object
			either all [not object? o/:i not block? o/:i] [ ;specialized ofr xml-object.r which uses value?: val
				if i == 'value? [ 
					repend out [join "" [ o/:i ] ]
				]
			][	;we have an object or block - 
				either block? o/:i [ ;deal with objects held in blocks with no name
					foreach newo o/:i [
						do compose/deep [newo: make object! [(to-set-word i) newo]]
						discover newo out 	
					]
				][	;we have a non-block object
					;handle first tag with possible attributes
					clear attributes: []
					foreach a next first o/:i [ ;go through and check for non object/block/value?
						if all [not object? o/:i/:a not block? o/:i/:a not equal? 'value? a ] [ 
							append attributes join " " [a {="} o/:i/:a {"}]
						]
					]
					repend out [join {^/} [tabs {<} i either not empty? attributes [attributes ][{}]  {>}] ]
					;process object
					discover o/:i out
					;end tag
					s: copy ""
					if not found? find first o/:i 'value? [s: copy join "^/" tabs]
					repend out [ join s [ {</} i  {>} ]] 
				] ;was an object
			] ;end of object/block check
		];end of loop
		remove tabs
	]
	
	set 'object-xml func [{Takes the objects created by xml-object.r and creates and xml file in 'out'. This calls discover which actually does all the work.} obj [OBJECT!] {The xml object}
	/local out xobj d w
	][
	
		;first separate the xml portion (xobj) from the <?xml> definition 
		do compose/deep [xobj: make object! [(to-set-word  first w: next first obj) get in obj first w]]
		;now get the definitions and handle them
		out: copy {<?xml }
		foreach d next w [
			if not none? obj/:d [	
				append out join "" [d {="} obj/:d {" }]
			]
		]
		append out {?>} 
	 	discover/init xobj out
		probe out ;can be commented out
		return out	
	] 

];context

comment {
xml: {<?xml version="1.0" encoding="utf-8"?>
        <person>
            <NAME test='text'>Fred</NAME>
            <AGE>24</AGE>
            <ADDRESS>
                <STREET>123 Main Street</STREET>
                <CITY>Ukiah</CITY>
                <STATE>CA</STATE>
            </ADDRESS>
            <nothing></nothing>
            <end/>
        </person>
}
;how to test
;You'll need these
do %xml-parse.r
do %xml-object.r
do %object-xml.r
;OK, run the test
a: parse-xml+ xml ;parses the xml
o: xml-to-object a ;converts to objects
obj: do load o ;makes a 'live' obj to play with 
print "Set up xml, a, o, and obj" ;reminder for me
out: object-xml obj ;here this tool is run
write clipboard:// out ;useful for pasting text into your editor for review.
}
