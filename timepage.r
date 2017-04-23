REBOL [
    Title: "Time a Web Page"
    Date: 24-Apr-1999
    File: %timepage.r
    Purpose: {
        Time how long it takes to fetch a web page from the net.
        (Just the HTML file, not the images.)
    }
    library: [
        level: 'beginner 
        platform: none 
        type: none 
        domain: [web other-net] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

start: now/time
read http://www.rebol.com
print now/time - start

