REBOL [
    Title: "Web Page Change Detector"
    Date: 20-May-1999
    File: %webcheck.r
    Purpose: {Determine if a web page has changed since it was last checked, and if it has, send the new page via email.}
    library: [
        level: 'intermediate 
        platform: 'all 
        type: 'Tool 
        domain: [web email file-handling other-net] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
    Version: 1.0.0
    Author: "Anonymous"
]

page: read http://www.rebol.com
page-sum: checksum page
if any [
    not exists? %page-sum.r
    page-sum <> (load %page-sum.r)
][
    print ["Page Changed" now]
    save %page-sum.r page-sum
    send luke@rebol.com page
]
