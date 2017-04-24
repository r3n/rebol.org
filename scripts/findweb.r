REBOL [
    Title: "Search Web Pages"
    Date: 18-Dec-1997
    File: %findweb.r
    Purpose: {
        Simple example of searching multiple web pages for
        a specified string.
    }
    library: [
        level: 'intermediate 
        platform: none 
        type: none 
        domain: [web file-handling other-net] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

string: "REBOL" ;string to look for

sites: [
    http://www.rebol.com
    http://www.sassenrath.com
    http://www.amiga.org
    http://www.cnn.com
]

print ["Web sites containing the word:" string]

foreach site sites [
    if find (read site) string [
        print [string "found on" site]
    ]
]
