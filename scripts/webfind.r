REBOL [
    Title: "Search a Web Page"
    Date: 20-May-1999
    File: %webfind.r
    Purpose: {
        Search a web page for a string, and save the page
        to a file if it was found
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

page: read http://www.rebol.com
if find page "jobs" [write %result.html page]
