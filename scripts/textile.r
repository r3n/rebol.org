rebol [
	file: %textile.r
	date: 16-June-2006
	title: "Textile Parser"
	version: 0.2.0
	author: "Brian Wisti"
	email: "brianwisti@yahoo.com"
	purpose: "Transforms Textile-formatted text into HTML"
	library: [
		level: 'intermediate
		platform: 'all
		type: [ tool module ]
		domain: [ text cgi text-processing]
		tested-under: [1.3]
		support: none
		license: 'mit
		see-also: none
	]
	notes: { 
		refer to http://bradchoate.com/mt/docs/mtmanual_textile2.html for the features I plan to implement.
	}
	changes: [
		[ 12-June-2006 0.1.0 "Initial upload. Many things still don't work" ]
		[ 15-June-2006 0.1.1 "Fixed a bug where new unadorned paragraphs were treated with previous paragraph tag" ]
		[ 16-June-2006 0.2.0 "Extended blocks now work!" ]
	]
	usage: {
		do %textile.r
		my-html: textile/process my-textile-string
	}
    	
]

textile: make object! [
    collapse?: false
    
    tags: [
        "p"      "p"
        "h1"     "h1"
        "h2"     "h2"
        "h3"     "h3"
        "h4"     "h4"
        "h5"     "h5"
        "h6"     "h6"
        "bc"     "code"
        "bq"     "blockquote"
        "strong" "strong"
        "em"     "em"
        "code"   "code"
        "span"   "span"
        "li"     "li"
        "ul"     "ul"
        "_LIST_"   "_LIST_"
    ]

    inline-tags: [
        "*"  "strong"
        "_"  "em"
        "@"  "code"
        "--" "small"
        "**" "b"
        "__" "i"
        "++" "big"
        "-"  "del"
        "+"  "ins"
        "%"  "span"
        "~"  "sub"
        "^^" "sup"
    ]

    keys: func [
        my-series
        /local
        key-series
    ] [
        key-series: copy []
        for i 1 (length? my-series) 2 [
            append key-series pick my-series i
        ]
        return key-series
    ]

    tag-keys: keys inline-tags

    digit: charset [ #"0" - #"9" ]
    alphanumeric: charset [ #"0" - #"9" #"A" - #"Z" #"a" - #"z" ]
    whitespace: charset reduce [ tab newline #" " ]    

    process: function [
        "Creates HTML text from Textile-formatted source"
        textile [string!] "The original Textile source"
    ] [
		extended?
		extended-attributes
		extended-chunk
		extended-element
		extended-tag
		html
		in-list?
		line
		paragraph-separator
		chunks
		tag
		content
		formatted-content
		attributes
		style
		class
		style-id
		lang
		element
		delimiter
		valid-attributes
		use-filter?
		style-subrule
		a b c d i
		aa bb cc dd
		aaa bbb
    ] [
    	extended?: false
    	extended-element: copy ""
    	extended-attributes: copy ""
    	extended-tag: copy ""
    	extended-chunk: copy ""
    	in-list?: false
        tag: copy ""
        attributes: copy ""
        style: copy ""
        class: copy ""
        lang: copy ""
        html: copy ""
        style-id: copy ""
        style-subrule: [
            "{" aa: to "}" bb: ( style: copy/part aa bb ) :bb skip |
            "(" aa: to "#" bb: skip cc: to ")" dd: ( 
                class: copy/part aa bb 
                style-id: copy/part cc dd
            ) :dd skip |
            "(" aa: to ")" bb: ( class: copy/part aa bb ) :bb skip |
            "[" aa: to "]" bb: ( lang: copy/part aa bb ) :bb skip |
            "<>" ( append style "text-align: justify;" ) |
            ">" ( append style "text-align: right;" ) |
            "<" ( append style "text-align: left;" ) |
            "=" ( append style "text-align: center;" ) |
            aa: some "(" bb: ( append style rejoin [ "margin-left: " length? copy/part aa bb "em;" ] ) |
            aa: some ")" bb: ( append style rejoin [ "margin-right: " length? copy/part aa bb "em;" ] ) |
            "|rebol|" ( use-filter?: true)
        ]

        rule: [
            some [
                ; Basic block tags.
                opt [ 
                    a: [ "p" | "h1" | "h2" | "h3" | "h4" | "h5" | "h6" | "bc" | "bq" ] b: 
                    ; Style and other attributes
                    any style-subrule
                    c: "."  to " " d: (
                        tag: copy/part a b
                        either (length? copy/part c d) > 1 [
                    		extended?: true
                    		extended-tag: tag
                    		extended-chunk: copy ""
                		] [
                			extended?: false
                			if extended-element <> "" [
								append html make-element [ extended-element extended-chunk extended-attributes ]
							]
							extended?: false
							extended-element: copy ""
							extended-attributes: copy ""
							extended-chunk: copy ""
							extended-tag: copy ""
						]
                    )
                    :d
                    " "
                ]
                
                ; Footnotes
                opt [
                    a: "fn" b: [ some digit ] c: "." d: (
                        element: "p"
                        i: copy/part b c
                        change/part a rejoin [ "^^" i "^^" ] d
                        attributes: parse-attributes rejoin [ "(footnote#fn" i ")" ]
                    )
                    :d
                    " "
                ]
                
                ; Lists
                opt [
                	a: some [ "*" | "#" ] " " b: (
                		; Make a list
                		list-components: copy/part a b
                		in-list?: true
                		tag: "_LIST_"
            		)
            		:b
            		
        		]

                ; Apply filters before going further
                aa: to "^/^/" bb: (
                    content: copy/part aa bb
                    if use-filter? [ change/part aa reduce [ do content ] bb ]
                ) :aa

                aa: to "^/^/" bb: (
                    content: copy/part aa bb

                    formatted-content: inline-format content

                    element: select tags tag
                    unless element [ element: "p" ]

                    ; Can I push this outside to the parse rule?
					if any [element = "code" extended-element = "code" ] [
							replace/all content "<" "&lt;"
							replace/all content ">" "&gt;"
					]
                    switch element [
                        "blockquote" [
                            content: make-element [ "p" content ]
                        ]
                        "p" [
                            either collapse? [
                                replace/all content "^/" " "
                            ] [
                                replace/all content "^/" make-element [ "br" ]
                            ]
                        ]
                        "_LIST_" [
                        	content: rejoin [ list-components content ]
                    		content: make-list content        
                    	]
                        
                    ]
                    if style <> "" [
                        append attributes rejoin [ " style='" style "'" ]
                    ]
                    if class <> "" [
                        append attributes rejoin [ " class='" class "'" ]
                    ]
                    if style-id <> "" [
                        append attributes rejoin [ " id='" style-id "'" ]
                    ]
					if lang <> "" [
						append attributes rejoin [ " lang='" lang "'" ]
					]
					either extended? [
						either tag = extended-tag [
							extended-element: element
							extended-attributes: attributes
							append extended-chunk content
						] [
							append extended-chunk make-element [ element content attributes ]
						]
					] [
						either tag/1 = #"_" [
							append html content
						] [
							append html make-element [ element content attributes ]
						]
					]
                    
                    tag: copy ""
                )
                2 skip
            ]
        ]
        append textile "^/^/"
        parse/all textile rule
        
        return html
    ]
    
    parse-attributes: function [
        text
    ] [
        align
        margin
        margin-index
        style
        style-info
        style-class-declaration
        style-id
        lang-id
        lang
        class
        aa bb cc dd 
    ] [
        style: copy ""
        lang: copy ""
        class: copy ""
        style-id: copy ""

        if all [ text text <> "" ][
            style-subrule: [
                "{" aa: to "}" bb: ( style: copy/part aa bb ) :bb skip |
                "(" aa: to "#" bb: skip cc: to ")" dd: ( 
                    class: copy/part aa bb 
                    style-id: copy/part cc dd
                ) :dd skip |
                "(" aa: to ")" bb: ( class: copy/part aa bb ) :bb skip |
                "[" aa: to "]" bb: ( lang: copy/part aa bb ) :bb skip |
                "<>" ( append style "text-align: justify;" ) |
                ">" ( append style "text-align: right;" ) |
                "<" ( append style "text-align: left;" ) |
                "=" ( append style "text-align: center;" ) |
                aa: some "(" bb: ( append style rejoin [ "margin-left: " length? copy/part aa bb "em;" ] ) |
                aa: some ")" bb: ( append style rejoin [ "margin-right: " length? copy/part aa bb "em;" ] ) |
                "|rebol|" ( use-filter?: true)
            ]
            parse text [ any style-subrule ]

        ]

        if class <> "" [
            class: rejoin [ " class='" class "'" ]
        ]
        if style-id <> "" [
            style-id: rejoin [ " id='" style-id "'" ]
        ]
        if style <> "" [
            style: rejoin [ " style='" style "'" ]
        ]

        return rejoin [ class style-id style lang ]
    ]

    inline-format: func [
        text
        /local
        tokens
        formatted
        char
        token
        a aa b c d
        tag
        segment
        attributes
    ] [
        attributes: ""

        markers: [
            a: "^^" aa: 
              opt [ copy attributes to ". " 2 skip ]
            b: to "^^" c: 1 skip d: |
            a: "__" aa: 
              opt [ copy attributes to ". " 2 skip ]
            b: to "__" c: 2 skip d: |
            a: "**" aa: 
              opt [ copy attributes to ". " 2 skip ]
            b: to "**" c: 2 skip d: |
            a: "--" aa: 
              opt [ copy attributes to ". " 2 skip ]
            b: to "--" c: 2 skip d: |
            a: "++" aa: 
              opt [ copy attributes to ". " 2 skip ]
            b: to "++" c: 2 skip d: |
            a: "--" aa: 
              opt [ copy attributes to ". " 2 skip ]
            b: to "--" c: 2 skip d: |
            a: "~"  aa: 
              opt [ copy attributes to ". " 2 skip ]
            b: to "~"  c: 1 skip d: |
            a: "%"  aa: 
              opt [ copy attributes to ". " 2 skip ]
            b: to "%"  c: 1 skip d: |
            a: "+"  aa: 
              opt [ copy attributes to ". " 2 skip ]
            b: to "+"  c: 1 skip d: |
            a: "-"  aa: 
              opt [ copy attributes to ". " 2 skip ]
            b: to "-"  c: 1 skip d: |
            a: "@"  aa: 
              opt [ copy attributes to ". " 2 skip ]
            b: to "@"  c: 1 skip d: |
            a: "_"  aa:
               opt [ copy attributes to ". " 2 skip ]
            b: to "_"  c: 1 skip d: |
            a: "*"  aa:
              opt [ copy attributes to ". " 2 skip ]
            b: to "*"  c: 1 skip d:
        ]

        do-transform: func [
            /local
            tag
            formatted-attributes
        ][
            segment: copy/part b c
            tag: select inline-tags copy/part a aa
            
            if (length? segment) > 0 [
            	formatted-attributes: parse-attributes attributes
                segment: inline-format segment
                change/part a make-element [ tag segment formatted-attributes ] d
            ]
        ]

        markup-rule: [
            opt [
                markers :a (do-transform) " " | skip
            ]

            any [
                whitespace
                markers :a (do-transform) " " | skip
            ]
            to end
        ]
        parse/all text markup-rule
        find-footnotes text
        find-images text
        find-special-characters text

        return text
            
    ]

    find-footnotes: func [
        text
        /local
        a b c d index
    ] [
        parse text [
            any alphanumeric
            any [
                [ a: "[" b: to "]" c: skip d: ] :a (
                    index: copy/part b c
                    change/part a make-element [
                    	"sup"
                    	(make-element [ "a" index (rejoin [ "href='#fn" index "'" ]) ])
                    	"class='footnote'"
                	] d
                )
            ] skip
            to end
        ]
    ]

    find-images: func [
        text
        /local
        img
    ][
        alt: copy ""
        dimensions: copy ""

        parse/all text [
            any [
                [ a: "!" b: to "!" c: skip d: ] :a (
                    img: copy/part b c
                    change/part a generate-img img d
                )
            ] skip
            to end
        ]
    ]

    generate-img: func [
        text
        /local
        img url alt height width img-data filename dimensions style attributes
        a b c d
    ][
        alt: copy ""
        dimensions: copy ""
        style: copy ""
        parse/all text [
            opt [ copy attributes to ". " 2 skip ]
            copy url to " " skip
            opt [ [ a: "(" b: to ")" c: skip d: ] :a (alt: copy/part b c) ]
            opt [ copy width to "x" skip copy height to end ]
        ]

        unless url [ url: text ]
        filename: to-file url
        if exists? filename [
            unless all [ width height ] [
                img-data: load-image filename
                width: img-data/size/x
                height: img-data/size/y
            ]
        ]
        
        if attributes [
            style: parse-attributes attributes
        ]

        if all [ width height ] [
            dimensions: rejoin [
                " width='" width "' height='" height "'"
            ]
        ]

        return make-element [
        	"img"
        	None
        	(rejoin [ "src='" url "' alt='" alt "'" dimensions style ])
    	]
    ]
    
    make-list: func [
    	chunk
    	/local
    	list-content
    	list-item
    	lines
    	line
	] [
    	list-content: copy ""
    	list-item: copy ""
    	list-items: []

    	list-marker: chunk/1
    	element: switch list-marker [
    		#"*" [ "ul" ]
    		#"#" [ "ol" ]
		]

    	lines: parse/all chunk "^/"
    	foreach line lines [
    		either line/1 == list-marker [
    			parse/all line [
    				a: [ #"*" | #"#" ] b:
    				" " c:
    				to end d: (
    					markers: copy/part a b
    					text: copy/part c d
					)
				]
    			line: text
    			if list-item <> "" [
    				count: length? markers
    				while [count > 1] [
	        			list-item: make-element [ "ul" (make-element [ "li" list-item ]) ]
	        			count: count - 1
        			]
        			append list-content make-element [ "li" list-item ]
    			]
    			list-item: copy ""
			] [
				either collapse? = true [
    				append list-item " "
				] [
					append list-item make-element [ "br" ]
				]
			]
    		append list-item line
    	]
    	if list-item <> "" [
    		append list-content make-element [ "li" list-item ]
		]
		return make-element [ element list-content ]
	]

    find-special-characters: func [
        text
		/local
		basic-characters
		entity
		a b c d
    ] [
		; This is the tail-end of the parsing process, done once everything else has been sorted out.
		basic-characters: [
			"c" "copy"
			"r" "reg"
			"tm" "trade"
		]

        parse/all text [
            any [
                [ a: "(" b: to ")" c: skip d: ] :a (
                    entity: select basic-characters copy/part b c
					if entity [
						change/part a rejoin [ "&" entity ";" ] d
					]
                )
            ] skip
            to end
		]
    ]
    
    make-element: func [
    	components
    	/local
    	tag
    	content
    	attributes
	] [
		components: reduce components
		length: length? components
		if length >= 1 [
			tag: components/1
		]
		if all [ length >= 2 components/2 <> None ] [
			content: components/2
		]
		either all [ length >= 3 components/3 <> "" ][
			attributes: components/3
			if attributes/1 <> #" " [
				attributes: rejoin [ " " attributes ]
			]
		] [
			attributes: copy ""
		]
		
		either content [
			return rejoin [ "<" tag attributes ">" content "</" tag ">" ]
		] [
			return rejoin [ "<" tag attributes " />" ]
		]
	]
]

