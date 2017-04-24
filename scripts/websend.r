REBOL [
    Title: "Web Page Emailer"
    Date: 20-May-1999
    File: %websend.r
    Purpose: "Fetch a web page and send it as email."
    library: [
        level: 'beginner 
        platform: 'all 
        type: 'one-liner 
        domain: [web email other-net] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
    Version: 1.0.0
    Author: "Anonymous"
]

send luke@rebol.com read http://www.rebol.com
