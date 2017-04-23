Rebol [
    title: "R3 time scheme"
    file: %prot-time.r
    author: "Pavel"
    Date: 30-Dec-2010
    Purpose: "R3 read time from RFC868 time server"
    Note: "Based on Graham's example datetime scheme for R3"
    Description: {
        create Rebol3 time:// scheme, 
        read time://time.server returns number of UTC seconds from 1-jan-1900,
        read/lines time://time.server returns well formated local time
        }
    ToDo: {- working with state should enable a port use
           - remove ugly /line refinement possibly thru write block actor}

    History: [0.0.1 first version]

    Library: [
        level: 'intermediate
        platform: 'all
        type: 'tool
        domain: [scheme protocol]
        tested-under: "R3 A110" 
        support: none
        license: 'PD 
        see-also: none 
    ]

]

sys/make-scheme [
    name: 'time
    title: "Time Protocol"
    spec: make system/standard/port-spec-net [port-id: 37 ]

    awake: func [event /local port] [
        ; print ["=== Client event:" event/type]
        port: event/port
        switch event/type [
            lookup [
                ; print "DNS lookup"
                open port
            ]
            connect [
                ; print "connected"
                read port
            ]
            read [
                port/locals: to-integer port/data
                ;probe port
                close port
                return true ; quits the awake
            ]
            wrote [read port]
        ]
        false
    ]


    actor: [
        open: func [
            port [port!]
            /local conn
        ] [
            if port/state [return port]
            if none? port/spec/host [http-error "Missing host address"]
            port/state: context [
                state: 'ready
                connection:
                error: none
                awake: :port/awake
                close?: yes
            ]
            port/state/connection: conn: make port! [
                scheme: 'tcp
                host: port/spec/host
                port-id: port/spec/port-id
                ref: rejoin [tcp:// host ":" port-id]
            ]
            conn/awake: :awake
            open conn
            conn
        ]

        open?: func [port [port!]][
            all [ port/state ]
        ]

        close: func [ port [port!]] [
            if open? port [ close port ]
        ]

        read: func [
            port [port!]
            /lines
            /locals stamp days seconds
        ] [
            either any-function? :port/awake [

                unless open? port [ wait open port]

            stamp: port/state/connection/locals
            days: round/down stamp / 86400
            seconds: stamp // 86400
                either lines [1-Jan-1900 + days + to-time seconds + now/zone ][stamp]
            ] [
                ; do something synchronous here
            ]
        ]
    ]
]
