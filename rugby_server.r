REBOL [
    Title: "Rugby client and server"
    Date: 28-May-2001/16:31:58+2:00
    Version: 2.0.0.0
    File: %rugby_server.r
    Author: "Maarten Koopmans"
    Needs: "Command 2.0+ , Core 2.5+ , View 1.1+"
    Purpose: {A high-performance, handler based, server framework and a rebol request broker...}
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
hipe-serv: make object! [

  ;The list of ports we wait/all for in our main loop
  port-q: make block! copy []
  ;mapping of ports to objects containg additional info
  object-q: make block! copy []
  ;our main server port
  server-port: none
  ;the handler for server [ currently only rugby, you can imagine http etc...]
  my-handler: none
  ;restricted server list
  restricted-server: make block! 20
  ;Server restrictions?
  restrict: no

  ;Set our server restrictions
  restrict-to: func [ r [any-block!]]
  [
    restrict: yes
    append restricted-server r
  ]

  ;Is a connection to this ip address allowed?
  allow?: func [ ip [tuple!]]
  [
    return found? find restricted-server ip
  ]

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
      either restrict
      [
        either allow? conn/remote-ip
        [
          start conn
          return
        ]
        [
          close conn
          return
        ]
      ]
      ;no restrictions
      [
        start conn
        return
      ]
    ]

  ;initialize our main server port
    init-server-port: func [ p [port!] conn-handler [any-function!]]
    [

      server-port: p

      append port-q server-port

      ;Increase the backlog for this server. 15 should be possible (default is 5)
      server-port/backlog: 15
      my-handler: :conn-handler
      open/direct/no-wait server-port
    ]

  ;Process all ports that have received an event (called from our main loop, serve)
  process-ports: func [ {Process all ports that have events}
                                                 portz [block!] {The port list}
                                                /local temp-obj]
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
                for filz 1 fills 1
                [
                insert filly "0"
                ]
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
    write-msg: func [msg dest [port!] /local length ]
    [
      ;We try to write ate least 16000 bytes at a time
      either 16000 > (length? msg)
      [
        length: write-io dest msg length? msg

        ;message written, we're done
        either (length = (length? msg))
        [
          return true
        ]
        ;we're not done. Return what we have written
        [
          return length
        ]
      ];either 16000 > first clause
      [
        length: write-io dest msg 16000
      ]

      ;we're done, port is closed
      if 0 > length [return true]

      return length


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
    do-message: func [ msg [any-string!] /local f-msg res size-read]
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
    do-handler: func [ o /local msg ret size size-read]
    [
      ;this handler does its work in 3 parts
      ; 1) Read the message size
      ; 2) Read the message
      ; 3) do the message
      ; 4) Return the result
      ; 1) and 2) and 4) may be done inmultiple steps because of the saync I/O


     ;First, we expect 8 bytes and use user-data initially to store that
     if (none? o/user-data)
     [
       o/user-data:  copy {}
     ];if

     ;If we are not an object we are initialized to a string
     if (not object? o/user-data  )
     [

       error? try
       [
        ;read the first 8 bytes that contain the total message size
        ;message size =< 99.999.999
        size: copy {}

          ;size-read: length? msg: copy o/port
          msg: copy/part o/port (8 - (length? o/user-data))

          size-read: length? msg
          either (size-read = ( 8 - (length? o/user-data)))
          [
            ;What's the total size
            size: copy o/user-data
            append size copy/part msg (8 - (length? o/user-data))
            remove/part msg (8 - (length? o/user-data))

            if (0 < (length? msg)) [ size: (to-integer size) - length? msg ]

            ;And make an object of our user-data
            o/user-data: context [ task: copy msg rest: to-integer size ret-val: copy {} msg-read: false
                                   ret-val-written: false task-completed: false header-written: false
                                   header-length: copy "0"
                                 ];context

          ]
          [
            o/user-data: append o/user-data msg
          ];either
          unset 'size
         ];try
        return
    ];if not object?

    ;Read the actual message
    if (not o/user-data/msg-read)
    [
        ;now try to read the rest of the message
        if (error? try [ msg: copy {} size-read: length? msg: copy/part o/port o/user-data/rest ])
        [ return]

        if 0 = size-read [return]
        o/user-data/task: append o/user-data/task msg
        o/user-data/rest: (o/user-data/rest - size-read)
        if (o/user-data/rest = 0) [ o/user-data/msg-read: true  ]
        return
    ]

    ;do our task and compose our return message
    if not o/user-data/task-completed
    [
          ret: copy []
          append ret do-message o/user-data/task
          o/user-data/ret-val: compose-msg ret
          o/user-data/header-length: fill-0 to-string length? o/user-data/ret-val 8
          o/user-data/task-completed: true
    ]

    ;write out the header (length of what follows)
    if not o/user-data/header-written
    [
        wr-res: write-msg o/user-data/header-length o/port
        either logic? wr-res
        [
          o/user-data/header-written: true
        ]
        [
          remove/part o/user-data/header-length wr-res
        ];either
        return
    ]

    ;write out our return message in batches
    if not o/user-data/ret-val-written
    [
        wr-res: write-msg o/user-data/ret-val o/port
        either logic? wr-res
        [
          o/user-data/ret-val-written: true
          stop o/port
        ]
        [
          remove/part o/user-data/ret-val wr-res
        ];either
        return
    ]
  ];do-handler

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

serve: func [ {Exposes a set of commands as a remote service} commands
              {The commands to expose} [block!]
              /with {Expose on a different port than tcp://:8001} p [port!] {The port spec}
              /restrict {Restrict access to a block of ip numbers} r [block!] {The block of Ip numbers that have access to this service}]
[
  if restrict
  [
    rugby-server/restrict-to r
  ]

  either with
  [
    rugby-server/init-rugby p commands
  ]
  [
    rugby-server/init-rugby make port! tcp://:8001 commands
  ]
  rugby-server/serve
]

echo: func [ e [string!]] [print enbase e return enbase e]


; Type in your console
;serve [echo]


;Rugby's client side
rugby-client: make object!

[
    ;list of ports for deferred requests
    deferred-ports: make block! []

    deferred-index: 0

  ;Again... fill with zeroes
    fill-0: func [ filly [string!] how-many [integer!] /local fills]
    [
        if how-many > length? filly
        [
            fills: how-many - length? filly
                for filz 1 fills 1
                [
                insert filly "0"
                ]
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
        length: fill-0 to-string length? f-msg 8
        write-io dest length 8
        write-io dest f-msg length? f-msg
        write-io dest length 1
    ]

  ;Do a high-level rexec
    rexec: func [ msg [any-block!] /with p [port!] /oneway /deferred
                                    /local res dest]
    [
        either with
        [
            dest: p
        ]
        [
            ;the default
            dest: make port! tcp://localhost:8001
        ]

        if error? try
            [
                open dest
                write-msg msg dest

                                ;Do we require to wait for the result
                                if not any [oneway deferred]
                                [
                    ;Read the result. We throw the length (first 8 bytes away)
                    ;because we just read everything (synchronously)
                                    res: remove/part copy dest 8
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
                                ];if oneway deferred

                                if deferred
                                [
                                    ;Create a holder object
                                    holder: make object!
                                    [
                                        size: copy {}
                                        ret-val: copy {}
                                        port: dest
                  ]
                  deferred-index: deferred-index + 1
                  append deferred-ports deferred-index
                  append deferred-ports holder
                  return deferred-index
                                ]
                                return true;

            ];try
        [
            return none
        ];if error? try
    ]

    wait-for-result: func [ index [integer!] /local res temp-object]
    [

      temp-object: select deferred-ports index

      ;Hmmmm.... we don't exist, return silently. Need to add error throwing here
      if (not object? temp-object)
      [
        return none
      ]

      ;Read the result. We throw the length (first 8 bytes away)
        ;because we just read everything (synchronously)

      res: remove/part copy temp-object/port 8
        close temp-object/port

      ;Remove the port holder and its index
      remove remove find deferred-ports index

        res: decompose-msg res
        either check-msg res
        [
          return copy second res
        ]
        [
          return none
        ]
        return copy res
    ];wait-for-result

    poll-for-result: func [ index [integer!] /local msg ret o size-read size]
    [

      ; 1) Read the message size
      ; 2) Read the message
      ; 3) Return the message
      ; 1) and 2) may be done inmultiple steps because of the async I/O

      o: select deferred-ports index

      ;Hmmmm.... we don't exist, return silently. Need to add error throwing here
      if (not object? o)
      [
        return none
      ]

      if (8 > length? (o/size ))
      [
        error? try
        [
          ;read the first 8 bytes that contain the total message size
          ;message size =< 99.999.999
          size: copy {}

          ;size-read: length? msg: copy o/port
          msg: copy/part o/port (8 - (length? o/size))
          o/size: append o/size msg
        ];try
    ];if not object?

    ;Read the actual message
    if ((length? o/size) = 8)
    [
      ;now try to read the rest of the message
      if (error? try [ msg: copy {} size-read: length? msg: copy/part o/port to-integer o/size ])
      [ return none]

      if 0 = size-read [return false]
      o/ret-val: append o/ret-val msg
      o/size: ((to-integer o/size) - size-read)
      if (o/size = 0)
      [
        ret: decompose-msg o/ret-val
        remove remove find deferred-ports index
        either check-msg ret
        [
           return copy second ret
        ]
        [
          return none
        ]
      ]
    ];if
     return false
   ];poll-result

];context

;Client test function. Shows how easy it is to do a remote exec
client-test: does [ rugby-client/rexec [echo "Rugby is great!"] ]

;A rexec wrapper in the global environment
;Feature suggestion by Allen Kamp
rexec: func [ {A remote exec like facility. Provides complete transparent remote messaging.}
              msg [any-block!]
              /with {Specify another port than the default of localhost:8001.}
              p [port!] {The other port}
              /oneway {Don't wait for a result. Returns true if the message was succefully delivered to the server.}
              /deferred {Check back later for the result and return immediately once the message has been delivered to the service. Returns an ID that can be used when checking if the result has arrived.}
              /local dest]
[
    either with
    [
        dest: p
    ]
    [
        dest: make port! tcp://localhost:8001
    ]

    if oneway
    [
        return rugby-client/rexec/with/oneway msg dest
    ]

    if deferred
    [
        return rugby-client/rexec/with/deferred msg dest
    ]

  return rugby-client/rexec/with msg dest
]


wait-for-result: func [ {Wait for the result to arrive}index {index of the result to wait for.}[integer!]]
[
  rugby-client/wait-for-result index
]


poll-for-result: func [ {Poll if the result has arrived. Return false or the value (or none in case of an error).}index {the index to poll for.} [integer!]]
[
  rugby-client/poll-for-result index
]










