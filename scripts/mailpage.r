REBOL [
    Title: "Email a Web Page"
    Date: 10-Sep-1999
    File: %mailpage.r
    Purpose: "Send a web page. (simple)"
    library: [
        level: 'beginner 
        platform: none 
        type: 'one-liner
        domain: [web email other-net] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

send luke@rebol.com read http://www.rebol.com/releases.html
