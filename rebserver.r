REBOL [
    Title: "Tiny REBOL Server"
    Date: 11-Oct-1999
    File: %rebserver.r
    Purpose: {The distributed REBOL server that builds the REBOL system.}
    Note: {
        This little server can come in very handy if you need
        to coordinate a number of different systems working
        on a common task.  We use it in-house to build REBOL
        for all of our hardware platforms in parallel.  It is
        sent the scripts that need to be executed.  Note that
        this script is for secure intranet use.
    }
    library: [
        level: 'intermediate 
        platform: 'all 
        type: 'tool 
        domain: [tcp other-net] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
    Version: 1.0.0
    Author: "Anonymous"
]

server-port: open/lines tcp://:4321

forever [
    connection-port: first server-port
    until [
        wait connection-port
        error? try [do first connection-port]
    ]
    close connection-port
]