Rebol [
    Title: "Print HTML source"
    Date: 20-Jul-2003
    File: %oneliner-print-web-page.r
    Purpose: {Prints to the console the HTML source for a web page.}
    One-liner-length: 31
    Version: 1.0.0
    Author: "RT"
    Library: [
        level: 'beginner
        platform: 'all
        type: [How-to FAQ one-liner]
        domain: [web html]
        tested-under: none
        support: none
        license: none
        see-also: none
    ]
]
print read http://www.rebol.com
