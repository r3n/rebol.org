REBOL [
    Title: "Count References on Web Pages"
    Date: 18-Dec-1997
    File: %countweb.r
    Purpose: {Count the number of times a string appears on each of a given set of web pages.}
    library: [
        level: 'beginner 
        platform: none 
        type: 'FAQ 
        domain: [web http] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
    Version: 1.0.0
    Author: "Anonymous"
]

string: "REBOL" ; string to look for

sites: [
    http://www.rebol.com
    http://www.sassenrath.com
    http://www.amiga.org
    http://www.cnn.com
]

foreach site sites [
    count: 0
    page: read site
    while [page: find/tail page string] [count: count + 1]
    print [count site]
]
