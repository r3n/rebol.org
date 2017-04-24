REBOL [
    Title: "Input via CGI"
    Date: 20-Jul-1999
    File: %input-cgi.r
    Author: "Mike Yaunish"
    Purpose: "Get CGI input with either POST or GET"
    Email: mike.yaunish@home.com
    Note: {If CGI input exceeds 15,000 bytes, increase the size of stdin}
    library: [
        level: 'intermediate 
        platform: none 
        type: 'tool 
        domain: 'cgi 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

input-cgi: func [/stdin] [
    stdin: make string! 15000
    either system/options/cgi/request-method = "POST" [
        read-io system/ports/input stdin 15000
        return stdin
    ][
        system/options/cgi/query-string
    ]
]
