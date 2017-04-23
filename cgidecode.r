REBOL [
    Title: "CGI Query String Decoder"
    Date: 21-May-1999
    File: %cgidecode.r
    Purpose: {
        Parses a CGI query into a list of words and values.
    }
    Notes: {
        A CGI query is a list of equates in the form: word=value&
        The value may contain hex escape characters (%XX), and 
        they will be decoded by this function.
    }
    library: [
        level: 'intermediate 
        platform: none 
        type: none 
        domain: [cgi other-net] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]


decode-cgi-query: func [
    "Convert CGI argument string to a list of words and value strings"
    args [any-string!] "Starts at first argument word"
    /local list equate value name val
][
    list: make block! 8
    equate: [copy name to "=" "=" (append list to-set-word name) value]
    value: ["&" (append list none) | [copy val to "&" "&" | copy val to end]
         (append list to-string load insert val "%")]
    parse/all args [some equate | none]
    list
]

Examples: [
    probe decode-cgi-query "fred=test&said=123&check=&file=test%20this"
    do decode-cgi-query "fred=test&said=123&check=&file=test%20this"
    print [fred said check file]
]

do Examples