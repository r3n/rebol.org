REBOL [
    Title: "Time-It Function"
    Date: 3-Jun-1999
    File: %timeit.r
    Purpose: {Creates a simple timer function for timing in REBOL.}
    Comment: {
        The first time-it call notes the time, but does not print.
        After that, each call will print the time that has elapsed since
        the last call.
    }
    library: [
        level: 'intermediate 
        platform: 'all 
        type: 'tool 
        domain: 'x-file 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
    Version: 1.0.0
    Author: "Anonymous"
]

time-it: use [last-time] [
    last-time: none
    func [] [
        if last-time [print now/time - last-time]
        last-time: now/time
        exit
    ]
]

example: [
    time-it
    loop 100000 [123 * 5 / 321]
    time-it
    wait 3
    time-it
    read http://www.rebol.com
    time-it
]

do example

