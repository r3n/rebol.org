REBOL [
    Title: "Keep an ISP Connection Alive"
    Date: 16-Sep-1999
    File: %keep-alive.r
    Author: "Jim Goodnow II"
    Purpose: {
        This script can be used to keep an ISP connection alive by
        accessing the net every so often.
    }
    Note: {
        You can change the URL that is accessed to whatever
        you want. You can also change the timeout value.
    }
    library: [
        level: 'beginner 
        platform: none 
        type: [tool tutorial] 
        domain: [web other-net] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

secure none     ; don't want to interrupt everytime

forever [                       
    read http://www.yahoo.com   ; read the Yahoo! page
    wait 0:5:0                  ; wait 5 minutes
]

