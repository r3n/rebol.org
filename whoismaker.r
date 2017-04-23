REBOL [
    Title: "WHOIS Maker"
    Date: 30-May-2000
    File: %whoismaker.r
    Author: "David Handy"
    Purpose: "WhoIs query, parse, and save as a file"
    library: [
        level: 'intermediate 
        platform: 'all 
        type: 'Tool 
        domain: [other-net broken] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
    Version: 1.0.0
]

whois-server: http://www.networksolutions.com/cgi-bin/whois/whois/whois/
the-query: ""
if not exists? %whois [make-dir %whois]

while [not the-query = "."]
[   the-query: ask "  WHOIS-> "
    whois-the-query: make url! rejoin [whois-server "?" the-query] 
    query-result-html: read whois-the-query
    parse query-result-html [thru <pre> copy query-result-preform to </pre>]

    either find query-result-preform "Your selection is available"
    
    ;true - no match
    [   print newline "NO MATCH FOUND - enter next query...."
        print query-result-preform 
    ]

    ;false - match found
    [   print newline "MATCH FOUND - processed - enter next query...."
        print query-result-preform 

        write/append %whois/masterfile.txt rejoin 
        [   query-result-preform
            newline newline
            "X X X"
            newline newline
        ]

        html-wrapper: rejoin [newline query-result-preform newline]

        html-file: make file! rejoin ["whois/" the-query ".html"]

        write html-file html-wrapper
    ]
]

