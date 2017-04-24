Rebol [
    Title: "web page links"
    Date: 20-Jul-2003
    File: %oneliner-print-links.r
    Purpose: {Load a web page, parse it to extract and print all links found}
    One-liner-length: 91
    Version: 1.0.0
    Author: "Christophe Coussement"
    Library: [
        level: 'beginner
        platform: none
        type: [How-to FAQ one-liner]
        domain: [web file-handling]
        tested-under: none
        support: none
        license: none
        see-also: none
    ]
]
parse read http://www.rebol.com [any [thru "A HREF=" copy link to ">" (print link)] to end]
