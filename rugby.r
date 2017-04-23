REBOL [
    Title: "Asynchronous Request Broker"
    Date: 21-May-2001/16:31:58+2:00
    Version: 1.0.0
    File: %rugby.r
    Author: "Maarten Koopmans"
    Needs: "Command 2.0+ , Core 2.5+ , View 1.1+"
    Purpose: {An asynchronous, high-performance, handler based, server framework and a rebol request broker...}
    Email: m.koopmans2@chello.nl
    library: [
        level: 'advanced 
        platform: none 
        type: 'tool 
        domain: [ldc other-net tcp] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]


; Our high performing server framework
; Used by the request broker rugby
hipe-serv: context [

  ;The list of ports we wait/all for in our main loop
  port-q: make block! copy []
  ;mapping of ports to objects containg additional info
  object-q: make block! copy []
  ;our main server port
  server-port: none
  ;the handler for server [ currently only rugby, you can imagine http etc...]
  my-handler: none

  ;remove a port from our port list 
    port-q-delete: func [ target [port!]]
    [
        remove find port-q target
    ]
  
  ;insert a port in to our port list
    port-q-insert: func [ target [port!]]
    [
        append port-q target
    ;append port-q make object! conn-object [ port: :target ]
    ]

  ;insert a port and its corresponding object
  object-q-insert: func [ target  /local o]
  [
    append object-q target
    o: make object!  [port: target handler: :my-handler user-data: none]
    append object-q o
  ]
  
  ;remove a port and its corresponding object
  object-q-delete: func [target [port!] ]
  [
    remove remove find object-q target
  ]

  ;initialize everything for a client connection on application level
  start: func [ conn [port!]]
    [
        port-q-insert conn
    object-q-insert conn
    ]

  ;clean up after a client connection
    stop: func [ conn [port!] /local conn-object]
    [
         port-q-delete conn
     error? try 
     [
      conn-object: select object-q conn
          close conn-object/port
      object-q-delete conn
    ]
    ]

  ;intialize everything on network level (asynchronous)
    init-conn-port: func [ conn [port!] ]
    [
        set-modes conn [ async-modes: [read write]]
        start conn 
    ]

  ;initialize our main server port
    init-server-port: func [ p [port!] conn-handler [any-function!]]
    [

        server-port: p

    append port-q server-port
    
        ;Increase the backlog for this server. 15 should be possible (default is 5)
        ;server-port/backlog: 15
        
    my-handler: :conn-handler
    
        open/direct server-port
    ]

  ;Process all ports that have received an event (called from our main loop, serve)
  process-ports: func [ portz [block!] /local temp-obj]
  [
    foreach item portz
    [
      either (item = server-port)
      [
        init-conn-port first server-port
      ]
      [
        temp-obj: select object-q item
        temp-obj/handler temp-obj
      ]
    ]

  ]
  
  ;Start serving. Do a blocking wait until there are events
    serve: func [/local portz]
    [
        forever
        [
      portz: wait/all port-q
      process-ports portz
        ]
    ]

]


;This object implements the server side of a request broker.
rugby-server: make hipe-serv    [

  ;get the number of args of a function
    nargs: func [
        {The number of the function arguments}
        f [any-function!]
    ] [
        -1 + index? any [find first :f refinement! tail first :f]
    ]

  ;fill a string with zeros (used for message lengths etc.)
    fill-0: func [ filly [string!] how-many [integer!] /local fills]
    [
        if how-many > length? filly
        [
            fills: how-many - length? filly
        ]
        for filz 1 fills 1
        [
            insert filly "0"
        ]
        return filly
    ]

  ;This varaiable is a block containg words that are allowed to be executed
    exec-env: none

  ;Checks to see if a message's integrity is ok.
    check-msg: func [ msg [any-block!]]
    [
        return ((checksum/secure mold second msg) = first msg)
    ]

  ;Create a message for on the wire transfer
    compose-msg: func [msg [any-block!] /local f-msg chk ]
    [
        f-msg: copy []
    ;compute the checksum
        chk: checksum/secure mold msg    
        insert/only f-msg copy msg
        insert f-msg chk
    ;return the compressed message
        return mold compress mold copy f-msg
    ]

  ;Extract a message that has been sent on the wire
    decompose-msg: func [ msg [any-string!]]
    [
        return copy do decompress do msg
    ]

  ;Do a low-level write of a message
    write-msg: func [msg [any-block!] dest [port!] /local length f-msg]
    [
        f-msg: compose-msg msg
        length: fill-0 to-string length? f-msg 4
        write-io dest length 4
        write-io dest f-msg length? f-msg
    ]

  ;Execute a message. Only if the first word is in our exec-env varaiable
    safe-exec: func [ statement [any-block!] env [any-block!] /local res n stm]
    [
        if found? (find env first statement)
        [

                n: nargs get to-get-word first statement
                res: none

                stm: copy/part statement (n + 1)
                error? try [ res: do stm ]
            return res
        ]
        return copy {}
    ]

  ;High-level 'do' of a message
    do-message: func [ msg [any-string!] /local f-msg res]
    [
        f-msg: decompose-msg msg
        either check-msg f-msg
        [
            res: safe-exec second f-msg exec-env
            return res
        ]
        [
            return none
        ]
    ]

  ;This is the rugby server-handler (my-handler in hipe-serv)
    do-handler: func [ o /local msg ret size]
    [   
    ;this handler does its work in 3 parts
    ; 1) Read the message size
    ; 2) Read the message
    ; 3) do the message
    ; 1) and 2) may be done inmultiple steps because of the saync I/O
    
    ret: copy []
      if (none? o/user-data  )
      [ error? try
        [
          ;read the first 4 bytes that contain the total message size
        ;message size =< 9999
        size: copy {}
          read-io o/port size 4
          o/user-data: context [ task: copy {} rest: to-integer size]
          unset 'size
        ]
        return
      ]

    ;now try to read the rest of the message
      either (error? try [ msg: copy {} read-io o/port msg to-integer 
o/user-data/rest ])

      [ return]

    ;Do what ever we asked
      [
        o/user-data/rest: o/user-data/rest - (length? msg)
        either (o/user-data/rest = 0)
        [
                o/user-data/task: append o/user-data/task msg
                append ret do-message o/user-data/task
                write-msg ret o/port
                stop o/port
                return
        ]
        [
          o/user-data/task:  append o/user-data/task msg
          return
        ]
      ]
    ]

  ;Init our server according to our server port-spec and with rugby's do-handler
    init-rugby: func [ port-spec [port!] x-env [any-block!]]
    [
        exec-env: copy x-env
        init-server-port port-spec :do-handler
    ]

  ;Start serving
    go: func []
    [
        serve
    ]


]


;Rugby's client side
rugby-client: context

[

  ;Again... fill with zeroes
    fill-0: func [ filly [string!] how-many [integer!] /local fills]
    [
        if how-many > length? filly
        [
            fills: how-many - length? filly
        ]
        for filz 1 fills 1
        [
            insert filly "0"
        ]
        return filly
    ]

  ;Check for message integrity
    check-msg: func [ msg [any-block!]]
    [
        return ((checksum/secure mold second msg) = first msg)
    ]

  ;Create a message for on the wire transmission
    compose-msg: func [msg [any-block!] /local f-msg chk ]
    [
        f-msg: copy []
        chk: checksum/secure mold msg
        insert/only f-msg copy msg
        insert f-msg chk
        return mold compress mold copy f-msg
    ]
   
  ;Extract a message that has been transmitted on the wire
    decompose-msg: func [ msg [any-string!]]
    [
        return copy do decompress do msg
    ]

  ;Write a message on the port
    write-msg: func [msg [any-block!] dest [port!] /local length f-msg]
    [
        f-msg: compose-msg msg
        length: fill-0 to-string length? f-msg 4
        write-io dest length 4
        write-io dest f-msg length? f-msg
    ]

  ;Do a high-level rexec
    rexec: func [ msg [any-block!] /with p [port!] /local res dest]
    [
        either with
        [
            dest: p
        ]
        [
            ;the default
            dest: make port! tcp://localhost:8001
        ]

        if error? e: try
            [
                open dest
                write-msg msg dest
                ;Read the result. We throw the length (first 4 bytes away)
                ;because we just read everything (synchronously)
                res: remove/part copy dest 4
                close dest
                res: decompose-msg res
                either check-msg res
                [
                    return copy second res
                ]
                [
                    return none
                ]
                return copy res

            ];try
        [
            return none
        ];if error? try
    ]


];context

;Client test function. Shows how easy it is to do a remote exec
client-test: does [ rugby-client/rexec [echo "Rugby is great!"] ]

;Sample echo function for the test-server
echo: func [a] [return enbase a]


;A server test function. Demonstrates how easy it is to use rugby-server.
server-test: does
[
    rugby-server/init-rugby make port! tcp://:8001 [echo]
    rugby-server/go
]

















