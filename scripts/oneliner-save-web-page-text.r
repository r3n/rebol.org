Rebol [
    Title: "Save web page"
    Date: 20-Jul-2003
    File: %oneliner-save-web-page-text.r
    Purpose: {This line reads a web page, strips all its tags (leaving just the text) and writes it to
a file called page.txt. Note: requires newer releases of REBOL.}
    One-liner-length: 86
    Version: 1.0.0
    Author: "Carl Sassenrath"
    Library: [
        level: 'beginner
        platform: none
        type: [How-to FAQ one-liner]
        domain: [web]
        tested-under: none
        support: none
        license: none
        see-also: none
    ]
]
remove-each tag page: load/markup http://www.rebol.com [tag? tag] write %page.txt page
