REBOL [
    Title: "Web Page Displayer"
    Date: 20-May-1999
    File: %webprint.r
    Purpose: "Fetch a web page and display its HTML code."
    library: [
        level: 'beginner 
        platform: 'all 
        type: 'one-liner 
        domain: [web other-net] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
    Version: 1.0.0
    Author: "Anonymous"
]

print read http://www.rebol.com
