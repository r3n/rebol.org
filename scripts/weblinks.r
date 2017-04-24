REBOL [
    Title: "Web Page Link Displayer"
    Date: 20-May-1999
    File: %weblinks.r
    Purpose: "Display all of the web links found on a page."
    library: [
        level: 'intermediate 
        platform: 'all 
        type: none 
        domain: [web other-net text-processing parse] 
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
foreach tag tags [
    if parse tag ["<A" thru "HREF="
        [{"} copy link to {"} | copy link to ">"]
        to end
    ][print link]
]
