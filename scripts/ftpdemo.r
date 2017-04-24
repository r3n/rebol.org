REBOL [
    Title: "Test FTP Commands"
    Date: 24-Jun-2001
    Version: 0.1.1
    File: %ftpdemo.r
    Author: "Larry Palmiter"
    Purpose: "Demonstrate ftp commands and results"
    Email: larry@ecotope.com
    library: [
        level: 'beginner 
        platform: none 
        type: 'Demo 
        domain: [ftp other-net] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

cmd-echo: func [cmd [block!]][
    print ["^/>>" form cmd]
    print ["==" mold do cmd]
]

print "^/Sample ftp commands and results:"

cmd-echo [dir? ftp://ftp.rebol.com/]
cmd-echo [read ftp://ftp.rebol.com/]
cmd-echo [read ftp://ftp.rebol.com/pub/]
cmd-echo [exists? ftp://ftp.rebol.com/test.txt]
cmd-echo [size? ftp://ftp.rebol.com/pub/downloads/rebol011.lha]
cmd-echo [modified? ftp://ftp.rebol.com/pub/downloads/rebol011.lha]
cmd-echo [info? ftp://ftp.rebol.com/pub/downloads/]
cmd-echo [info? ftp://ftp.rebol.com/test.txt]
cmd-echo [read ftp://ftp.rebol.com/test.txt]
cmd-echo [read/binary ftp://ftp.rebol.com/test.txt]

halt
                                                           