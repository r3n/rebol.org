REBOL [
    Title: "tcp2bc"
    Date: 22-Aug-2001
    Version: 1.0.0
    File: %tcp2broadcast.r
    Author: "ND"
    Purpose: "tcp input forwarded/redirected as udp broadcast"
    Email: none
    library: [
        level: 'intermediate 
        platform: 'all 
        type: 'Tool 
        domain: [tcp other-net] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

idata: open tcp://:1111                 ; tcp listening port
odata: open udp://255.255.255.255:2222      ; udp broadcast port
set-modes odata [ broadcast: true ]         ; enable broadcast on udp

forever [
    tcp: first idata                    
    until [                         ; do until error is true
       wait tcp
       error? try [ insert odata first tcp ]    ; insert tcp into udp
    ]
   close tcp
]                       

                        