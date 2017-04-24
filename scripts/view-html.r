REBOL [
    Title: "View HTML Code"
    Date: 1-Jun-2000
    File: %view-html.r
    Purpose: {Fetch a web page and view its HTML code in a window.}
    library: [
        level: 'beginner 
        platform: none 
        type: 'one-liner 
        domain: 'GUI 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
    Version: 1.0.0
    Author: "Anonymous"
]

view layout [text 800x600 read http://www.rebol.com]

