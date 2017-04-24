REBOL [
    Title: "Download Web Page"
    Date: 20-May-1999
    File: %webget.r
    Purpose: "Fetch a web page and save it as a file."
    library: [
        level: 'beginner 
        platform: none 
        type: 'one-liner
        domain: [web file-handling other-net] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

write %index.html read http://www.rebol.com
