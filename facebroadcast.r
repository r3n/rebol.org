REBOL [
    Title: "Broadcast "
    Date: 1-Oct-2001
    Version: 1.0.0
    File: %facebroadcast.r
    Author: "ND"
    Purpose: "UDP broadcast example"
    Email: none
   library: [
        level: 'beginner
        platform: 'all 
        type: 'Tool 
        domain: [tcp other-net] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
 
]

data: "1101001011110000"
; port 54000 binary notation as text to bc

forever [

    connection: open udp://255.255.255.255:54000
    set-modes connection [ broadcast: true ]

    insert connection data
    print [ now/date "*" now/time ]
    close connection
    wait 0:15:0 ; wait 15 minutes for next broadcast
]

