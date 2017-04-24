;; ===========================
;; Script: whoismaker.r
;; Downloaded from: www.REBOL.org
;; On: 9-Jul-2004/4:00:01
;; MODIFIED: 16-Dec-2004 by DH
;; ===========================

REBOL [                                       
    Title: "WHOIS Maker"
    Date: 16-Dec-2004
    File: %whoismaker2.r
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
    Version: 2.0.0
    ;; Re-visiting REBOL after several years,
    ;; I downloaded the one script I wrote and donated to the script library.
    ;; %whoismaker.r - from 30-May-2000
    ;; It seemed to be broken, so I set out to fix it.
    ;; Hence, the new version 2.0.0
    ;; If you find it's still broken,
    ;; or can suggest other improvements,
    ;; please, be my guest to fix up the code.
]


whois-server: [rs.internic.net]


the-query: ""
if not exists? %whois [make-dir %whois]

while [not the-query = "."]
[   query-result-preform: ""
    the-query: ask "  WHOIS-> "
    whois-the-query: make url! rejoin ["whois://" the-query "@" whois-server] 
    print [newline "Searching for: " whois-the-query ]
    query-result-html: read whois-the-query
    parse query-result-html [thru "Domain Name:" copy query-result-preform to "<<<"]
    either find query-result-preform "Last update"
    [   print newline "MATCH FOUND - processed - enter next query...."
        print query-result-preform 
        write/append %whois/masterfile.txt rejoin 
        [   query-result-preform
            newline newline
            "X X X"
            newline newline
        ]
	html-header: rejoin ["<html><head><title>" the-query "</title><head><body>"]
        html-wrapper: rejoin [html-header newline query-result-preform newline "</body></html>"]
        html-file: make file! rejoin ["whois/" the-query ".html"]
        write html-file html-wrapper
    ]
    [   print newline "NO MATCH FOUND - enter next query...."
        print query-result-preform 
    ]
]