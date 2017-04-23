rebol [
    title: "RebelXML"
    date: 25-apr-06
    file: %rebelxml.r
    author: "Christophe 'REBOLtof' Coussement"
    email: "reboltof-at-yahoo-dot-com"
	purpose: {RebelXML provides a set of functions which allows to easily create/modify/delete XML data}    
    usage: {
        -- you will be parsed, any resistance if futile! --
        Use the following functions:
         'clear-xml-data 
         'get-xml-data 
         'set-xml-data
         'show-xml-data 
         'set-xml-quote 
         'load-xml-data
        More explanations are available into the published documentation at:
        http://www.rebol.org/cgi-bin/cgiwrap/rebol/documentation.r?script=rebelxml.r
    }
    history: [          
		1.0.0 [25-apr-05 "History begins" "COU"]
	]
	uses: 'face	
    library: [
        level: 'advanced 
        platform: all 
        type: [tool] 
        domain: 'xml 
        tested-under: [View 1.3.2.3.1 on "Windows XP"] 
        support: "Contact the author" 
        license: 'lgpl 
    ]
]

if any [
    system/version/1 < 1
    system/version/2 < 3
] [
    alert "This tool requests at least REBOL/View 1.3 to run."
    quit
]

rebelxml: context [
    ;--- container for the XML data string
    xml-data: copy ""
    
    ;--- container for the parsing rules -- debugging purpose
    parse-rules: none
    
    ;--- container for the choosen xml quote - simple by default
    quote: "'"
    
    ;--- clear the data container
    clear-data: func [
        "clears existing data into internal cache"
    ] [clear xml-data]
    
    ;--- returns xml-data content
    show-data: func [
        "returns data from internal cache"
    ] [xml-data]
    
    ;--- load xml data 
    load-data: func [
        "load xml data into xml-data word"
        data [string!] "XML data to load"
    ] [
        xml-data: copy data
    ]
    
    ;--- set user quote preference
    set-quote: func [
        "set user quote preference (default is simple)"
        user-quote [word!] "May be 'simple or 'double"
    ] [
        quote: switch user-quote [simple ["'"] double [{"}]]
    ]
    
    ;--- data access functions
    get-data: func [
        "extract requested data from xml"
        path [path! word!] "the path pointing to the data" 
        /content "if content value is requested"
        /attribute "if attribute value is requested" 
        att-name [word!] "name of the attribute"
        /with-attribute "qualify a content" 
        w-att-name [word!] "name of the attribute"
        w-att-data [string!] "value of the attribute"
        /local rules result txt last-path
    ] [
        ;--- check right use of the rafinements
        if all [content attribute] [return false]
        if all [attribute with-attribute] [return false]
        
        ;--- convert access path if needed
        if word? path [path: to-path path]
        
        ;--- set access to content as default
        if not any [content attribute][content: true]
        
        ;--- set containers
        rules: copy/deep [any [] to end]
        result: none
        txt: copy ""
        
        ;--- get trace of last path element
        last-path: last path
        
        ;--- create initial path
        while [not empty? form path] [
            append rules/any compose/deep [thru (rejoin ["<" (first path)])]
            path: next path
        ]
        
        if content [
            if with-attribute [
                append rules/any compose [
                    thru (rejoin [form w-att-name "='" w-att-data "'"]) | 
                    thru (rejoin [form w-att-name {="} w-att-data {"}])
                ]
            ] 
            append rules/any compose/deep [
                [thru ">" copy txt to (form to-end-tag last-path) | thru "/>"]
            ]
        ]
        
        if attribute [
            append rules/any compose/deep [
                [thru (join form att-name "='") | thru (join form att-name {="})] 
                copy txt 
                [to "' " | to "'>" | to {" } | to {">} | to "'/>" | to {"/>"}] 
            ]
        ]
        
        append rules/any [(
                if none? result [result: copy []] 
                append result txt
                if none? result/1 [result: []]
        )]
        
        parse-rules: copy rules
        
        ;--- return 'result (all ok) 'false (parsing error) or 'none (path not found)
        either parse xml-data rules [result][false]        
    ]
    
    set-data: func [
        "set path, content and/or attribute into xml-data"
        path [word! path!] "access path"
        /content "set a content"
            data [string!] "content data"
        /attribute "set an attribute"
            att-name [word!] "attribute name"
            att-value [string!] "attribute data"
        /with-attribute "specify a tag with a given attribute" 
            w-att-name [word!] "name of the attribute"
            w-att-data [string!] "value of the attribute"
        /local rules mark sub-rule
    ] [
        ;--- refinements compatibility checks
        if all [content attribute] [return false]
        if all [attribute with-attribute] [return false]
        if not any [content attribute] [content: true data: copy ""]
        
        ;--- some init
        rules: copy/deep [[] to end]
        mark: none
        
        ;--- dynamically compose parsing rules
        foreach tag path [
            sub-rule: copy []
            append sub-rule reduce [
                'thru to-open-tag tag ;to-paren [?? "in"]
            ] 
            if all [attribute tag = last path][
                append sub-rule [mark:]
                append sub-rule reduce [
                    to-paren compose/deep [insert mark (rejoin [" " form att-name "=" quote att-value quote])]
                ]
                append sub-rule [:mark]
            ]
            if all [with-attribute tag = last path][
                append sub-rule reduce [
                    'thru rejoin [" " w-att-name "=" quote w-att-data quote]
                ]
            ]
            append sub-rule [to ">"]
            append sub-rule [mark: :mark | mark:]
            case [
                all [attribute tag = last path] [
                    append/only sub-rule reduce [
                         to-paren compose/deep [
                             until [mark: next mark any [ #"<" = mark/1 empty? mark]]
                             insert mark [( rejoin [form to-open-tag tag " " form att-name "=" quote att-value quote ">" form to-end-tag tag])]
                             mark: next mark
                         ]  
                    ]
                ] 
                all [not attribute not with-attribute] [
                    append/only sub-rule reduce [
                         to-paren compose/deep [
                             until [mark: next mark any [ #"<" = mark/1 empty? mark]]
                             insert mark [( rejoin [form to-tag tag form to-end-tag tag])]
                             mark: next mark
                         ]  
                    ]
                ]
            ]            
            append sub-rule [:mark]            
            append/only rules/1 sub-rule
        ]
        
        if content [                        
            append/only rules/1 reduce [
                'thru #">" to-set-word 'begin 'to #"<" to-set-word 'ending
            ]
            append/only rules/1 to-paren compose/deep [
                change/part begin (data) ending
            ]
        ]
        
        ;--- uncomment following line to see composed rules
        ;? rules ask "Press to go" ;<<< DEBUG! >>>
        parse/all xml-data rules
        
        xml-data: head xml-data
    ]
    
    ;--- helpers
    to-end-tag: func [
        data [string! word!]
    ] [
        to-tag join "/" data
    ]
    to-open-tag: func [
        data [string! word!]
    ] [
        head insert form data "<"
    ]
    
    ;--- set public functions accessible from outside context
    set 'clear-xml-data :clear-data
    set 'get-xml-data :get-data
    set 'set-xml-data :set-data
    set 'show-xml-data :show-data
    set 'set-xml-quote :set-quote
    set 'load-xml-data :load-data
] 
 
