REBOL [
    Title: "Search Multiple Web Pages"
    Date: 20-May-1999
    File: %webfinder.r
    Purpose: {
        Search multiple web pages for a string, and print
        the URL of the ones where it was found.
    }
    library: [
        level: 'beginner 
        platform: none 
        type: none 
        domain: [web file-handling other-net] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

sites: [
    http://www.rebol.com
    http://www.cnet.com
    http://www.wsj.com
    http://www.etrade.com
]

foreach url sites [
    if find read url "REBOL" [print url]
]
