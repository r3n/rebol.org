REBOL [
    Title: "Update from WWW.REBOL.COM"
    Date: 12-Oct-1998
    File: %update.r
    Purpose: {Updates your rebol.r and reboldoc.r files from the web.}
    library: [
        level: 'beginner 
        platform: 'all 
        type: 'Tool 
        domain: [web other-net] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
    Version: 1.0.0
    Author: "Anonymous"
]

site: http://www.rebol.com/

updates: [%rebol.r %reboldoc.r %experts.html]

foreach file updates [
    print ["Reading:" site/:file]
    write file read site/:file
] 