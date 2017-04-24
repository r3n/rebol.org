REBOL [
    Title: "Console udp-broadcast "
    Date: 1-Aug-2002
    Version: 1.0.0
    File: %console-udp.r
    Author: "ND"
    Purpose: {Console IO udp-broadcast instead of echo file!. When rebol echo function! is executed then bcast-on is automaticly closed by rebol, 
scheme: 'file takes over for echo in system/ports/echo. There is no check on udp port, please change to the right port. Use of an 
udp-listen on a remote console/machine can now listen for udp traffic from this console and capture it to file i.e. by use of echo file!
}
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


bcast-on: does [                      
    either port? system/ports/echo [ print "system/ports/echo is already in use!"]
    [ 
        iout: open udp://255.255.255.255:1111
        set-modes iout [ broadcast: true ]
        system/ports/echo: throw-on-error [ iout ]
    ]
]

bcast-off: does [
    if port? system/ports/echo [
        either equal? system/ports/echo/scheme 'udp [
            system/ports/echo: none
        close iout
        ][ print "system/port/echo is not opened by bcast-on" ]
    ]
]


                                  