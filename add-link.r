REBOL [
    Title: "Link Maintainer"
    Date: 15-Sep-1999
    File: %add-link.r
    Purpose: "Cgi for maintaining links to REBOL materials"
    library: [
        level: 'advanced 
        platform: none 
        type: 'Tool 
        domain: 'cgi 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
    Version: 1.0.0
    Author: "Anonymous"
]

print   "Content-type: text/html^/^/"
secure  [file quit net allow %links.dat [allow all]]

linkf: %links.dat
links: either exists? linkf [load linkf][copy []]
 
output: compose [ 
    REBOL Links (now) 
]

emit: func [thing][append output thing]

error: func [it][
    emit reduce [#Error: it]
]

add-link: func [/local page script! groups][
    if found? system/options/cgi/query-string [
        script!: " [script!]"
        do decode-cgi system/options/cgi/query-string
        groups: [
            [
                any [not value? 'newlink not value? 'descrip] 
                exit
            ]
            [
                any [error? try [newlink: to-url newlink] not exists? newlink]
                error [Bad URL]
                exit
            ] 
            [
                find links newlink 
                error [Sorry. I already have that link]
                exit
            ] 
            [
                not find page: read newlink "REBOL" 
                error [ There is no mention of REBOL at the URL you submitted.]
                exit
            ] 
            [
                found? script? page 
                none? find trim/all copy descrip append descrip script!
            ]
        ] 
        foreach group groups [all group] 
        append links reduce [newlink descrip] 
        save linkf links 
    ] 
] 

add-link 
foreach [link description] links [ 
    emit reduce [ 
        build-tag [A HREF (link)] description newline 
    ]
] 

print [ 
    append output compose [ 
        (build-tag [ 
            FORM ACTION (second split-path system/options/script) METHOD "GET" 
        ]) 
        Add a link to a REBOL site: 
        URL:  
        Description:  
 
        The delay after submission is a result of the URL being confirmed. 
    ]
]
