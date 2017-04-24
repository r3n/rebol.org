Rebol [
    Title: "TCP port scanner"
    Date: 20-Jul-2003
    File: %oneliner-tcp-port-scanner.r
    Purpose: {This is a simple port scanner. Given a TCP address, it will tell you which of the
first 100 ports are accessible. The address can be a host name or number. For example, use
"localhost" to scan ports on your own machine. You can scan more ports by increasing the
number (from 100), or you can scan ranges by using a FOR loop rather than REPEAT.}
    One-liner-length: 89
    Version: 1.0.0
    Author: "Anonymous"
    Library: [
        level: 'beginner
        platform: none
        type: [How-to FAQ one-liner]
        domain: [tcp other-net]
        tested-under: none
        support: none
        license: none
        see-also: none
    ]
]
repeat n 100 [if not error? try [close open join tcp://address: n] [print [n "is open"]]]
