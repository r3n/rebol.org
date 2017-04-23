REBOL [
    Title: "Demo client with telnet-protocol"
    Date: 6-Jul-2001
    Version: 1.0.0
    File: %telnet-client.r
    Author: "Frank Sievertsen"
    Purpose: "A simple telnet-client"
    Email: fsievert@uos.de
    library: [
        level: 'intermediate 
        platform: none 
        type: 'tutorial 
        domain: [tcp other-net] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

do http://www.reboltech.com/library/scripts/telnet.r

host: ask "Hostname:"

telnet: open join telnet:// host

system/console/break: no

forever [
    port: wait [telnet/sub-port system/ports/input]
    either port = telnet/sub-port [
        if none? str: copy telnet [break]
        insert system/ports/output str
    ] [
        insert telnet copy/part system/ports/input 1
    ]
]
                            