REBOL [
    Title: "Web Page Title Extractor"
    Date: 20-May-1999
    File: %webtitle.r
    Purpose: "Find the title of a web page and display it."
    library: [
        level: 'beginner 
        platform: 'all 
        type: [Tool one-liner] 
        domain: [web other-net text-processing parse] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
    Version: 1.0.0
    Author: "Anonymous"
]

page: read http://www.rebol.com
parse page [thru <title> copy title to </title>]
print title
