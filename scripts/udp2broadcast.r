REBOL [
    Title: "udp2bc"
    Date: 21-Aug-2001
    Version: 1.0.1
    File: %udp2broadcast.r
    Author: "ND"
    Purpose: "udp input forwarded/redirected as broadcast"
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

idata: open udp://:1111                 ; adjust for listening
odata: open udp://255.255.255.255:2222      ; adjust for broadcasting

;; io buffersize is set to 4 MB adjust for your needs
set-modes odata [ broadcast: true send-buffer-size: receive-buffer-size: 2048 * 2048  ]

forever [
    gotya: wait idata                   ; wait
    pushit: copy gotya              ; store
    error? try [ insert odata pushit ]      ; and forced forward
]

                       