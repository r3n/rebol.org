REBOL [
    Title: "Web HTML Tag Extractor"
    Date: 20-May-1999
    File: %websplit.r
    Purpose: {Separate the HTML tags from the body text of a document.}
    library: [
        level: 'intermediate 
        platform: 'all 
        type: [Demo Tool] 
        domain: [web other-net text-processing] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
    Version: 1.0.0
    Author: "Anonymous"
]

tags: make block! 100
text: make string! 8000
html-code: [
    copy tag ["<" thru ">"] (append tags tag) | 
    copy txt to "<" (append text txt)
]
page: read http://www.rebol.com
parse page [to "<" some html-code]
foreach tag tags [print tag]
print text
