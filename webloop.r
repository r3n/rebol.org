REBOL [
    Title: "Send Pages Every Hour"
    Date: 20-May-1999
    File: %webloop.r
    Purpose: "Send a set of pages via email every hour."
    library: [
        level: 'beginner 
        platform: none 
        type: none 
        domain: [web email other-net] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

pages: [
    http://www.cnet.com
    http://www.rebol.com/index.html
    http://www.news-wire.com/news/today.html
]

loop 24 [
    foreach page pages [send luke@rebol.com read page]
    wait 1:00
]

