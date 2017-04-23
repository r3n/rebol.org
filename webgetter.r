REBOL [
    Title: "Download Multiple Pages"
    Date: 20-May-1999
    File: %webgetter.r
    Purpose: {Fetch several web pages and save them as local files.}
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

site: http://www.rebol.com

files: [
    %index.html
    %company.html
    %support.html
]

foreach file files [write file read site/:file]
